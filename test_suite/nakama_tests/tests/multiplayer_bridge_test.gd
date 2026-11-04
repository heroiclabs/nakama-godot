extends "res://base_test.gd"

const RpcNode := preload("res://utils/rpc_node.gd")

# One player: login, socket, bridge, and a MultiplayerAPI rooted at its own node.
class Player:
	var session: NakamaSession
	var socket: NakamaSocket
	var bridge: NakamaMultiplayerBridge
	var api: SceneMultiplayer
	var rpc_node: RpcNode
	var connected_peers := []
	var disconnected_peers := []

# Records the levels of the messages the socket would print.
class LogSocket extends NakamaSocket:
	var printed := []

	func _init() -> void:
		super("ws", "127.0.0.1", 0)

	func _log(level: Nakama.LogLevel, _message: String) -> void:
		if level <= log_level:
			printed.append(level)

func setup() -> void:
	var client := Nakama.new(NakamaConfig.SERVER_KEY, NakamaConfig.HOST, NakamaConfig.PORT, NakamaConfig.SCHEME)
	var players: Array[Player] = []
	for i in 3:
		var player := await _new_player(client, "P%d" % i)
		if assert_cond(player != null):
			return
		players.append(player)
	if assert_cond(_claim_before_presence()):
		return
	if assert_cond(_host_leaves_before_claim()):
		return
	if assert_cond(_host_leaves_after_claim()):
		return
	if assert_cond(_server_claim_refused()):
		return
	if assert_cond(_socket_closed_while_joining()):
		return
	if assert_cond(_failed_send_logged()):
		return
	if assert_cond(_no_backlog_while_matchmaking()):
		return
	if assert_cond(await _create_join_rpc_leave(players)):
		return
	if assert_cond(await _unknown_match(players[2])):
		return
	for player: Player in players:
		player.socket.close()
	if assert_cond(await _matchmaking(client)):
		return
	if assert_cond(await _matched_before_start(client)):
		return
	if assert_cond(await _server_match(client)):
		return
	if assert_cond(await _rejoin_after_leave(client)):
		return
	if assert_cond(await _switch_after_leave(client)):
		return
	if assert_cond(await _rejoin_after_socket_close(client)):
		return
	if assert_cond(await _server_matchmaking(client)):
		return
	done()

func _new_player(client: Nakama, p_name: String) -> Player:
	var player := Player.new()
	var auth: NakamaResult = await client.authenticate_device_async("bridge-test-%d" % randi())
	if auth.error != null:
		return null
	player.session = auth.value
	player.socket = NakamaSocket.from(client)
	if await player.socket.connect_async(player.session) != null:
		return null
	player.bridge = NakamaMultiplayerBridge.new(player.socket)
	var player_root := Node.new()
	player_root.name = p_name
	add_child(player_root)
	player.rpc_node = RpcNode.new()
	player.rpc_node.name = "Rpc"
	player_root.add_child(player.rpc_node)
	player.api = SceneMultiplayer.new()
	get_tree().set_multiplayer(player.api, player_root.get_path())
	player.api.multiplayer_peer = player.bridge.multiplayer_peer
	player.api.peer_connected.connect(player.connected_peers.append)
	player.api.peer_disconnected.connect(player.disconnected_peers.append)
	return player

# The creator is host with ID 1, joiners get distinct IDs, everyone sees everyone, RPCs arrive with the
# right sender, and a leave disconnects that peer elsewhere. True if every check passed.
func _create_join_rpc_leave(players: Array[Player]) -> bool:
	var host := players[0]
	await host.bridge.create_match()
	if host.bridge.connection_state != NakamaMultiplayerBridge.ConnectionState.CONNECTED or host.api.get_unique_id() != 1:
		return false
	for joiner: Player in players.slice(1):
		joiner.bridge.join_match(host.bridge.match_id)
	await _wait(func() -> bool: return players.all(func(p: Player) -> bool: return p.connected_peers.size() == 2), 5000)

	var ids := players.map(func(p: Player) -> int: return p.api.get_unique_id())
	if not (ids[1] > 1 and ids[2] > 1 and ids[1] != ids[2]):
		return false
	for i in players.size():
		var others := ids.filter(func(id: int) -> bool: return id != ids[i])
		others.sort()
		var seen: Array = players[i].connected_peers.duplicate()
		seen.sort()
		if seen != others:
			return false

	# A broadcast from a joiner reaches the other two; a targeted call reaches only its target.
	players[1].rpc_node.ping.rpc("all")
	var target: int = ids[2]
	host.rpc_node.ping.rpc_id(target, "only two")
	await _wait(func() -> bool: return host.rpc_node.received.size() == 1 and players[2].rpc_node.received.size() == 2)
	# Packets from different senders can arrive in either order.
	var to_two: Array = players[2].rpc_node.received.duplicate()
	to_two.sort()
	if host.rpc_node.received != [["all", ids[1]]] or to_two != [["all", ids[1]], ["only two", 1]]:
		return false
	if not players[1].rpc_node.received.is_empty():
		return false

	# Closing the peer the usual Godot way leaves the match.
	players[2].api.multiplayer_peer.close()
	await _wait(func() -> bool: return host.disconnected_peers.size() == 1 and players[1].disconnected_peers.size() == 1)
	if host.disconnected_peers != [ids[2]] or players[1].disconnected_peers != [ids[2]]:
		return false
	# Without the host the match is over: the last player leaves too and hears that the server is gone.
	var lost := []
	players[1].api.server_disconnected.connect(func() -> void: lost.append(true))
	await host.bridge.leave()
	await _wait(func() -> bool: return not lost.is_empty())
	return lost.size() == 1 and players[1].bridge.connection_state == NakamaMultiplayerBridge.ConnectionState.DISCONNECTED

# Joining a match that does not exist emits match_join_error and frees the bridge to try again.
func _unknown_match(player: Player) -> bool:
	var unknown := "00000000-0000-0000-0000-000000000000."
	var errors := []
	player.bridge.match_join_error.connect(errors.append)
	# A retry from the error handler is accepted, so it fails again on its own.
	player.bridge.match_join_error.connect(func(_error: NakamaError) -> void: player.bridge.join_match(unknown), CONNECT_ONE_SHOT)
	await player.bridge.join_match(unknown)
	await _wait(func() -> bool: return errors.size() == 2)
	return errors.size() == 2 and player.bridge.connection_state == NakamaMultiplayerBridge.ConnectionState.DISCONNECTED

# Two players matched by the matchmaker join the same match; exactly one becomes host.
func _matchmaking(client: Nakama) -> bool:
	var players: Array[Player] = []
	for p_name: String in ["M0", "M1"]:
		var player := await _new_player(client, p_name)
		if player == null:
			return false
		players.append(player)
	for player: Player in players:
		var ticket: NakamaResult = await player.socket.add_matchmaker_async(2, 2, "*")
		if ticket.error != null:
			return false
		var ticket_value: NakamaSocketTypes.MatchmakerTicket = ticket.value
		player.bridge.start_matchmaking(ticket_value)
	await _wait(func() -> bool: return players.all(func(p: Player) -> bool: return p.connected_peers.size() == 1), 30000)
	var ids := players.map(func(p: Player) -> int: return p.api.get_unique_id())
	ids.sort()
	var ok: bool = ids[0] == 1 and ids[1] > 1 and players[0].bridge.match_id != "" \
			and players[0].bridge.match_id == players[1].bridge.match_id
	for player: Player in players:
		await player.bridge.leave()
		player.socket.close()
	return ok

# The matched event can arrive with the ticket reply, before the caller has the ticket for start_matchmaking();
# the bridge keeps it and joins once started.
func _matched_before_start(client: Nakama) -> bool:
	var players: Array[Player] = []
	var tickets: Array[NakamaSocketTypes.MatchmakerTicket] = []
	var matched := []
	for p_name: String in ["E0", "E1"]:
		var player := await _new_player(client, p_name)
		if player == null:
			return false
		player.socket.received_matchmaker_matched.connect(matched.append)
		players.append(player)
	for player: Player in players:
		var ticket: NakamaResult = await player.socket.add_matchmaker_async(2, 2, "*")
		if ticket.error != null:
			return false
		tickets.append(ticket.value)
	await _wait(func() -> bool: return matched.size() == 2, 30000)
	for i in players.size():
		players[i].bridge.start_matchmaking(tickets[i])
	await _wait(func() -> bool: return players.all(func(p: Player) -> bool: return p.connected_peers.size() == 1))
	var ok: bool = matched.size() == 2 and players.all(func(p: Player) -> bool: return p.connected_peers.size() == 1) \
			and players[0].bridge.match_id == players[1].bridge.match_id
	for player: Player in players:
		await player.bridge.leave()
		player.socket.close()
	return ok

# In the authoritative match of test_suite/server the match gives out the IDs, so nobody is peer 1, and it
# routes each RPC by the target peer ID at its start.
func _server_match(client: Nakama) -> bool:
	var players: Array[Player] = []
	for p_name: String in ["S0", "S1", "S2"]:
		var player := await _new_player(client, p_name)
		if player == null:
			return false
		players.append(player)
	var created: NakamaResult = await client.rpc_async(players[0].session, "create_bridge_match")
	if created.error != null:
		return false
	var reply: NakamaTypes.Rpc = created.value
	var payload: Dictionary = JSON.parse_string(reply.payload)
	var match_id: String = payload.match_id
	for player: Player in players:
		player.bridge.join_match(match_id)
	await _wait(func() -> bool: return players.all(func(p: Player) -> bool: return p.connected_peers.size() == 2), 5000)

	var ids := players.map(func(p: Player) -> int: return p.api.get_unique_id())
	if not players.all(func(p: Player) -> bool: return p.bridge.server_assigned):
		return false
	if not (ids.all(func(id: int) -> bool: return id > 1) and ids[0] != ids[1] and ids[1] != ids[2] and ids[0] != ids[2]):
		return false
	for i in players.size():
		var others := ids.filter(func(id: int) -> bool: return id != ids[i])
		others.sort()
		var seen: Array = players[i].connected_peers.duplicate()
		seen.sort()
		if seen != others:
			return false

	# A broadcast reaches both others with its sender's ID, a targeted call only its target.
	players[0].rpc_node.ping.rpc("all")
	var target: int = ids[2]
	players[1].rpc_node.ping.rpc_id(target, "only two")
	await _wait(func() -> bool: return players[1].rpc_node.received.size() == 1 and players[2].rpc_node.received.size() == 2)
	await get_tree().create_timer(0.3).timeout  # a misrouted copy would arrive by now
	var to_two: Array = players[2].rpc_node.received.duplicate()
	to_two.sort()
	var want := [["all", ids[0]], ["only two", ids[1]]]
	want.sort()
	var ok: bool = players[1].rpc_node.received == [["all", ids[0]]] and to_two == want \
			and players[0].rpc_node.received.is_empty()
	for player: Player in players:
		await player.bridge.leave()
		player.socket.close()
	return ok

# The matchmaker can put players in an authoritative match, as test_suite/server does for bridge=server
# tickets; that match gives out the IDs, so neither player may make itself host.
func _server_matchmaking(client: Nakama) -> bool:
	var players: Array[Player] = []
	for p_name: String in ["A0", "A1"]:
		var player := await _new_player(client, p_name)
		if player == null:
			return false
		players.append(player)
	for player: Player in players:
		var ticket: NakamaResult = await player.socket.add_matchmaker_async(2, 2, "+properties.bridge:server",
				null, {"bridge": "server"})
		if ticket.error != null:
			return false
		var ticket_value: NakamaSocketTypes.MatchmakerTicket = ticket.value
		player.bridge.start_matchmaking(ticket_value)
	await _wait(func() -> bool: return players.all(func(p: Player) -> bool: return p.connected_peers.size() == 1), 30000)
	var ids := players.map(func(p: Player) -> int: return p.api.get_unique_id())
	var ok: bool = players.all(func(p: Player) -> bool: return p.bridge.server_assigned) and ids.all(func(id: int) -> bool: return id > 1) \
			and ids[0] != ids[1]
	for player: Player in players:
		await player.bridge.leave()
		player.socket.close()
	return ok


# Join, leave before the reply, and join the same match again: the late first reply must not leave the
# match the second join is in.
func _rejoin_after_leave(client: Nakama) -> bool:
	var host := await _new_player(client, "R0")
	var guest := await _new_player(client, "R1")
	if host == null or guest == null:
		return false
	await host.bridge.create_match()
	guest.bridge.join_match(host.bridge.match_id)
	guest.bridge.leave()
	await guest.bridge.join_match(host.bridge.match_id)
	await _wait(func() -> bool: return host.connected_peers.size() == 1)
	# Long enough for a stray leave from the first join to reach the server and the host.
	await get_tree().create_timer(0.5).timeout
	var ok: bool = guest.bridge.connection_state == NakamaMultiplayerBridge.ConnectionState.CONNECTED \
			and host.connected_peers.size() == 1 and host.disconnected_peers.is_empty()
	for player: Player in [host, guest]:
		await player.bridge.leave()
		player.socket.close()
	return ok


# Join A, leave before the reply, and join B, whose only member does not use a bridge, so no host gives out a peer ID
# and the guest stays JOINING: the late reply from A must still leave A.
func _switch_after_leave(client: Nakama) -> bool:
	var host := await _new_player(client, "W0")
	var guest := await _new_player(client, "W1")
	var b_owner := await _new_player(client, "W2")
	if host == null or guest == null or b_owner == null:
		return false
	await host.bridge.create_match()
	var b: NakamaResult = await b_owner.socket.create_match_async()
	if b.error != null:
		return false
	var left_a := []
	host.socket.received_match_presence.connect(func(event: NakamaSocketTypes.MatchPresenceEvent) -> void:
		for presence: NakamaSocketTypes.UserPresence in event.leaves:
			if presence.user_id == guest.session.user_id:
				left_a.append(presence))
	guest.bridge.join_match(host.bridge.match_id)
	guest.bridge.leave()
	var b_match: NakamaSocketTypes.Match = b.value
	await guest.bridge.join_match(b_match.match_id)
	await _wait(func() -> bool: return not left_a.is_empty())
	var ok: bool = not left_a.is_empty() and guest.bridge.connection_state == NakamaMultiplayerBridge.ConnectionState.JOINING
	for player: Player in [host, guest, b_owner]:
		await player.bridge.leave()
		player.socket.close()
	return ok


# A socket drop leaves the bridge SOCKET_CLOSED; once the socket reconnects, the bridge joins again.
func _rejoin_after_socket_close(client: Nakama) -> bool:
	var host := await _new_player(client, "C0")
	var guest := await _new_player(client, "C1")
	if host == null or guest == null:
		return false
	await host.bridge.create_match()
	guest.bridge.join_match(host.bridge.match_id)
	await _wait(func() -> bool: return guest.bridge.connection_state == NakamaMultiplayerBridge.ConnectionState.CONNECTED)
	guest.socket.close()
	if guest.bridge.connection_state != NakamaMultiplayerBridge.ConnectionState.SOCKET_CLOSED:
		return false
	if await guest.socket.connect_async(guest.session) != null:
		return false
	guest.bridge.join_match(host.bridge.match_id)
	await _wait(func() -> bool: return guest.bridge.connection_state == NakamaMultiplayerBridge.ConnectionState.CONNECTED)
	var ok: bool = guest.bridge.connection_state == NakamaMultiplayerBridge.ConnectionState.CONNECTED
	for player: Player in [host, guest]:
		await player.bridge.leave()
		player.socket.close()
	return ok


# The host's claim and ID can arrive before the server's presence event for the host; the player still connects.
func _claim_before_presence() -> bool:
	var bridge := NakamaMultiplayerBridge.new(NakamaSocket.new("ws", "127.0.0.1", 0))
	var me := NakamaSocketTypes.UserPresence.new("me-user", "me-session", "me")
	var host := NakamaSocketTypes.UserPresence.new("host-user", "host-session", "host")
	bridge._start_joining("test")
	bridge._setup_match(NakamaSocketTypes.Match.new("m1", false, null, 1, [], me))
	var claim := JSON.stringify({type = NakamaMultiplayerBridge.MetaMessageType.CLAIM_HOST})
	var assign := JSON.stringify({type = NakamaMultiplayerBridge.MetaMessageType.ASSIGN_PEER_ID, session_id = "me-session", peer_id = 5})
	for text: String in [claim, assign]:
		bridge._on_received_match_state(NakamaSocketTypes.MatchData.new("m1", host, bridge.meta_op_code, text.to_utf8_buffer()))
	return bridge.connection_state == NakamaMultiplayerBridge.ConnectionState.CONNECTED and bridge.multiplayer_peer.get_unique_id() == 5


# The elected host of a matchmaker match leaves before its claim arrives, so it never became peer 1: the player
# waiting for its ID must still leave, not stay JOINING forever.
func _host_leaves_before_claim() -> bool:
	var bridge := NakamaMultiplayerBridge.new(NakamaSocket.new("ws", "127.0.0.1", 0))
	var me := NakamaSocketTypes.UserPresence.new("me-user", "me-session", "me")
	# The lowest session ID, so the matchmaker elects it host.
	var host := NakamaSocketTypes.UserPresence.new("host-user", "a-host-session", "host")
	bridge._start_joining("test")
	bridge._setup_match(NakamaSocketTypes.Match.new("m1", false, null, 2, [host], me))
	bridge._elected_host_session_id = host.session_id
	var errors := []
	bridge.match_join_error.connect(errors.append)
	bridge._on_received_match_presence(NakamaSocketTypes.MatchPresenceEvent.new("m1", [], [host]))
	var ok := bridge.connection_state == NakamaMultiplayerBridge.ConnectionState.DISCONNECTED \
			and bridge.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED \
			and errors.size() == 1
	bridge.leave()
	return ok


# The host claims, then leaves before giving this player an ID: the join failed, so match_join_error is emitted.
func _host_leaves_after_claim() -> bool:
	var bridge := NakamaMultiplayerBridge.new(NakamaSocket.new("ws", "127.0.0.1", 0))
	var me := NakamaSocketTypes.UserPresence.new("me-user", "me-session", "me")
	var host := NakamaSocketTypes.UserPresence.new("host-user", "host-session", "host")
	bridge._start_joining("test")
	bridge._setup_match(NakamaSocketTypes.Match.new("m1", false, null, 2, [host], me))
	var claim := JSON.stringify({type = NakamaMultiplayerBridge.MetaMessageType.CLAIM_HOST})
	bridge._on_received_match_state(NakamaSocketTypes.MatchData.new("m1", host, bridge.meta_op_code, claim.to_utf8_buffer()))
	var errors := []
	bridge.match_join_error.connect(errors.append)
	bridge._on_received_match_presence(NakamaSocketTypes.MatchPresenceEvent.new("m1", [], [host]))
	var ok := bridge.connection_state == NakamaMultiplayerBridge.ConnectionState.DISCONNECTED and errors.size() == 1
	bridge.leave()
	return ok


# A host claim from the match itself, which has no sender, makes nobody host.
func _server_claim_refused() -> bool:
	var bridge := NakamaMultiplayerBridge.new(NakamaSocket.new("ws", "127.0.0.1", 0))
	var me := NakamaSocketTypes.UserPresence.new("me-user", "me-session", "me")
	bridge._start_joining("test")
	bridge._setup_match(NakamaSocketTypes.Match.new("m1", true, null, 1, [], me))
	var claim := JSON.stringify({type = NakamaMultiplayerBridge.MetaMessageType.CLAIM_HOST})
	bridge._on_received_match_state(NakamaSocketTypes.MatchData.new("m1", null, bridge.meta_op_code, claim.to_utf8_buffer()))
	var ok := not bridge._id_map.has(1)
	bridge.leave()
	return ok


# The socket closes while joining: the join failed, so match_join_error is emitted, even though the late join
# reply is then ignored as stale.
func _socket_closed_while_joining() -> bool:
	var bridge := NakamaMultiplayerBridge.new(NakamaSocket.new("ws", "127.0.0.1", 0))
	var errors := []
	bridge.match_join_error.connect(errors.append)
	bridge._start_joining("test")
	bridge._on_socket_closed(1006, "")
	var ok := bridge.connection_state == NakamaMultiplayerBridge.ConnectionState.SOCKET_CLOSED and errors.size() == 1
	bridge.leave()
	return ok


# A failed send, e.g. of a newcomer's peer ID, shows at the default log level: that newcomer is stuck JOINING.
func _failed_send_logged() -> bool:
	var socket := LogSocket.new()
	var bridge := NakamaMultiplayerBridge.new(socket)
	bridge._log_failure(NakamaResult.new(null, NakamaError.new(0, NakamaError.UNAVAILABLE, "down")), "send a meta message")
	return socket.printed.size() == 1


# While the matchmaker searches, no join is sent, so events from other matches are not held for later.
func _no_backlog_while_matchmaking() -> bool:
	var bridge := NakamaMultiplayerBridge.new(NakamaSocket.new("ws", "127.0.0.1", 0))
	var ticket := NakamaSocketTypes.MatchmakerTicket.new("waiting-ticket")
	bridge.start_matchmaking(ticket)
	for i in 100:
		bridge._on_received_match_state(NakamaSocketTypes.MatchData.new("lobby-match"))
	var ok := bridge.connection_state == NakamaMultiplayerBridge.ConnectionState.JOINING and bridge._pending_events.is_empty()
	bridge.leave()
	return ok


func _wait(condition: Callable, timeout_ms: int = 3000) -> void:
	var deadline := Time.get_ticks_msec() + timeout_ms
	while not condition.call() and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame

func _process(_delta: float) -> void:
	assert_time(60)

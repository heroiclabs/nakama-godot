extends "res://base_test.gd"

# The node each player calls RPCs on; the same name under every player's multiplayer root.
const RPC_NODE_SOURCE := """
extends Node
var received: Array = []

@rpc("any_peer")
func ping(text: String) -> void:
	received.append([text, multiplayer.get_remote_sender_id()])
"""

var _rpc_script := GDScript.new()

# One player: login, socket, bridge, and a MultiplayerAPI rooted at its own node.
class Player:
	var session: NakamaSession
	var socket: NakamaSocket
	var bridge: NakamaMultiplayerBridge
	var api: SceneMultiplayer
	var rpc_node: Node
	var connected_peers := []
	var disconnected_peers := []

func setup():
	_rpc_script.source_code = RPC_NODE_SOURCE
	_rpc_script.reload()
	var client := Nakama.new(NakamaConfig.SERVER_KEY, NakamaConfig.HOST, NakamaConfig.PORT, NakamaConfig.SCHEME)
	var players: Array[Player] = []
	for i in 3:
		var player := await _new_player(client, "P%d" % i)
		if assert_cond(player != null):
			return
		players.append(player)
	if assert_cond(await _create_join_rpc_leave(players)):
		return
	if assert_cond(await _unknown_match(players[2])):
		return
	for player in players:
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
	player.rpc_node = Node.new()
	player.rpc_node.name = "Rpc"
	player.rpc_node.set_script(_rpc_script)
	player_root.add_child(player.rpc_node)
	player.api = SceneMultiplayer.new()
	get_tree().set_multiplayer(player.api, player_root.get_path())
	player.api.multiplayer_peer = player.bridge.multiplayer_peer
	player.api.peer_connected.connect(player.connected_peers.append)
	player.api.peer_disconnected.connect(player.disconnected_peers.append)
	return player

# The creator is host with id 1, joiners get distinct ids, everyone sees everyone, RPCs arrive with the
# right sender, and a leave disconnects that peer elsewhere. True if every check passed.
func _create_join_rpc_leave(players: Array[Player]) -> bool:
	var host := players[0]
	await host.bridge.create_match()
	if host.bridge.connection_state != NakamaMultiplayerBridge.ConnectionState.CONNECTED or host.api.get_unique_id() != 1:
		return false
	for joiner in players.slice(1):
		joiner.bridge.join_match(host.bridge.match_id)
	await _wait(func(): return players.all(func(p): return p.connected_peers.size() == 2), 5000)

	var ids := players.map(func(p): return p.api.get_unique_id())
	if not (ids[1] > 1 and ids[2] > 1 and ids[1] != ids[2]):
		return false
	for i in players.size():
		var others := ids.filter(func(id): return id != ids[i])
		others.sort()
		var seen: Array = players[i].connected_peers.duplicate()
		seen.sort()
		if seen != others:
			return false

	# A broadcast from a joiner reaches the other two; a targeted call reaches only its target.
	players[1].rpc_node.ping.rpc("all")
	host.rpc_node.ping.rpc_id(ids[2], "only two")
	await _wait(func(): return host.rpc_node.received.size() == 1 and players[2].rpc_node.received.size() == 2)
	# Packets from different senders can arrive in either order.
	var to_two: Array = players[2].rpc_node.received.duplicate()
	to_two.sort()
	if host.rpc_node.received != [["all", ids[1]]] or to_two != [["all", ids[1]], ["only two", 1]]:
		return false
	if not players[1].rpc_node.received.is_empty():
		return false

	await players[2].bridge.leave()
	await _wait(func(): return host.disconnected_peers.size() == 1 and players[1].disconnected_peers.size() == 1)
	if host.disconnected_peers != [ids[2]] or players[1].disconnected_peers != [ids[2]]:
		return false
	await host.bridge.leave()
	await players[1].bridge.leave()
	return true

# Joining a match that does not exist emits match_join_error and frees the bridge to try again.
func _unknown_match(player: Player) -> bool:
	var errors := []
	player.bridge.match_join_error.connect(errors.append)
	await player.bridge.join_match("00000000-0000-0000-0000-000000000000.")
	return errors.size() == 1 and player.bridge.connection_state == NakamaMultiplayerBridge.ConnectionState.DISCONNECTED

# Two players matched by the matchmaker join the same match; exactly one becomes host.
func _matchmaking(client: Nakama) -> bool:
	var players: Array[Player] = []
	for p_name in ["M0", "M1"]:
		var player := await _new_player(client, p_name)
		if player == null:
			return false
		players.append(player)
	for player in players:
		var ticket: NakamaResult = await player.socket.add_matchmaker_async(2, 2, "*")
		if ticket.error != null:
			return false
		player.bridge.start_matchmaking(ticket.value)
	await _wait(func(): return players.all(func(p): return p.connected_peers.size() == 1), 30000)
	var ids := players.map(func(p): return p.api.get_unique_id())
	ids.sort()
	var ok: bool = ids[0] == 1 and ids[1] > 1 and players[0].bridge.match_id != "" \
			and players[0].bridge.match_id == players[1].bridge.match_id
	for player in players:
		await player.bridge.leave()
		player.socket.close()
	return ok

# The matched event can arrive with the ticket reply, before the caller has the ticket for start_matchmaking();
# the bridge keeps it and joins once started.
func _matched_before_start(client: Nakama) -> bool:
	var players: Array[Player] = []
	var tickets: Array[NakamaRtTypes.MatchmakerTicket] = []
	var matched := []
	for p_name in ["E0", "E1"]:
		var player := await _new_player(client, p_name)
		if player == null:
			return false
		player.socket.received_matchmaker_matched.connect(matched.append)
		players.append(player)
	for player in players:
		var ticket: NakamaResult = await player.socket.add_matchmaker_async(2, 2, "*")
		if ticket.error != null:
			return false
		tickets.append(ticket.value)
	await _wait(func(): return matched.size() == 2, 30000)
	for i in players.size():
		players[i].bridge.start_matchmaking(tickets[i])
	await _wait(func(): return players.all(func(p): return p.connected_peers.size() == 1))
	var ok: bool = matched.size() == 2 and players.all(func(p): return p.connected_peers.size() == 1) \
			and players[0].bridge.match_id == players[1].bridge.match_id
	for player in players:
		await player.bridge.leave()
		player.socket.close()
	return ok

# In the authoritative match of test_suite/server the match gives out the ids, so nobody is peer 1, and it
# routes each RPC by the target in front of it.
func _server_match(client: Nakama) -> bool:
	var players: Array[Player] = []
	for p_name in ["S0", "S1", "S2"]:
		var player := await _new_player(client, p_name)
		if player == null:
			return false
		players.append(player)
	var created: NakamaResult = await client.rpc_async(players[0].session, "create_bridge_match")
	if created.error != null:
		return false
	var match_id: String = JSON.parse_string(created.value.payload).match_id
	for player in players:
		player.bridge.join_match(match_id)
	await _wait(func(): return players.all(func(p): return p.connected_peers.size() == 2), 5000)

	var ids := players.map(func(p): return p.api.get_unique_id())
	if not players.all(func(p): return p.bridge.server_assigned):
		return false
	if not (ids.all(func(id): return id > 1) and ids[0] != ids[1] and ids[1] != ids[2] and ids[0] != ids[2]):
		return false
	for i in players.size():
		var others := ids.filter(func(id): return id != ids[i])
		others.sort()
		var seen: Array = players[i].connected_peers.duplicate()
		seen.sort()
		if seen != others:
			return false

	# A broadcast reaches both others with its sender's id, a targeted call only its target.
	players[0].rpc_node.ping.rpc("all")
	players[1].rpc_node.ping.rpc_id(ids[2], "only two")
	await _wait(func(): return players[1].rpc_node.received.size() == 1 and players[2].rpc_node.received.size() == 2)
	await get_tree().create_timer(0.3).timeout  # a misrouted copy would arrive by now
	var to_two: Array = players[2].rpc_node.received.duplicate()
	to_two.sort()
	var want := [["all", ids[0]], ["only two", ids[1]]]
	want.sort()
	var ok: bool = players[1].rpc_node.received == [["all", ids[0]]] and to_two == want \
			and players[0].rpc_node.received.is_empty()
	for player in players:
		await player.bridge.leave()
		player.socket.close()
	return ok

# The matchmaker can put players in an authoritative match, as test_suite/server does for bridge=server
# tickets; that match gives out the ids, so neither player may make itself host.
func _server_matchmaking(client: Nakama) -> bool:
	var players: Array[Player] = []
	for p_name in ["A0", "A1"]:
		var player := await _new_player(client, p_name)
		if player == null:
			return false
		players.append(player)
	for player in players:
		var ticket: NakamaResult = await player.socket.add_matchmaker_async(2, 2, "+properties.bridge:server",
				null, {"bridge": "server"})
		if ticket.error != null:
			return false
		player.bridge.start_matchmaking(ticket.value)
	await _wait(func(): return players.all(func(p): return p.connected_peers.size() == 1), 30000)
	var ids := players.map(func(p): return p.api.get_unique_id())
	var ok: bool = players.all(func(p): return p.bridge.server_assigned) and ids.all(func(id): return id > 1) \
			and ids[0] != ids[1]
	for player in players:
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
	await _wait(func(): return host.connected_peers.size() == 1)
	# Long enough for a stray leave from the first join to reach the server and the host.
	await get_tree().create_timer(0.5).timeout
	var ok: bool = guest.bridge.connection_state == NakamaMultiplayerBridge.ConnectionState.CONNECTED \
			and host.connected_peers.size() == 1 and host.disconnected_peers.is_empty()
	for player in [host, guest]:
		await player.bridge.leave()
		player.socket.close()
	return ok


# Join A, leave before the reply, and join B, whose only member does not use a bridge, so no host gives out a peer ID
# and the guest stays JOINING: the late reply from A must still leave A.
func _switch_after_leave(client: Nakama) -> bool:
	var host := await _new_player(client, "S0")
	var guest := await _new_player(client, "S1")
	var b_owner := await _new_player(client, "S2")
	if host == null or guest == null or b_owner == null:
		return false
	await host.bridge.create_match()
	var b: NakamaResult = await b_owner.socket.create_match_async()
	if b.error != null:
		return false
	var left_a := []
	host.socket.received_match_presence.connect(func(event: NakamaRtTypes.MatchPresenceEvent) -> void:
		for presence: NakamaRtTypes.UserPresence in event.leaves:
			if presence.user_id == guest.session.user_id:
				left_a.append(presence))
	guest.bridge.join_match(host.bridge.match_id)
	guest.bridge.leave()
	await guest.bridge.join_match(b.value.match_id)
	await _wait(func(): return not left_a.is_empty())
	var ok: bool = not left_a.is_empty() and guest.bridge.connection_state == NakamaMultiplayerBridge.ConnectionState.JOINING
	for player in [host, guest, b_owner]:
		await player.bridge.leave()
		player.socket.close()
	return ok


func _wait(condition: Callable, timeout_ms: int = 3000) -> void:
	var deadline := Time.get_ticks_msec() + timeout_ms
	while not condition.call() and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame

func _process(_delta):
	assert_time(60)

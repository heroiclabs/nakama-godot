# Copyright 2026 The Nakama Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class_name NakamaMultiplayerBridge
extends RefCounted
## Runs Godot's high-level multiplayer (RPCs, peer signals, authority) over a Nakama match.
## Set multiplayer_peer on a MultiplayerAPI, then create_match(), join_match(), join_named_match() or
## start_matchmaking(). In a relayed match the host, who created the match or was elected among matched
## players, gets peer ID 1 and gives every other player its ID. An authoritative match can give out the IDs
## instead, so no player is the host and nobody is peer 1: see server_assigned. match_joined is emitted once
## this player has an ID.

## Emitted when this player has a peer ID and can send RPCs.
signal match_joined
## Emitted when creating or joining the match failed; the bridge is then disconnected again.
signal match_join_error(error: NakamaError)

enum ConnectionState { DISCONNECTED, JOINING, CONNECTED, SOCKET_CLOSED }
enum MetaMessageType { CLAIM_HOST, ASSIGN_PEER_ID }

## Matched events kept for tickets the bridge may still get; the rest, e.g. for tickets used without the
## bridge, are dropped.
const MAX_EARLY_MATCHED := 8

## Read-only.
var socket: NakamaSocket:
	get: return _socket
	set(_v): _read_only("socket")
## Read-only.
var connection_state: ConnectionState:
	get: return _connection_state
	set(_v): _read_only("connection_state")
## Read-only. The current match, or "" when not in one.
var match_id: String:
	get: return _match_id
	set(_v): _read_only("match_id")
## Read-only. Give it to MultiplayerAPI.multiplayer_peer.
var multiplayer_peer: NakamaMultiplayerPeer:
	get: return _multiplayer_peer
	set(_v): _read_only("multiplayer_peer")
## Op code of the bridge's own messages that assign peer IDs.
var meta_op_code := 9001
## Op code of the match state that carries Godot's packets.
var rpc_op_code := 9002
## Read-only. True when the match's server, not a host, gave out the peer IDs, as in an authoritative match.
## RPCs then go through the server, which forwards each one to the peers it targets.
var server_assigned: bool:
	get: return _server_assigned
	set(_v): _read_only("server_assigned")

var _socket: NakamaSocket
var _connection_state := ConnectionState.DISCONNECTED
var _match_id := ""
var _multiplayer_peer := NakamaMultiplayerPeer.new()
var _server_assigned := false
var _my_session_id := ""
var _my_peer_id := 0
## Session ID by peer ID.
var _id_map: Dictionary = {}
## User by session ID.
var _users: Dictionary = {}
var _matchmaker_ticket := ""
## Matched events for tickets not yet passed to start_matchmaking(): one can arrive in the same socket poll as
## its ticket, before the caller has the ticket. Oldest dropped past MAX_EARLY_MATCHED.
var _early_matched: Dictionary = {}
## Match events that arrived before the join reply, replayed once match_id is known.
var _pending_events: Array[Callable] = []
## Bumped by leave(), so a join reply that arrives after it is ignored.
var _attempt := 0


func _init(p_socket: NakamaSocket) -> void:
	_socket = p_socket
	socket.received_match_presence.connect(_on_received_match_presence)
	socket.received_matchmaker_matched.connect(_on_received_matchmaker_matched)
	socket.received_match_state.connect(_on_received_match_state)
	socket.closed.connect(_on_socket_closed)
	multiplayer_peer.packet_generated.connect(_on_packet_generated)
	multiplayer_peer.set_connection_status(MultiplayerPeer.CONNECTION_CONNECTING)


## Creates a new relayed match with this player as the host.
func create_match() -> void:
	if not _start_joining("create a match"):
		return
	var attempt := _attempt
	var result: NakamaResult = await socket.create_match_async()
	if await _join_failed(result, attempt):
		return
	var joined: NakamaRtTypes.Match = result.value
	_setup_match(joined)
	_setup_host()
	_replay_pending_events()


## Joins the match with match_id; its host, or the match itself, assigns this player a peer ID.
func join_match(p_match_id: String) -> void:
	if not _start_joining("join a match"):
		return
	var attempt := _attempt
	var result: NakamaResult = await socket.join_match_async(p_match_id, null, {})
	if await _join_failed(result, attempt):
		return
	var joined: NakamaRtTypes.Match = result.value
	_setup_match(joined)
	_replay_pending_events()


## Joins the match named match_name, creating it with this player as the host if nobody is in it.
func join_named_match(match_name: String) -> void:
	if not _start_joining("join a named match"):
		return
	var attempt := _attempt
	var result: NakamaResult = await socket.create_match_async(match_name)
	if await _join_failed(result, attempt):
		return
	var joined: NakamaRtTypes.Match = result.value
	_setup_match(joined)
	if joined.size == 0 or (joined.size == 1 and joined.presences.is_empty()):
		_setup_host()
	_replay_pending_events()


## Waits for the matchmaker to match ticket, from socket.add_matchmaker_async, then joins that match.
## The matched player with the lowest session ID becomes the host.
func start_matchmaking(ticket: NakamaRtTypes.MatchmakerTicket) -> void:
	if not _start_joining("start matchmaking"):
		return
	_matchmaker_ticket = ticket.ticket
	if _early_matched.has(ticket.ticket):
		var matched: NakamaRtTypes.MatchmakerMatched = _early_matched[ticket.ticket]
		_early_matched.erase(ticket.ticket)
		# No await: joins on its own, as when the event arrives later
		_on_received_matchmaker_matched(matched)


func get_user_presence_for_peer(peer_id: int) -> NakamaRtTypes.UserPresence:
	var user: User = _users.get(_id_map.get(peer_id, ""))
	return user.presence if user else null


## Leaves the match, or the matchmaker if still waiting, and disconnects multiplayer_peer.
func leave() -> void:
	if connection_state == ConnectionState.DISCONNECTED:
		return
	_connection_state = ConnectionState.DISCONNECTED
	_attempt += 1
	var left_match_id := match_id
	var ticket := _matchmaker_ticket
	_cleanup()
	if left_match_id != "":
		_log_error(await socket.leave_match_async(left_match_id), "leave the match")
	if ticket != "":
		_log_error(await socket.remove_matchmaker_async(ticket), "leave the matchmaker")


func _read_only(property: String) -> void:
	push_error("NakamaMultiplayerBridge.%s is read-only" % property)


func _start_joining(what: String) -> bool:
	if connection_state != ConnectionState.DISCONNECTED:
		socket._log(Nakama.LogLevel.ERROR, "cannot %s while the multiplayer bridge is %s" % [what, ConnectionState.keys()[connection_state]])
		return false
	_connection_state = ConnectionState.JOINING
	multiplayer_peer.set_connection_status(MultiplayerPeer.CONNECTION_CONNECTING)
	return true


func _join_failed(result: NakamaResult, attempt: int) -> bool:
	if attempt != _attempt:
		# leave() ran while waiting: leave the match the late reply joined. Nakama keeps one membership per
		# session and match, so first wait for a newer join's reply, not its peer ID, and stay if it is in
		# that match. Another leave() ends the wait.
		if result.error == null:
			var joined: NakamaRtTypes.Match = result.value
			while connection_state == ConnectionState.JOINING and match_id == "" and _matchmaker_ticket == "":
				await (Engine.get_main_loop() as SceneTree).process_frame
			if match_id != joined.match_id:
				_log_error(await socket.leave_match_async(joined.match_id), "leave the match")
		return true
	if result.error == null:
		return false
	match_join_error.emit(result.error)
	await leave()
	return true


func _log_error(result: NakamaResult, what: String) -> void:
	if result.error != null:
		socket._log(Nakama.LogLevel.INFO, "multiplayer bridge cannot %s: %s" % [what, result.error])


func _on_received_matchmaker_matched(matched: NakamaRtTypes.MatchmakerMatched) -> void:
	if _matchmaker_ticket == "" or matched.ticket != _matchmaker_ticket:
		_early_matched[matched.ticket] = matched
		if _early_matched.size() > MAX_EARLY_MATCHED:
			_early_matched.erase(_early_matched.keys()[0])
		return
	# The ticket is used up once matched, so leave() must not remove it.
	_matchmaker_ticket = ""
	var session_ids: Array = matched.users.map(func(user: NakamaRtTypes.MatchmakerMatchedMatchmakerUser) -> String: return user.presence.session_id)
	session_ids.sort()
	var attempt := _attempt
	var result: NakamaResult = await socket.join_matched_async(matched)
	if await _join_failed(result, attempt):
		return
	var joined: NakamaRtTypes.Match = result.value
	_setup_match(joined)
	# An authoritative match gives out the IDs itself, so only a relayed one gets a player host.
	if not joined.authoritative and _my_session_id == session_ids[0]:
		_setup_host()
		for user: User in _users.values():
			if user.peer_id == 0:
				_host_add_peer(user.presence)
	_replay_pending_events()


func _on_socket_closed(_code: int, _reason: String) -> void:
	if connection_state == ConnectionState.DISCONNECTED:
		return
	_connection_state = ConnectionState.SOCKET_CLOSED
	# A join reply the socket read before closing must not set up a match on a closed socket.
	_attempt += 1
	_cleanup()


func _cleanup() -> void:
	for peer_id: int in _id_map:
		if peer_id != _my_peer_id:
			multiplayer_peer.peer_disconnected.emit(peer_id)
	_match_id = ""
	_server_assigned = false
	_matchmaker_ticket = ""
	_my_session_id = ""
	_my_peer_id = 0
	_id_map.clear()
	_users.clear()
	_pending_events.clear()
	multiplayer_peer.set_connection_status(MultiplayerPeer.CONNECTION_DISCONNECTED)


func _setup_match(joined: NakamaRtTypes.Match) -> void:
	_match_id = joined.match_id
	_my_session_id = joined.self_.session_id
	_users[_my_session_id] = User.new(joined.self_)
	for presence: NakamaRtTypes.UserPresence in joined.presences:
		if not _users.has(presence.session_id):
			_users[presence.session_id] = User.new(presence)


func _replay_pending_events() -> void:
	var events := _pending_events
	_pending_events = []
	for event in events:
		event.call()


func _setup_host() -> void:
	_my_peer_id = 1
	_map_id_to_session(1, _my_session_id)
	_connection_state = ConnectionState.CONNECTED
	multiplayer_peer.initialize(_my_peer_id)
	match_joined.emit()


func _generate_id(session_id: String) -> int:
	# Peer IDs are positive 32-bit signed integers, and 1 is the host's.
	var peer_id: int = session_id.hash() & 0x7FFFFFFF
	while peer_id <= 1 or _id_map.has(peer_id):
		peer_id += 1
		if peer_id > 0x7FFFFFFF:
			peer_id = randi() & 0x7FFFFFFF
	return peer_id


func _map_id_to_session(peer_id: int, session_id: String) -> void:
	_id_map[peer_id] = session_id
	_users[session_id].peer_id = peer_id


func _host_add_peer(presence: NakamaRtTypes.UserPresence) -> void:
	var peer_id := _generate_id(presence.session_id)
	_map_id_to_session(peer_id, presence.session_id)
	# Not awaited: the sends go out in this order either way, and the handler need not wait for them.
	_send_meta({type = MetaMessageType.CLAIM_HOST}, [presence])
	# Tell the newcomer about everyone else already connected.
	for other_peer_id: int in _id_map:
		var other_session_id: String = _id_map[other_peer_id]
		if other_session_id == presence.session_id or other_session_id == _my_session_id:
			continue
		_send_meta({type = MetaMessageType.ASSIGN_PEER_ID, session_id = other_session_id, peer_id = other_peer_id}, [presence])
	# Only to players with IDs: one that joined but is not claimed yet hears of everyone once it is.
	var assigned: Array[NakamaRtTypes.UserPresence] = []
	for other_peer_id: int in _id_map:
		if other_peer_id != _my_peer_id:
			assigned.append(_users[_id_map[other_peer_id]].presence)
	_send_meta({type = MetaMessageType.ASSIGN_PEER_ID, session_id = presence.session_id, peer_id = peer_id}, assigned)
	multiplayer_peer.peer_connected.emit(peer_id)


func _send_meta(content: Dictionary, presences: Array[NakamaRtTypes.UserPresence]) -> void:
	_log_error(await socket.send_match_state_async(match_id, meta_op_code, JSON.stringify(content), true, presences), "send a meta message")


## Holds event_handler for later if the match reply has not arrived yet; true if it held it.
func _defer_until_joined(event_handler: Callable) -> bool:
	if connection_state == ConnectionState.JOINING and match_id == "":
		_pending_events.append(event_handler)
		return true
	return false


func _on_received_match_presence(event: NakamaRtTypes.MatchPresenceEvent) -> void:
	if connection_state == ConnectionState.DISCONNECTED or _defer_until_joined(_on_received_match_presence.bind(event)):
		return
	if event.match_id != match_id:
		return
	for presence: NakamaRtTypes.UserPresence in event.joins:
		if not _users.has(presence.session_id):
			_users[presence.session_id] = User.new(presence)
		if _my_peer_id == 1 and _users[presence.session_id].peer_id == 0:
			_host_add_peer(presence)
	for presence: NakamaRtTypes.UserPresence in event.leaves:
		if not _users.has(presence.session_id):
			continue
		var peer_id: int = _users[presence.session_id].peer_id
		_users.erase(presence.session_id)
		if peer_id != 0:
			_id_map.erase(peer_id)
			multiplayer_peer.peer_disconnected.emit(peer_id)


func _on_received_match_state(state: NakamaRtTypes.MatchData) -> void:
	if connection_state == ConnectionState.DISCONNECTED or _defer_until_joined(_on_received_match_state.bind(state)):
		return
	if state.match_id != match_id:
		return
	# Only an authoritative match's own messages have no sender.
	var from_session_id: String = state.presence.session_id if state.presence else ""
	if state.op_code == meta_op_code:
		_on_meta_message(state.data.get_string_from_utf8(), from_session_id)
	elif state.op_code == rpc_op_code:
		var from_user: User = _users.get(from_session_id)
		if from_user == null or from_user.peer_id == 0:
			socket._log(Nakama.LogLevel.ERROR, "multiplayer bridge got an RPC from %s, who has no peer ID" % from_session_id)
			return
		multiplayer_peer.deliver_packet(state.data, from_user.peer_id)


func _on_meta_message(text: String, from_session_id: String) -> void:
	var json := JSON.new()
	var parsed: Variant = json.data if json.parse(text) == OK else null
	if not parsed is Dictionary:
		socket._log(Nakama.LogLevel.ERROR, "multiplayer bridge got an unreadable meta message from %s: %s" % [from_session_id, text])
		return
	var content: Dictionary = parsed
	var type: int = type_convert(content.get("type", -1), TYPE_INT)
	if type == MetaMessageType.CLAIM_HOST:
		if _id_map.has(1):
			socket._log(Nakama.LogLevel.ERROR, "multiplayer bridge: %s claims to be the host, but %s already is" % [from_session_id, _id_map[1]])
		elif not _users.has(from_session_id):
			socket._log(Nakama.LogLevel.ERROR, "multiplayer bridge: %s claims to be the host, but is not in the match" % from_session_id)
		else:
			_map_id_to_session(1, from_session_id)
		return
	var from_server := from_session_id == ""
	if not from_server and from_session_id != _id_map.get(1, ""):
		socket._log(Nakama.LogLevel.ERROR, "multiplayer bridge got a meta message from %s, who is not the host: %s" % [from_session_id, text])
		return
	if type != MetaMessageType.ASSIGN_PEER_ID:
		socket._log(Nakama.LogLevel.ERROR, "multiplayer bridge got a meta message of unknown type: %s" % text)
		return
	var session_id: String = content.get("session_id", "")
	var peer_id: int = type_convert(content.get("peer_id", 0), TYPE_INT)
	# The server's message can beat the newcomer's presence event, so it names the user too.
	if from_server and not _users.has(session_id) and content.has("user_id"):
		var user_id: String = content.get("user_id", "")
		var username: String = content.get("username", "")
		_users[session_id] = User.new(NakamaRtTypes.UserPresence.new(user_id, session_id, username))
	if not _users.has(session_id) or _users[session_id].peer_id != 0:
		socket._log(Nakama.LogLevel.ERROR, "multiplayer bridge cannot give peer ID %d to %s: unknown or already has one" % [peer_id, session_id])
		return
	_map_id_to_session(peer_id, session_id)
	if session_id == _my_session_id:
		_my_peer_id = peer_id
		_server_assigned = from_server
		_connection_state = ConnectionState.CONNECTED
		multiplayer_peer.initialize(peer_id)
		multiplayer_peer.set_connection_status(MultiplayerPeer.CONNECTION_CONNECTED)
		match_joined.emit()
		if _id_map.has(1):
			multiplayer_peer.peer_connected.emit(1)
	else:
		multiplayer_peer.peer_connected.emit(peer_id)


func _on_packet_generated(peer_id: int, buffer: PackedByteArray) -> void:
	if connection_state != ConnectionState.CONNECTED:
		socket._log(Nakama.LogLevel.ERROR, "multiplayer bridge cannot send an RPC before match_joined")
		return
	if server_assigned:
		var target := PackedByteArray()
		target.resize(4)
		target.encode_s32(0, peer_id)
		_log_error(await socket.send_match_state_async(match_id, rpc_op_code, target + buffer, true), "send an RPC")
		return
	var presences: Array[NakamaRtTypes.UserPresence] = []
	if peer_id > 0:
		if not _id_map.has(peer_id):
			socket._log(Nakama.LogLevel.ERROR, "multiplayer bridge cannot send an RPC to unknown peer ID %d" % peer_id)
			return
		presences = [_users[_id_map[peer_id]].presence]
	elif peer_id < 0:
		# Everyone but -peer_id; an empty list would send to all.
		for other_peer_id: int in _id_map:
			if other_peer_id != -peer_id and other_peer_id != _my_peer_id:
				presences.append(_users[_id_map[other_peer_id]].presence)
		if presences.is_empty():
			return
	_log_error(await socket.send_match_state_async(match_id, rpc_op_code, buffer, true, presences), "send an RPC")


class User:
	extends RefCounted
	var presence: NakamaRtTypes.UserPresence
	var peer_id := 0


	func _init(p_presence: NakamaRtTypes.UserPresence) -> void:
		presence = p_presence

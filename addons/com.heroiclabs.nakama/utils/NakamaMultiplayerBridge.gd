extends RefCounted
class_name NakamaMultiplayerBridge

enum MatchState {
	DISCONNECTED,
	JOINING,
	CONNECTED,
	SOCKET_CLOSED,
}

enum MetaMessageType {
	CLAIM_HOST,
	ASSIGN_PEER_ID,
}

# Read-only variables.
var _nakama_socket: NakamaSocket
var nakama_socket: NakamaSocket:
	get: return _nakama_socket
	set(_v): pass
var _match_state: int = MatchState.DISCONNECTED
var match_state: int:
	get: return _match_state
	set(_v): pass
var _match_id := ''
var match_id: String:
	get: return _match_id
	set(_v): pass
var _multiplayer_peer: NakamaMultiplayerPeer = NakamaMultiplayerPeer.new()
var multiplayer_peer: NakamaMultiplayerPeer:
	get: return _multiplayer_peer
	set(_v): pass

# Configuration that can be set by the developer.
var meta_op_code: int = 9001
var rpc_op_code: int = 9002

# Internal variables.
var _my_session_id: String
var _my_peer_id: int = 0
var _id_map := {}
var _users := {}
var _matchmaker_ticket := ''

class User extends RefCounted:
	var presence
	var peer_id: int = 0

	func _init(p_presence) -> void:
		presence = p_presence

signal match_join_error (exception)
signal match_joined ()

func _set_readonly(_value) -> void:
	pass

func _init(p_nakama_socket: NakamaSocket) -> void:
	_nakama_socket = p_nakama_socket
	_nakama_socket.received_match_presence.connect(self._on_nakama_socket_received_match_presence)
	_nakama_socket.received_matchmaker_matched.connect(self._on_nakama_socket_received_matchmaker_matched)
	_nakama_socket.received_match_state.connect(self._on_nakama_socket_received_match_state)
	_nakama_socket.closed.connect(self._on_nakama_socket_closed)

	_multiplayer_peer.packet_generated.connect(self._on_multiplayer_peer_packet_generated)
	_multiplayer_peer.set_connection_status(MultiplayerPeer.CONNECTION_CONNECTING)

func create_match() -> void:
	if _match_state != MatchState.DISCONNECTED:
		push_error("Cannot create match when state is %s" % MatchState.keys()[_match_state])
		return

	_match_state = MatchState.JOINING
	multiplayer_peer.set_connection_status(MultiplayerPeer.CONNECTION_CONNECTING)

	var res = await _nakama_socket.create_match_async()
	if res.is_exception():
		match_join_error.emit(res.get_exception())
		leave()
		return

	_setup_match(res)
	_setup_host()

func join_match(p_match_id: String) -> void:
	if _match_state != MatchState.DISCONNECTED:
		push_error("Cannot join match when state is %s" % MatchState.keys()[_match_state])
		return

	_match_state = MatchState.JOINING
	multiplayer_peer.set_connection_status(MultiplayerPeer.CONNECTION_CONNECTING)

	var res = await _nakama_socket.join_match_async(p_match_id)
	if res.is_exception():
		match_join_error.emit(res.get_exception())
		leave()
		return

	_setup_match(res)

func join_named_match(_match_name: String) -> void:
	if _match_state != MatchState.DISCONNECTED:
		push_error("Cannot join match when state is %s" % MatchState.keys()[_match_state])
		return

	_match_state = MatchState.JOINING
	multiplayer_peer.set_connection_status(MultiplayerPeer.CONNECTION_CONNECTING)

	var res = await _nakama_socket.create_match_async(_match_name)
	if res.is_exception():
		match_join_error.emit(res.get_exception())
		leave()
		return

	_setup_match(res)
	if res.size == 0 or (res.size == 1 and res.presences.size() == 0):
		_setup_host()

func start_matchmaking(ticket) -> void:
	if _match_state != MatchState.DISCONNECTED:
		push_error("Cannot start matchmaking when state is %s" % MatchState.keys()[_match_state])
		return
	if ticket.is_exception():
		push_error("Ticket with exception passed into start_matchmaking()")
		return

	_match_state = MatchState.JOINING
	multiplayer_peer.set_connection_status(MultiplayerPeer.CONNECTION_CONNECTING)

	_matchmaker_ticket = ticket.ticket

func _on_nakama_socket_received_matchmaker_matched(matchmaker_matched) -> void:
	if _matchmaker_ticket != matchmaker_matched.ticket:
		return

	# Get a list of sorted session ids.
	var session_ids := []
	for matchmaker_user in matchmaker_matched.users:
		session_ids.append(matchmaker_user.presence.session_id)
	session_ids.sort()

	var res = await _nakama_socket.join_matched_async(matchmaker_matched)
	if res.is_exception():
		match_join_error.emit(res.get_exception())
		leave()
		return

	_setup_match(res)

	# If our session is the first alphabetically, then we'll be the host.
	if _my_session_id == session_ids[0]:
		_setup_host()

		# Add all of the existing peers.
		for presence in res.presences:
			if presence.session_id != _my_session_id:
				_host_add_peer(presence)

func _on_nakama_socket_closed() -> void:
	match_state = MatchState.SOCKET_CLOSED
	_cleanup()

func get_user_presence_for_peer(peer_id: int) -> NakamaRTAPI.UserPresence:
	var session_id = _id_map.get(peer_id)
	if session_id == null:
		return null
	var user = _users.get(session_id)
	if user == null:
		return null
	return user.presence

func leave() -> void:
	if _match_state == MatchState.DISCONNECTED:
		return
	_match_state = MatchState.DISCONNECTED

	if _match_id:
		await _nakama_socket.leave_match_async(_match_id)
	if _matchmaker_ticket:
		await _nakama_socket.remove_matchmaker_async(_matchmaker_ticket)

	_cleanup()

func _cleanup() -> void:
	for peer_id in _id_map:
		multiplayer_peer.peer_disconnected.emit(peer_id)

	_match_id = ''
	_matchmaker_ticket = ''
	_my_session_id = ''
	_my_peer_id = 0
	_id_map.clear()
	_users.clear()

	_multiplayer_peer.set_connection_status(MultiplayerPeer.CONNECTION_DISCONNECTED)

func _setup_match(res) -> void:
	_match_id = res.match_id
	_my_session_id = res.self_user.session_id

	_users[_my_session_id] = User.new(res.self_user)

	for presence in res.presences:
		if not _users.has(presence.session_id):
			_users[presence.session_id] = User.new(presence)

func _setup_host() -> void:
	# Claim id 1 and start the match.
	_my_peer_id = 1
	_map_id_to_session(1, _my_session_id)
	_match_state = MatchState.CONNECTED
	_multiplayer_peer.initialize(_my_peer_id)
	match_joined.emit()

func _generate_id(session_id: String) -> int:
	# Peer ids can only be positive 32-bit signed integers.
	var peer_id: int = session_id.hash() & 0x7FFFFFFF

	# If this peer id is already taken, try to find another.
	while peer_id <= 1 or _id_map.has(peer_id):
		peer_id += 1
		if peer_id > 0x7FFFFFFF or peer_id <= 0:
			peer_id = randi() & 0x7FFFFFFF

	return peer_id

func _map_id_to_session(peer_id: int, session_id: String) -> void:
	_id_map[peer_id] = session_id
	_users[session_id].peer_id = peer_id

func _host_add_peer(presence) -> void:
	var peer_id = _generate_id(presence.session_id)
	_map_id_to_session(peer_id, presence.session_id)

	# Tell them we are the host.
	_nakama_socket.send_match_state_async(_match_id, meta_op_code, JSON.stringify({
		type = MetaMessageType.CLAIM_HOST,
	}), [presence])

	# Tell them about all the other connected peers.
	for other_peer_id in _id_map:
		var other_session_id = _id_map[other_peer_id]
		if other_session_id == presence.session_id or other_session_id == _my_session_id:
			continue
		_nakama_socket.send_match_state_async(_match_id, meta_op_code, JSON.stringify({
			type = MetaMessageType.ASSIGN_PEER_ID,
			session_id = other_session_id,
			peer_id = other_peer_id,
		}), [presence])

	# Assign them a peer_id (tell everyone about it).
	_nakama_socket.send_match_state_async(_match_id, meta_op_code, JSON.stringify({
		type = MetaMessageType.ASSIGN_PEER_ID,
		session_id = presence.session_id,
		peer_id = peer_id,
	}))

	_multiplayer_peer.peer_connected.emit(peer_id)

func _on_nakama_socket_received_match_presence(event) -> void:
	if _match_state == MatchState.DISCONNECTED:
		return
	if event.match_id != _match_id:
		return

	for presence in event.joins:
		if not _users.has(presence.session_id):
			_users[presence.session_id] = User.new(presence)

		# If we are the host, and they don't yet have a peer id, then let's
		# generate a new id for them and send all the necessary messages.
		if _my_peer_id == 1 and _users[presence.session_id].peer_id == 0:
			_host_add_peer(presence)

	for presence in event.leaves:
		if not _users.has(presence.session_id):
			continue

		var peer_id = _users[presence.session_id].peer_id

		_multiplayer_peer.peer_disconnected.emit(peer_id)

		_users.erase(presence.session_id)
		_id_map.erase(peer_id)

func _parse_json(data: String):
	var json = JSON.new()
	if json.parse(data) != OK:
		return null
	var content = json.get_data()
	if not content is Dictionary:
		return null
	return content

func _on_nakama_socket_received_match_state(data) -> void:
	if _match_state == MatchState.DISCONNECTED:
		return
	if data.match_id != _match_id:
		return

	if data.op_code == meta_op_code:
		var content = _parse_json(data.data)
		if content == null:
			return
		var type = content['type']
		#print ("RECEIVED: ", content)

		if type == MetaMessageType.CLAIM_HOST:
			if _id_map.has(1):
				# @todo Can we mediate this dispute?
				push_error("User %s claiming to be host, when user %s has already claimed it" % [data.presence.session_id, _id_map[1]])
			else:
				_map_id_to_session(1, data.presence.session_id)
			return

		# Ensure that any meta messages are coming from the host!
		if data.presence.session_id != _id_map[1]:
			push_error("Received meta message from user %s who isn't the host: %s" % [data.presence.session_id, content])
			return

		if type == MetaMessageType.ASSIGN_PEER_ID:
			var session_id = content['session_id']
			var peer_id = content['peer_id']

			if _users.has(session_id) and _users[session_id].peer_id != 0:
				push_error("Attempting to assign peer id %s to %s which already has id %s" % [
					peer_id,
					session_id,
					_users[session_id].peer_id,
				])
				return

			_map_id_to_session(peer_id, session_id)

			if _my_session_id == session_id:
				_match_state = MatchState.CONNECTED
				_multiplayer_peer.initialize(peer_id)
				_multiplayer_peer.set_connection_status(MultiplayerPeer.CONNECTION_CONNECTED)
				match_joined.emit()
				_multiplayer_peer.peer_connected.emit(1)
			else:
				_multiplayer_peer.peer_connected.emit(peer_id)
		else:
			_nakama_socket.logger.error("Received meta message with unknown type: %s" % type)
	elif data.op_code == rpc_op_code:
		var from_session_id: String = data.presence.session_id
		if not _users.has(from_session_id) or _users[from_session_id].peer_id == 0:
			push_error("Received RPC from %s which isn't assigned a peer id" % data.presence.session_id)
			return
		var from_peer_id = _users[from_session_id].peer_id
		_multiplayer_peer.deliver_packet(data.binary_data, from_peer_id)

func _on_multiplayer_peer_packet_generated(peer_id: int, buffer: PackedByteArray) -> void:
	if match_state == MatchState.CONNECTED:
		var target_presences = null
		if peer_id > 0:
			if not _id_map.has(peer_id):
				push_error("Attempting to send RPC to unknown peer id: %s" % peer_id)
				return
			target_presences = [ _users[_id_map[peer_id]].presence ]
		_nakama_socket.send_match_state_raw_async(_match_id, rpc_op_code, buffer, target_presences)
	else:
		push_error("RPC sent while the NakamaMultiplayerBridge isn't connected!")

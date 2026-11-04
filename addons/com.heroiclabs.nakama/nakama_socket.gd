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

class_name NakamaSocket
extends RefCounted
## Realtime connection to Nakama: chat, matches, parties, the matchmaker, notifications, and
## status. It stays open until close() or the server ends it.

signal connected
## code: WebSocket close code (1000 normal or close(), 1009 message too big, -1 connection dropped).
## reason: the closing side's text, often empty.
signal closed(code: int, reason: String)
signal received_error(error: NakamaError)
signal received_channel_message(message: NakamaTypes.ChannelMessage)
signal received_channel_presence(event: NakamaSocketTypes.ChannelPresenceEvent)
signal received_matchmaker_matched(matched: NakamaSocketTypes.MatchmakerMatched)
signal received_match_presence(event: NakamaSocketTypes.MatchPresenceEvent)
signal received_match_state(state: NakamaSocketTypes.MatchData)
signal received_notification(notification: NakamaTypes.Notification)
signal received_party(party: NakamaSocketTypes.Party)
signal received_party_close(close: NakamaSocketTypes.PartyClose)
signal received_party_data(data: NakamaSocketTypes.PartyData)
signal received_party_join_request(request: NakamaSocketTypes.PartyJoinRequest)
signal received_party_leader(leader: NakamaSocketTypes.PartyLeader)
signal received_party_matchmaker_ticket(ticket: NakamaSocketTypes.PartyMatchmakerTicket)
signal received_party_presence(event: NakamaSocketTypes.PartyPresenceEvent)
signal received_party_update(update: NakamaSocketTypes.PartyUpdate)
signal received_status_presence(event: NakamaSocketTypes.StatusPresenceEvent)
signal received_stream_presence(event: NakamaSocketTypes.StreamPresenceEvent)
signal received_stream_state(state: NakamaSocketTypes.StreamData)

const DEFAULT_SEND_TIMEOUT_SEC := 10
const DEFAULT_CONNECT_TIMEOUT_SEC := 30
## Ping interval; no pong by the next ping closes the socket.
const KEEP_ALIVE_INTERVAL_SEC := 15

## What the socket prints; see Nakama.log_level. NakamaSocket.from copies the client's.
var log_level := Nakama.LogLevel.WARNING
var _adapter: WebSocketPeer
var _base_url: String
## Pending replies by collation ID; the envelope once it arrives.
var _responses: Dictionary
## Collation IDs of match joins and creates that timed out: if the server still answers, the match is left.
var _timed_out_joins: Dictionary
var _send_timeout_sec: int
var _next_cid: int
## Bumped on connect and close, stopping stale loops and requests.
var _connection: int
## The _connection whose receive loop runs; while it is current, closed has not been emitted for it yet.
var _live_connection := -1


static func from(client: Nakama) -> NakamaSocket:
	var socket_scheme := "ws" if client.scheme.to_lower() == "http" else "wss"
	var socket := NakamaSocket.new(socket_scheme, client.host, client.port)
	socket.log_level = client.log_level
	return socket


static func _new_adapter() -> WebSocketPeer:
	var adapter := WebSocketPeer.new()
	adapter.heartbeat_interval = KEEP_ALIVE_INTERVAL_SEC
	# The 64 KB default closes the socket on bigger server messages.
	adapter.inbound_buffer_size = 256 * 1024
	return adapter


## Polls a closing adapter until its close handshake finishes, for at most 5 s.
static func _finish_close(adapter: WebSocketPeer) -> void:
	var deadline := Time.get_ticks_msec() + 5000
	while adapter.get_ready_state() != WebSocketPeer.STATE_CLOSED and Time.get_ticks_msec() < deadline:
		adapter.poll()
		await (Engine.get_main_loop() as SceneTree).process_frame


## Polls every frame until the connection ends, dispatching messages; stops silently once replaced.
## Static so its argument keeps the socket alive while running.
static func _receive_loop(socket: NakamaSocket, connection: int) -> void:
	while connection == socket._connection:
		socket._adapter.poll()
		# A handler may close or reconnect the socket, so check again before each message.
		while connection == socket._connection and socket._adapter.get_available_packet_count() > 0:
			socket._process_message(socket._adapter.get_packet().get_string_from_utf8())
		if connection == socket._connection and socket._adapter.get_ready_state() == WebSocketPeer.STATE_CLOSED:
			socket._connection += 1
			# The server took this player out of every match, and no late reply can still arrive.
			socket._timed_out_joins.clear()
			socket._log(Nakama.LogLevel.WARNING, "connection lost: %d %s" % [socket._adapter.get_close_code(), socket._adapter.get_close_reason()])
			socket.closed.emit(socket._adapter.get_close_code(), socket._adapter.get_close_reason())
			break
		await (Engine.get_main_loop() as SceneTree).process_frame
	# One more frame so pending requests see the end before the socket can be freed.
	await (Engine.get_main_loop() as SceneTree).process_frame


func _init(p_scheme: String, p_host: String, p_port: int,
		p_send_timeout_sec: int = DEFAULT_SEND_TIMEOUT_SEC) -> void:
	_adapter = _new_adapter()
	_base_url = "%s://%s:%d" % [p_scheme, p_host, p_port]
	_responses = {}
	_send_timeout_sec = p_send_timeout_sec


## Accept a party member's request to join the party.
func accept_party_member_async(party_id: String,
		presence: NakamaSocketTypes.UserPresence) -> NakamaResult:
	var request := NakamaSocketTypes.PartyAccept.new(party_id, presence)
	var request_model := NakamaSocketAPI.accept_party_member(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Join the matchmaker pool and search for opponents on the server.
func add_matchmaker_async(min_count: int = 2, max_count: int = 8, query: String = "*",
		count_multiple: Variant = null, string_properties: Dictionary = {},
		numeric_properties: Dictionary = {}) -> NakamaResult:
	var request := NakamaSocketTypes.MatchmakerAdd.new(min_count, max_count, query, string_properties,
			numeric_properties, count_multiple)
	var request_model := NakamaSocketAPI.add_matchmaker(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaSocketTypes.MatchmakerTicket.from_json(result.value)
	return result


## Begin matchmaking as a party.
func add_matchmaker_party_async(party_id: String, min_count: int = 2, max_count: int = 8,
		query: String = "*", count_multiple: Variant = null, string_properties: Dictionary = {},
		numeric_properties: Dictionary = {}) -> NakamaResult:
	var request := NakamaSocketTypes.PartyMatchmakerAdd.new(party_id, min_count, max_count, query,
			string_properties, numeric_properties, count_multiple)
	var request_model := NakamaSocketAPI.add_matchmaker_party(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaSocketTypes.PartyMatchmakerTicket.from_json(result.value)
	return result


## Closes the connection and fails pending requests at once; emits closed if the socket was open.
func close() -> void:
	# Not is_open(): if the server is closing the socket this frame, the state is CLOSING, and bumping _connection
	# below stops the receive loop before it reports the close.
	var was_live := _live_connection == _connection
	_connection += 1
	_timed_out_joins.clear()
	# A fresh adapter, so a reconnect does not wait for the old one's closing handshake.
	var closing := _adapter
	_adapter = _new_adapter()
	closing.close()
	# No await: finishes on its own.
	_finish_close(closing)
	if was_live:
		_log(Nakama.LogLevel.INFO, "closed by client")
		closed.emit(1000, "closed by client")


## End a party, kicking all party members and closing it.
func close_party_async(party_id: String) -> NakamaResult:
	var request := NakamaSocketTypes.PartyClose.new(party_id)
	var request_model := NakamaSocketAPI.close_party(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Connects as session's user; appear_online shows them online to their followers.
## Returns null on success, otherwise why the connection failed.
## Already open: returns null and keeps the connection.
## Already connecting: waits for that attempt and returns its outcome.
## To connect as a new user, first close() the previous socket.
func connect_async(session: NakamaSession, appear_online: bool = false, lang_tag: String = "en",
		connect_timeout_sec: int = DEFAULT_CONNECT_TIMEOUT_SEC) -> NakamaError:
	if is_open():
		return null
	if _adapter.get_ready_state() == WebSocketPeer.STATE_CONNECTING:
		var pending := _connection
		while pending == _connection and _adapter.get_ready_state() == WebSocketPeer.STATE_CONNECTING:
			await (Engine.get_main_loop() as SceneTree).process_frame
		if pending == _connection and is_open():
			return null
		return NakamaError.new(0, NakamaError.UNAVAILABLE, "the connection attempt in progress to %s failed" % _base_url)
	close()
	# A failed handshake has no status, so a 401 looks like an outage; check expiry first.
	if session.has_expired():
		return NakamaError.new(0, NakamaError.UNAUTHENTICATED, "session expired; refresh it or log in again")
	var connection := _connection
	var url := "%s/ws?lang=%s&status=%s&token=%s" % [_base_url, lang_tag.uri_encode(),
			str(appear_online).to_lower(), session.token.uri_encode()]
	var err := _adapter.connect_to_url(url)
	if err != OK:
		return NakamaError.new(0, NakamaError.UNAVAILABLE, "cannot connect to %s: %s" % [_base_url, error_string(err)])
	var deadline := Time.get_ticks_msec() + connect_timeout_sec * 1000
	while _adapter.get_ready_state() == WebSocketPeer.STATE_CONNECTING:
		if connection != _connection:
			return NakamaError.new(0, NakamaError.UNAVAILABLE, "closed while connecting to %s" % _base_url)
		if Time.get_ticks_msec() > deadline:
			close()
			return NakamaError.new(0, NakamaError.DEADLINE_EXCEEDED, "connecting to %s timed out after %d s" % [_base_url, connect_timeout_sec])
		_adapter.poll()
		await (Engine.get_main_loop() as SceneTree).process_frame
	if _adapter.get_ready_state() != WebSocketPeer.STATE_OPEN:
		_log(Nakama.LogLevel.INFO, "cannot connect to %s: %s" % [_base_url, _adapter.get_close_reason()])
		return NakamaError.new(0, NakamaError.UNAVAILABLE, "cannot connect to %s: %s" % [_base_url, _adapter.get_close_reason()])
	_log(Nakama.LogLevel.INFO, "connected to %s" % _base_url)
	_live_connection = connection
	# Before the loop: its first poll can already see the server close the socket and emit closed.
	connected.emit()
	# No await: runs until the connection ends. If a connected handler closed or reconnected, it stops at once.
	_receive_loop(self, connection)
	return null


## Create a multiplayer match on the server.
func create_match_async(name: String = "") -> NakamaResult:
	var request := NakamaSocketTypes.MatchCreate.new(name)
	var request_model := NakamaSocketAPI.create_match(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaSocketTypes.Match.from_json(result.value)
	return result


## Create a party.
func create_party_async(open: bool = false, max_size: int = 0, label: String = "",
		hidden: bool = false) -> NakamaResult:
	var request := NakamaSocketTypes.PartyCreate.new(open, max_size, label, hidden)
	var request_model := NakamaSocketAPI.create_party(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaSocketTypes.Party.from_json(result.value)
	return result


## Subscribe to one or more users for their status updates.
func follow_users_async(user_ids: Array[String] = [],
		usernames: Array[String] = []) -> NakamaResult:
	var request := NakamaSocketTypes.StatusFollow.new(user_ids, usernames)
	var request_model := NakamaSocketAPI.follow_users(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaSocketTypes.Status.from_json(result.value)
	return result


func is_connecting() -> bool:
	return _adapter.get_ready_state() == WebSocketPeer.STATE_CONNECTING


func is_open() -> bool:
	return _adapter.get_ready_state() == WebSocketPeer.STATE_OPEN


## Join a chat channel on the server.
func join_chat_async(target: String, type: int, persistence: Variant = null,
		hidden: Variant = null) -> NakamaResult:
	var request := NakamaSocketTypes.ChannelJoin.new(target, type, persistence, hidden)
	var request_model := NakamaSocketAPI.join_chat(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaSocketTypes.Channel.from_json(result.value)
	return result


## Join a multiplayer match by its ID or a matchmaker token.
func join_match_async(match_id: Variant = null, token: Variant = null,
		metadata: Dictionary = {}) -> NakamaResult:
	var request := NakamaSocketTypes.MatchJoin.new(match_id, token, metadata)
	var request_model := NakamaSocketAPI.join_match(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaSocketTypes.Match.from_json(result.value)
	return result


## Joins the match the matchmaker found: by match_id for an authoritative match, else by token.
func join_matched_async(matched: NakamaSocketTypes.MatchmakerMatched,
		metadata: Dictionary = {}) -> NakamaResult:
	if matched.match_id != null and matched.match_id != "":
		return await join_match_async(matched.match_id, null, metadata)
	return await join_match_async(null, matched.token, metadata)


## Join a party, or request to join if the party is not open.
func join_party_async(party_id: String) -> NakamaResult:
	var request := NakamaSocketTypes.PartyJoin.new(party_id)
	var request_model := NakamaSocketAPI.join_party(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Leave a chat channel on the server.
func leave_chat_async(channel_id: String) -> NakamaResult:
	var request := NakamaSocketTypes.ChannelLeave.new(channel_id)
	var request_model := NakamaSocketAPI.leave_chat(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Leave a multiplayer match on the server.
func leave_match_async(match_id: String) -> NakamaResult:
	var request := NakamaSocketTypes.MatchLeave.new(match_id)
	var request_model := NakamaSocketAPI.leave_match(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Leave the party.
func leave_party_async(party_id: String) -> NakamaResult:
	var request := NakamaSocketTypes.PartyLeave.new(party_id)
	var request_model := NakamaSocketAPI.leave_party(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Request a list of pending join requests for a party.
func list_party_join_requests_async(party_id: String) -> NakamaResult:
	var request := NakamaSocketTypes.PartyJoinRequestList.new(party_id)
	var request_model := NakamaSocketAPI.list_party_join_requests(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaSocketTypes.PartyJoinRequest.from_json(result.value)
	return result


## Promote a new party leader.
func promote_party_member_async(party_id: String,
		presence: NakamaSocketTypes.UserPresence) -> NakamaResult:
	var request := NakamaSocketTypes.PartyPromote.new(party_id, presence)
	var request_model := NakamaSocketAPI.promote_party_member(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Remove a chat message from a chat channel on the server.
func remove_chat_message_async(channel_id: String, message_id: String) -> NakamaResult:
	var request := NakamaSocketTypes.ChannelMessageRemove.new(channel_id, message_id)
	var request_model := NakamaSocketAPI.remove_chat_message(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaSocketTypes.ChannelMessageAck.from_json(result.value)
	return result


## Leave the matchmaker pool using a ticket.
func remove_matchmaker_async(ticket: String) -> NakamaResult:
	var request := NakamaSocketTypes.MatchmakerRemove.new(ticket)
	var request_model := NakamaSocketAPI.remove_matchmaker(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Cancel a party matchmaking process using a ticket.
func remove_matchmaker_party_async(party_id: String, ticket: String) -> NakamaResult:
	var request := NakamaSocketTypes.PartyMatchmakerRemove.new(party_id, ticket)
	var request_model := NakamaSocketAPI.remove_matchmaker_party(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Kick a party member, or decline a request to join.
func remove_party_member_async(party_id: String,
		presence: NakamaSocketTypes.UserPresence) -> NakamaResult:
	var request := NakamaSocketTypes.PartyRemove.new(party_id, presence)
	var request_model := NakamaSocketAPI.remove_party_member(request)
	var result: NakamaResult = await _send(request_model)
	return result


## [param payload]: A String is sent as is, bytes as UTF-8 text, anything else as JSON.
func rpc_async(id: String, payload: Variant = "") -> NakamaResult:
	var request := NakamaTypes.Rpc.new(id)
	match typeof(payload):
		TYPE_STRING:
			request.payload = payload
		TYPE_PACKED_BYTE_ARRAY:
			var bytes: PackedByteArray = payload
			request.payload = bytes.get_string_from_utf8()
		_:
			request.payload = JSON.stringify(payload)
	var request_model := NakamaSocketAPI.rpc(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaTypes.Rpc.from_json(result.value)
	return result


## Send input to a multiplayer match on the server. The server sends no reply.
## [param data]: A String is sent as its UTF-8 bytes.
func send_match_state_async(match_id: String, op_code: int, data: Variant, reliable: bool = false,
		presences: Array[NakamaSocketTypes.UserPresence] = []) -> NakamaResult:
	var bytes: PackedByteArray = str(data).to_utf8_buffer() if data is String else data
	var request := NakamaSocketTypes.MatchDataSend.new(match_id, op_code, bytes, presences, reliable)
	var request_model := NakamaSocketAPI.send_match_state(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Send data to a party.
## [param data]: A String is sent as its UTF-8 bytes.
func send_party_data_async(party_id: String, op_code: int, data: Variant) -> NakamaResult:
	var bytes: PackedByteArray = str(data).to_utf8_buffer() if data is String else data
	var request := NakamaSocketTypes.PartyDataSend.new(party_id, op_code, bytes)
	var request_model := NakamaSocketAPI.send_party_data(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Unsubscribe from one or more users' status updates.
func unfollow_users_async(user_ids: Array[String]) -> NakamaResult:
	var request := NakamaSocketTypes.StatusUnfollow.new(user_ids)
	var request_model := NakamaSocketAPI.unfollow_users(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Update a chat message on a chat channel on the server.
## [param content]: A String is sent as is, anything else as JSON.
func update_chat_message_async(channel_id: String, message_id: String,
		content: Variant) -> NakamaResult:
	var text: String = content if content is String else JSON.stringify(content)
	var request := NakamaSocketTypes.ChannelMessageUpdate.new(channel_id, message_id, text)
	var request_model := NakamaSocketAPI.update_chat_message(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaSocketTypes.ChannelMessageAck.from_json(result.value)
	return result


## Update the party label and whether it's open or closed.
func update_party_async(party_id: String, label: String = "", open: bool = false,
		hidden: bool = false) -> NakamaResult:
	var request := NakamaSocketTypes.PartyUpdate.new(party_id, label, open, hidden)
	var request_model := NakamaSocketAPI.update_party(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaSocketTypes.PartyUpdate.from_json(result.value)
	return result


## Update the current user's online status.
func update_status_async(status: Variant = null) -> NakamaResult:
	var request := NakamaSocketTypes.StatusUpdate.new(status)
	var request_model := NakamaSocketAPI.update_status(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Send a chat message to a chat channel on the server.
## [param content]: A String is sent as is, anything else as JSON.
func write_chat_message_async(channel_id: String, content: Variant) -> NakamaResult:
	var text: String = content if content is String else JSON.stringify(content)
	var request := NakamaSocketTypes.ChannelMessageSend.new(channel_id, text)
	var request_model := NakamaSocketAPI.write_chat_message(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaSocketTypes.ChannelMessageAck.from_json(result.value)
	return result


func _log(level: Nakama.LogLevel, message: String) -> void:
	if level > log_level:
		return
	match level:
		Nakama.LogLevel.ERROR: push_error("NakamaSocket: " + message)
		Nakama.LogLevel.WARNING: push_warning("NakamaSocket: " + message)
		_: print("NakamaSocket: " + message)


func _process_message(text: String) -> void:
	var json := JSON.new()
	var parsed: Variant = json.data if json.parse(text) == OK else null
	if not parsed is Dictionary:
		received_error.emit(NakamaError.new(0, NakamaError.UNKNOWN, "unreadable socket message: " + text))
		return
	var envelope: Dictionary = parsed
	var cid: String = envelope.get("cid", "")
	if cid != "":
		if _responses.has(cid):
			_responses[cid] = envelope
		elif _timed_out_joins.has(cid):
			_timed_out_joins.erase(cid)
			var joined: Dictionary = envelope.get("match", {})
			var joined_id: String = joined.get("match_id", "")
			if joined_id != "":
				# The caller gave up, but the server let this player in: leave, or the others see a ghost.
				_log(Nakama.LogLevel.WARNING, "left match %s, whose join had timed out" % joined_id)
				# No await: finishes on its own.
				leave_match_async(joined_id)
		return
	for key: String in envelope:
		var data: Variant = envelope[key]
		match key:
			"error":
				var error: Dictionary = data
				received_error.emit(NakamaError.from_socket(error))
			"channel_message":
				received_channel_message.emit(NakamaTypes.ChannelMessage.from_json(data))
			"channel_presence_event":
				received_channel_presence.emit(NakamaSocketTypes.ChannelPresenceEvent.from_json(data))
			"matchmaker_matched":
				received_matchmaker_matched.emit(NakamaSocketTypes.MatchmakerMatched.from_json(data))
			"match_presence_event":
				received_match_presence.emit(NakamaSocketTypes.MatchPresenceEvent.from_json(data))
			"match_data":
				received_match_state.emit(NakamaSocketTypes.MatchData.from_json(data))
			"notifications":
				for note: NakamaTypes.Notification in NakamaSocketTypes.Notifications.from_json(data).notifications:
					received_notification.emit(note)
			"party":
				received_party.emit(NakamaSocketTypes.Party.from_json(data))
			"party_close":
				received_party_close.emit(NakamaSocketTypes.PartyClose.from_json(data))
			"party_data":
				received_party_data.emit(NakamaSocketTypes.PartyData.from_json(data))
			"party_join_request":
				received_party_join_request.emit(NakamaSocketTypes.PartyJoinRequest.from_json(data))
			"party_leader":
				received_party_leader.emit(NakamaSocketTypes.PartyLeader.from_json(data))
			"party_matchmaker_ticket":
				received_party_matchmaker_ticket.emit(NakamaSocketTypes.PartyMatchmakerTicket.from_json(data))
			"party_presence_event":
				received_party_presence.emit(NakamaSocketTypes.PartyPresenceEvent.from_json(data))
			"party_update":
				received_party_update.emit(NakamaSocketTypes.PartyUpdate.from_json(data))
			"status_presence_event":
				received_status_presence.emit(NakamaSocketTypes.StatusPresenceEvent.from_json(data))
			"stream_presence_event":
				received_stream_presence.emit(NakamaSocketTypes.StreamPresenceEvent.from_json(data))
			"stream_data":
				received_stream_state.emit(NakamaSocketTypes.StreamData.from_json(data))
			_:
				received_error.emit(NakamaError.new(0, NakamaError.UNKNOWN, "unknown socket message: " + key))


## Value is the reply's message, or null for an acknowledgement.
func _send(request: NakamaSocketAPI.SocketRequestModel) -> NakamaResult:
	_log(Nakama.LogLevel.DEBUG, "send %s" % request.key)
	if not is_open():
		return NakamaResult.new(null, NakamaError.new(0, NakamaError.UNAVAILABLE, "socket is not connected"))
	if not request.expects_reply:
		var send_err := _adapter.send_text('{"%s":%s}' % [request.key, request.body])
		if send_err != OK:
			return NakamaResult.new(null, NakamaError.new(0, NakamaError.UNAVAILABLE, "send failed: %s" % error_string(send_err)))
		return NakamaResult.new()

	var connection := _connection
	_next_cid += 1
	var cid := str(_next_cid)
	_responses[cid] = null
	var err := _adapter.send_text('{"cid":"%s","%s":%s}' % [cid, request.key, request.body])
	if err != OK:
		_responses.erase(cid)
		return NakamaResult.new(null, NakamaError.new(0, NakamaError.UNAVAILABLE, "send failed: %s" % error_string(err)))
	var deadline := Time.get_ticks_msec() + _send_timeout_sec * 1000
	while _responses[cid] == null:
		if connection != _connection:
			_responses.erase(cid)
			return NakamaResult.new(null, NakamaError.new(0, NakamaError.UNAVAILABLE, "socket closed before %s was answered" % request.key))
		if Time.get_ticks_msec() > deadline:
			_responses.erase(cid)
			if request.key in ["match_join", "match_create"]:
				_timed_out_joins[cid] = true
			return NakamaResult.new(null, NakamaError.new(0, NakamaError.DEADLINE_EXCEEDED, "%s timed out after %d s" % [request.key, _send_timeout_sec]))
		await (Engine.get_main_loop() as SceneTree).process_frame
	var envelope: Dictionary = _responses[cid]
	_responses.erase(cid)
	if envelope.has("error"):
		var error: Dictionary = envelope["error"]
		return NakamaResult.new(null, NakamaError.from_socket(error))
	# A reply holds the cid and at most one message.
	for key: String in envelope:
		if key != "cid":
			return NakamaResult.new(envelope[key])
	return NakamaResult.new()

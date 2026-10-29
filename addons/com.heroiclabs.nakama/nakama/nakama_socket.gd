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
signal received_channel_presence(event: NakamaRtTypes.ChannelPresenceEvent)
signal received_matchmaker_matched(matched: NakamaRtTypes.MatchmakerMatched)
signal received_match_presence(event: NakamaRtTypes.MatchPresenceEvent)
signal received_match_state(state: NakamaRtTypes.MatchData)
signal received_notification(notification: NakamaTypes.Notification)
signal received_party(party: NakamaRtTypes.Party)
signal received_party_close(close: NakamaRtTypes.PartyClose)
signal received_party_data(data: NakamaRtTypes.PartyData)
signal received_party_join_request(request: NakamaRtTypes.PartyJoinRequest)
signal received_party_leader(leader: NakamaRtTypes.PartyLeader)
signal received_party_matchmaker_ticket(ticket: NakamaRtTypes.PartyMatchmakerTicket)
signal received_party_presence(event: NakamaRtTypes.PartyPresenceEvent)
signal received_party_update(update: NakamaRtTypes.PartyUpdate)
signal received_status_presence(event: NakamaRtTypes.StatusPresenceEvent)
signal received_stream_presence(event: NakamaRtTypes.StreamPresenceEvent)
signal received_stream_state(state: NakamaRtTypes.StreamData)

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
var _send_timeout_sec: int
var _next_cid: int
## Bumped on connect and close, stopping stale loops and requests.
var _connection: int


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


## Polls a closed adapter until its closing handshake is done, which needs polling to finish, or for
## at most 5 s.
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
		presence: NakamaRtTypes.UserPresence) -> NakamaResult:
	var request := NakamaRtTypes.PartyAccept.new(party_id, presence)
	var request_model := NakamaSocketAPI.accept_party_member(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Join the matchmaker pool and search for opponents on the server.
func add_matchmaker_async(min_count: int = 2, max_count: int = 8, query: String = "*",
		count_multiple: Variant = null, string_properties: Dictionary = {},
		numeric_properties: Dictionary = {}) -> NakamaResult:
	var request := NakamaRtTypes.MatchmakerAdd.new(min_count, max_count, query, string_properties,
			numeric_properties, count_multiple)
	var request_model := NakamaSocketAPI.add_matchmaker(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaRtTypes.MatchmakerTicket.from_json(result.value)
	return result


## Begin matchmaking as a party.
func add_matchmaker_party_async(party_id: String, min_count: int = 2, max_count: int = 8,
		query: String = "*", count_multiple: Variant = null, string_properties: Dictionary = {},
		numeric_properties: Dictionary = {}) -> NakamaResult:
	var request := NakamaRtTypes.PartyMatchmakerAdd.new(party_id, min_count, max_count, query,
			string_properties, numeric_properties, count_multiple)
	var request_model := NakamaSocketAPI.add_matchmaker_party(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaRtTypes.PartyMatchmakerTicket.from_json(result.value)
	return result


## Closes the connection, emits closed and fails pending requests at once.
func close() -> void:
	var was_open := is_open()
	_connection += 1
	# A fresh adapter, so a reconnect does not wait for the old one's closing handshake.
	var closing := _adapter
	_adapter = _new_adapter()
	closing.close()
	# No await: finishes on its own
	_finish_close(closing)
	if was_open:
		_log(Nakama.LogLevel.INFO, "closed by client")
		closed.emit(1000, "closed by client")


## End a party, kicking all party members and closing it.
func close_party_async(party_id: String) -> NakamaResult:
	var request := NakamaRtTypes.PartyClose.new(party_id)
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
		return NakamaError.new(0, NakamaError.UNAUTHENTICATED, "session expired, refresh it or log in again")
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
	# No await: runs until the connection ends
	_receive_loop(self, connection)
	connected.emit()
	return null


## Create a multiplayer match on the server.
func create_match_async(name: String = "") -> NakamaResult:
	var request := NakamaRtTypes.MatchCreate.new(name)
	var request_model := NakamaSocketAPI.create_match(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaRtTypes.Match.from_json(result.value)
	return result


## Create a party.
func create_party_async(open: bool = false, max_size: int = 0, label: String = "",
		hidden: bool = false) -> NakamaResult:
	var request := NakamaRtTypes.PartyCreate.new(open, max_size, label, hidden)
	var request_model := NakamaSocketAPI.create_party(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaRtTypes.Party.from_json(result.value)
	return result


## Subscribe to one or more users for their status updates.
func follow_users_async(user_ids: Array[String] = [],
		usernames: Array[String] = []) -> NakamaResult:
	var request := NakamaRtTypes.StatusFollow.new(user_ids, usernames)
	var request_model := NakamaSocketAPI.follow_users(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaRtTypes.Status.from_json(result.value)
	return result


func is_connecting() -> bool:
	return _adapter.get_ready_state() == WebSocketPeer.STATE_CONNECTING


func is_open() -> bool:
	return _adapter.get_ready_state() == WebSocketPeer.STATE_OPEN


## Join a chat channel on the server.
func join_chat_async(target: String, type: int, persistence: Variant = null,
		hidden: Variant = null) -> NakamaResult:
	var request := NakamaRtTypes.ChannelJoin.new(target, type, persistence, hidden)
	var request_model := NakamaSocketAPI.join_chat(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaRtTypes.Channel.from_json(result.value)
	return result


## Join a multiplayer match by its ID or a matchmaker token.
func join_match_async(match_id: Variant = null, token: Variant = null,
		metadata: Dictionary = {}) -> NakamaResult:
	var request := NakamaRtTypes.MatchJoin.new(match_id, token, metadata)
	var request_model := NakamaSocketAPI.join_match(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaRtTypes.Match.from_json(result.value)
	return result


## Joins the match the matchmaker found by its match_id for a server match, else by its token.
func join_matched_async(matched: NakamaRtTypes.MatchmakerMatched,
		metadata: Dictionary = {}) -> NakamaResult:
	if matched.match_id != null and matched.match_id != "":
		return await join_match_async(matched.match_id, null, metadata)
	return await join_match_async(null, matched.token, metadata)


## Join a party, or request to join if the party is not open.
func join_party_async(party_id: String) -> NakamaResult:
	var request := NakamaRtTypes.PartyJoin.new(party_id)
	var request_model := NakamaSocketAPI.join_party(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Leave a chat channel on the server.
func leave_chat_async(channel_id: String) -> NakamaResult:
	var request := NakamaRtTypes.ChannelLeave.new(channel_id)
	var request_model := NakamaSocketAPI.leave_chat(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Leave a multiplayer match on the server.
func leave_match_async(match_id: String) -> NakamaResult:
	var request := NakamaRtTypes.MatchLeave.new(match_id)
	var request_model := NakamaSocketAPI.leave_match(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Leave the party.
func leave_party_async(party_id: String) -> NakamaResult:
	var request := NakamaRtTypes.PartyLeave.new(party_id)
	var request_model := NakamaSocketAPI.leave_party(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Request a list of pending join requests for a party.
func list_party_join_requests_async(party_id: String) -> NakamaResult:
	var request := NakamaRtTypes.PartyJoinRequestList.new(party_id)
	var request_model := NakamaSocketAPI.list_party_join_requests(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaRtTypes.PartyJoinRequest.from_json(result.value)
	return result


## Promote a new party leader.
func promote_party_member_async(party_id: String,
		presence: NakamaRtTypes.UserPresence) -> NakamaResult:
	var request := NakamaRtTypes.PartyPromote.new(party_id, presence)
	var request_model := NakamaSocketAPI.promote_party_member(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Remove a chat message from a chat channel on the server.
func remove_chat_message_async(channel_id: String, message_id: String) -> NakamaResult:
	var request := NakamaRtTypes.ChannelMessageRemove.new(channel_id, message_id)
	var request_model := NakamaSocketAPI.remove_chat_message(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaRtTypes.ChannelMessageAck.from_json(result.value)
	return result


## Leave the matchmaker pool using a ticket.
func remove_matchmaker_async(ticket: String) -> NakamaResult:
	var request := NakamaRtTypes.MatchmakerRemove.new(ticket)
	var request_model := NakamaSocketAPI.remove_matchmaker(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Cancel a party matchmaking process using a ticket.
func remove_matchmaker_party_async(party_id: String, ticket: String) -> NakamaResult:
	var request := NakamaRtTypes.PartyMatchmakerRemove.new(party_id, ticket)
	var request_model := NakamaSocketAPI.remove_matchmaker_party(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Kick a party member, or decline a request to join.
func remove_party_member_async(party_id: String,
		presence: NakamaRtTypes.UserPresence) -> NakamaResult:
	var request := NakamaRtTypes.PartyRemove.new(party_id, presence)
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
		presences: Array[NakamaRtTypes.UserPresence] = []) -> NakamaResult:
	var bytes: PackedByteArray = str(data).to_utf8_buffer() if data is String else data
	var request := NakamaRtTypes.MatchDataSend.new(match_id, op_code, bytes, presences, reliable)
	var request_model := NakamaSocketAPI.send_match_state(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Send data to a party.
## [param data]: A String is sent as its UTF-8 bytes.
func send_party_data_async(party_id: String, op_code: int, data: Variant) -> NakamaResult:
	var bytes: PackedByteArray = str(data).to_utf8_buffer() if data is String else data
	var request := NakamaRtTypes.PartyDataSend.new(party_id, op_code, bytes)
	var request_model := NakamaSocketAPI.send_party_data(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Unsubscribe from one or more users' status updates.
func unfollow_users_async(user_ids: Array[String]) -> NakamaResult:
	var request := NakamaRtTypes.StatusUnfollow.new(user_ids)
	var request_model := NakamaSocketAPI.unfollow_users(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Update a chat message on a chat channel on the server.
## [param content]: A String is sent as is, anything else as JSON.
func update_chat_message_async(channel_id: String, message_id: String,
		content: Variant) -> NakamaResult:
	var text: String = content if content is String else JSON.stringify(content)
	var request := NakamaRtTypes.ChannelMessageUpdate.new(channel_id, message_id, text)
	var request_model := NakamaSocketAPI.update_chat_message(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaRtTypes.ChannelMessageAck.from_json(result.value)
	return result


## Update the party label and whether it's open or closed.
func update_party_async(party_id: String, label: String = "", open: bool = false,
		hidden: bool = false) -> NakamaResult:
	var request := NakamaRtTypes.PartyUpdate.new(party_id, label, open, hidden)
	var request_model := NakamaSocketAPI.update_party(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaRtTypes.PartyUpdate.from_json(result.value)
	return result


## Update the current user's online status.
func update_status_async(status: Variant = null) -> NakamaResult:
	var request := NakamaRtTypes.StatusUpdate.new(status)
	var request_model := NakamaSocketAPI.update_status(request)
	var result: NakamaResult = await _send(request_model)
	return result


## Send a chat message to a chat channel on the server.
## [param content]: A String is sent as is, anything else as JSON.
func write_chat_message_async(channel_id: String, content: Variant) -> NakamaResult:
	var text: String = content if content is String else JSON.stringify(content)
	var request := NakamaRtTypes.ChannelMessageSend.new(channel_id, text)
	var request_model := NakamaSocketAPI.write_chat_message(request)
	var result: NakamaResult = await _send(request_model)
	if result.error == null and result.value != null:
		result.value = NakamaRtTypes.ChannelMessageAck.from_json(result.value)
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
				received_channel_presence.emit(NakamaRtTypes.ChannelPresenceEvent.from_json(data))
			"matchmaker_matched":
				received_matchmaker_matched.emit(NakamaRtTypes.MatchmakerMatched.from_json(data))
			"match_presence_event":
				received_match_presence.emit(NakamaRtTypes.MatchPresenceEvent.from_json(data))
			"match_data":
				received_match_state.emit(NakamaRtTypes.MatchData.from_json(data))
			"notifications":
				for note: NakamaTypes.Notification in NakamaRtTypes.Notifications.from_json(data).notifications:
					received_notification.emit(note)
			"party":
				received_party.emit(NakamaRtTypes.Party.from_json(data))
			"party_close":
				received_party_close.emit(NakamaRtTypes.PartyClose.from_json(data))
			"party_data":
				received_party_data.emit(NakamaRtTypes.PartyData.from_json(data))
			"party_join_request":
				received_party_join_request.emit(NakamaRtTypes.PartyJoinRequest.from_json(data))
			"party_leader":
				received_party_leader.emit(NakamaRtTypes.PartyLeader.from_json(data))
			"party_matchmaker_ticket":
				received_party_matchmaker_ticket.emit(NakamaRtTypes.PartyMatchmakerTicket.from_json(data))
			"party_presence_event":
				received_party_presence.emit(NakamaRtTypes.PartyPresenceEvent.from_json(data))
			"party_update":
				received_party_update.emit(NakamaRtTypes.PartyUpdate.from_json(data))
			"status_presence_event":
				received_status_presence.emit(NakamaRtTypes.StatusPresenceEvent.from_json(data))
			"stream_presence_event":
				received_stream_presence.emit(NakamaRtTypes.StreamPresenceEvent.from_json(data))
			"stream_data":
				received_stream_state.emit(NakamaRtTypes.StreamData.from_json(data))
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

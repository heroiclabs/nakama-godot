extends NakamaAsyncResult

class_name NakamaRTAPI

# A chat channel on the server.
class Channel extends NakamaAsyncResult:

	const _SCHEMA = {
		"id": {"name": "id", "type": TYPE_STRING, "required": true},
		"presences": {"name": "presences", "type": TYPE_ARRAY, "required": false, "content": "UserPresence"},
		"self": {"name": "self_presence", "type": "UserPresence", "required": true},
		"room_name": {"name": "room_name", "type": TYPE_STRING, "required": false},
		"group_id": {"name": "group_id", "type": TYPE_STRING, "required": false},
		"user_id_one": {"name": "user_id_one", "type": TYPE_STRING, "required": false},
		"user_id_two": {"name": "user_id_two", "type": TYPE_STRING, "required": false}
	}

	# The server-assigned channel ID.
	var id : String

	# The presences visible on the chat channel.
	var presences : Array # of objects NakamaUserPresence

	# The presence of the current user. i.e. Your self.
	var self_presence : NakamaRTAPI.UserPresence

	# The name of the chat room, or an empty string if this message was not sent through a chat room.
	var room_name : String

	# The ID of the group, or an empty string if this message was not sent through a group channel.
	var group_id : String

	# The ID of the first DM user, or an empty string if this message was not sent through a DM chat.
	var user_id_one : String

	# The ID of the second DM user, or an empty string if this message was not sent through a DM chat.
	var user_id_two : String

	func _init(p_ex = null):
		super(p_ex)

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "Channel<id=%s, presences=%s, self=%s, room_name=%s, group_id=%s, user_id_one=%s, user_id_two=%s>" % [
			id, presences, self_presence, room_name, group_id, user_id_one, user_id_two
		]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> Channel:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "Channel", p_dict), Channel) as Channel

	static func get_result_key() -> String:
		return "channel"


class ChannelMessageAck extends NakamaAsyncResult:

	const _SCHEMA = {
		"channel_id": {"name": "channel_id", "type": TYPE_STRING, "required": true},
		"code": {"name": "code", "type": TYPE_INT, "required": true},
		"create_time": {"name": "create_time", "type": TYPE_STRING, "required": false},
		"message_id": {"name": "message_id", "type": TYPE_STRING, "required": true},
		"persistent": {"name": "persistent", "type": TYPE_BOOL, "required": false},
		"update_time": {"name": "update_time", "type": TYPE_STRING, "required": false},
		"username": {"name": "username", "type": TYPE_STRING, "required": false},
		"room_name": {"name": "room_name", "type": TYPE_STRING, "required": false},
		"group_id": {"name": "group_id", "type": TYPE_STRING, "required": false},
		"user_id_one": {"name": "user_id_one", "type": TYPE_STRING, "required": false},
		"user_id_two": {"name": "user_id_two", "type": TYPE_STRING, "required": false}
	}

	# The server-assigned channel ID.
	var channel_id : String

	# A user-defined code for the chat message.
	var code : int

	# The UNIX time when the message was created.
	var create_time : String

	# A unique ID for the chat message.
	var message_id : String

	# True if the chat message has been stored in history.
	var persistent : bool

	# The UNIX time when the message was updated.
	var update_time : String

	# The username of the sender of the message.
	var username : String

	# The name of the chat room, or an empty string if this message was not sent through a chat room.
	var room_name : String

	# The ID of the group, or an empty string if this message was not sent through a group channel.
	var group_id : String

	# The ID of the first DM user, or an empty string if this message was not sent through a DM chat.
	var user_id_one : String

	# The ID of the second DM user, or an empty string if this message was not sent through a DM chat.
	var user_id_two : String

	func _init(p_ex = null):
		super(p_ex)

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "ChannelMessageAck<channel_id=%s, code=%d, create_time=%s, message_id=%s, persistent=%s, update_time=%s, username=%s room_name=%s, group_id=%s, user_id_one=%s, user_id_two=%s>" % [
			channel_id, code, create_time, message_id, persistent, update_time, username, room_name, group_id, user_id_one, user_id_two
		]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> ChannelMessageAck:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "ChannelMessageAck", p_dict), ChannelMessageAck) as ChannelMessageAck

	static func get_result_key() -> String:
		return "channel_message_ack"


# A batch of join and leave presences on a chat channel.
class ChannelPresenceEvent extends NakamaAsyncResult:

	const _SCHEMA = {
		"channel_id": {"name": "channel_id", "type": TYPE_STRING, "required": true},
		"joins": {"name": "joins", "type": TYPE_ARRAY, "required": false, "content" : "UserPresence"},
		"leaves": {"name": "leaves", "type": TYPE_ARRAY, "required": false, "content" : "UserPresence"},
		"room_name": {"name": "room_name", "type": TYPE_STRING, "required": false},
		"group_id": {"name": "group_id", "type": TYPE_STRING, "required": false},
		"user_id_one": {"name": "user_id_one", "type": TYPE_STRING, "required": false},
		"user_id_two": {"name": "user_id_two", "type": TYPE_STRING, "required": false}
	}

	# The unique identifier of the chat channel.
	var channel_id : String

	# Presences of the users who joined the channel.
	var joins : Array # UserPresence

	# Presences of users who left the channel.
	var leaves : Array # UserPresence

	# The name of the chat room, or an empty string if this message was not sent through a chat room.
	var room_name : String

	# The ID of the group, or an empty string if this message was not sent through a group channel.
	var group_id : String

	# The ID of the first DM user, or an empty string if this message was not sent through a DM chat.
	var user_id_one : String

	# The ID of the second DM user, or an empty string if this message was not sent through a DM chat.
	var user_id_two : String

	func _init(p_ex = null):
		super(p_ex)

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "ChannelPresenceEvent<channel_id=%s, joins=%s, leaves=%s, room_name=%s, group_id=%s, user_id_one=%s, user_id_two=%s>" % [
			channel_id, joins, leaves, room_name, group_id, user_id_one, user_id_two
		]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> ChannelPresenceEvent:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "ChannelPresenceEvent", p_dict), ChannelPresenceEvent) as ChannelPresenceEvent

	static func get_result_key() -> String:
		return "channel_presence_event"


# Describes an error which occurred on the server.
class Error extends NakamaAsyncResult:

	const _SCHEMA = {
		"code": {"name": "code", "type": TYPE_INT, "required": true},
		"message": {"name": "message", "type": TYPE_STRING, "required": true},
		"context": {"name": "context", "type": TYPE_DICTIONARY, "required": false, "content": TYPE_STRING},
	}

	# The selection of possible error codes.
	enum Code {
		# An unexpected result from the server.
		RUNTIME_EXCEPTION = 0,
		# The server received a message which is not recognised.
		UNRECOGNIZED_PAYLOAD = 1,
		# A message was expected but contains no content.
		MISSING_PAYLOAD = 2,
		# Fields in the message have an invalid format.
		BAD_INPUT = 3,
		# The match id was not found.
		MATCH_NOT_FOUND = 4,
		# The match join was rejected.
		MATCH_JOIN_REJECTED = 5,
		# The runtime function does not exist on the server.
		RUNTIME_FUNCTION_NOT_FOUND = 6,
		#The runtime function executed with an error.
		RUNTIME_FUNCTION_EXCEPTION = 7,
	}

	# The error code which should be one of "Error.Code" enums.
	var code : int

	# A message in English to help developers debug the response.
	var message : String

	# Additional error details which may be different for each response.
	var context : Dictionary

	func _init(p_ex = null):
		super(p_ex)

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "Error<code=%s, messages=%s, context=%s>" % [code, message, context]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> Error:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "Error", p_dict), Error) as Error

	static func get_result_key() -> String:
		return "error"


# A multiplayer match.
class Match extends NakamaAsyncResult:

	const _SCHEMA = {
		"authoritative": {"name": "authoritative", "type": TYPE_BOOL, "required": false},
		"match_id": {"name": "match_id", "type": TYPE_STRING, "required": true},
		"label": {"name": "label", "type": TYPE_STRING, "required": false},
		"presences": {"name": "presences", "type": TYPE_ARRAY, "required": false, "content": "UserPresence"},
		"size": {"name": "size", "type": TYPE_INT, "required": false},
		"self": {"name": "self_user", "type": "UserPresence", "required": true}
	}

	# If this match has an authoritative handler on the server.
	var authoritative : bool

	# The unique match identifier.
	var match_id : String

	# A label for the match which can be filtered on.
	var label : String

	# The presences already in the match.
	var presences : Array # UserPresence

	# The number of users currently in the match.
	var size : int

	# The current user in this match. i.e. Yourself.
	var self_user : UserPresence

	func _init(p_ex = null):
		super(p_ex)

	static func create(p_ns : GDScript, p_dict : Dictionary):
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "Match", p_dict), Match) as Match

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "Match<authoritative=%s, match_id=%s, label=%s, presences=%s, size=%d, self=%s>" % [authoritative, match_id, label, presences, size, self_user]

	static func get_result_key() -> String:
		return "match"


# Some game state update in a match.
class MatchData extends NakamaAsyncResult:
	const _SCHEMA = {
		"match_id": {"name": "match_id", "type": TYPE_STRING, "required": true},
		"presence": {"name": "presence", "type": "UserPresence", "required": false},
		"op_code": {"name": "op_code", "type": TYPE_INT, "required": false},
		"data": {"name": "data", "type": TYPE_STRING, "required": false}
	}

	# The unique match identifier.
	var match_id : String

	# The operation code for the state change.
	# This value can be used to mark the type of the contents of the state.
	var op_code : int = 0

	# The user that sent this game state update.
	var presence : UserPresence

	# The raw base64-encoded contents of the state change.
	var base64_data : String

	# The contents of the state change decoded as a UTF-8 string.
	var _data
	var data : String:
		get:
			if _data == null and base64_data != '':
				_data = Marshalls.base64_to_utf8(base64_data)
			return _data if _data != null else ''
		set(v):
			_data = v

	# The contents of the state change decoded as binary data.
	var _binary_data
	var binary_data : PackedByteArray:
		get:
			if _binary_data == null and base64_data != '':
				_binary_data = Marshalls.base64_to_raw(base64_data)
			return _binary_data

	func _init(p_ex = null):
		super(p_ex)

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "MatchData<match_id=%s, op_code=%s, presence=%s, data=%s>" % [match_id, op_code, presence, data]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> MatchData:
		var out = _safe_ret(NakamaSerializer.deserialize(p_ns, "MatchData", p_dict), MatchData) as MatchData
		# Store the base64 data, ready to be decoded when the developer requests it.
		if out._data != null:
			out.base64_data = out._data
			out._data = null
		return out

	static func get_result_key() -> String:
		return "match_data"


# A batch of join and leave presences for a match.
class MatchPresenceEvent extends NakamaAsyncResult:
	const _SCHEMA = {
		"match_id": {"name": "match_id", "type": TYPE_STRING, "required": true},
		"joins": {"name": "joins", "type": TYPE_ARRAY, "required": false, "content" : "UserPresence"},
		"leaves": {"name": "leaves", "type": TYPE_ARRAY, "required": false, "content" : "UserPresence"},
	}

	# Presences of users who joined the match.
	var joins : Array

	# Presences of users who left the match.
	var leaves : Array

	# The unique match identifier.
	var match_id : String

	func _init(p_ex = null):
		super(p_ex)

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "MatchPresenceEvent<match_id=%s, joins=%s, leaves=%s>" % [match_id, joins, leaves]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> MatchPresenceEvent:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "MatchPresenceEvent", p_dict), MatchPresenceEvent) as MatchPresenceEvent

	static func get_result_key() -> String:
		return "match_presence_event"


# The result of a successful matchmaker operation sent to the server.
class MatchmakerMatched extends NakamaAsyncResult:

	const _SCHEMA = {
		"match_id": {"name": "match_id", "type": TYPE_STRING, "required": false},
		"ticket": {"name": "ticket", "type": TYPE_STRING, "required": true},
		"token": {"name": "token", "type": TYPE_STRING, "required": false},
		"users": {"name": "users", "type": TYPE_ARRAY, "required": false, "content": "MatchmakerUser"},
		"self": {"name": "self_user", "type": "MatchmakerUser", "required": true}
	}

	# The id used to join the match.
	# A match ID used to join the match.
	var match_id : String

	# The ticket sent by the server when the user requested to matchmake for other players.
	var ticket : String

	# The token used to join a match.
	var token : String

	# The other users matched with this user and the parameters they sent.
	var users : Array # MatchmakerUser

	# The current user who matched with opponents.
	var self_user : MatchmakerUser

	func _init(p_ex = null):
		super(p_ex)

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "<MatchmakerMatched match_id=%s, ticket=%s, token=%s, users=%s, self=%s>" % [
			match_id, ticket, token, users, self_user
		]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> MatchmakerMatched:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "MatchmakerMatched", p_dict), MatchmakerMatched) as MatchmakerMatched

	static func get_result_key() -> String:
		return "matchmaker_matched"


# The matchmaker ticket received from the server.
class MatchmakerTicket extends NakamaAsyncResult:

	const _SCHEMA = {
		"ticket": {"name": "ticket", "type": TYPE_STRING, "required": true}
	}

	# The ticket generated by the matchmaker.
	var ticket : String

	func _init(p_ex = null):
		super(p_ex)

	static func create(p_ns : GDScript, p_dict : Dictionary) -> MatchmakerTicket:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "MatchmakerTicket", p_dict), MatchmakerTicket) as MatchmakerTicket

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "<MatchmakerTicket ticket=%s>" % ticket

	static func get_result_key() -> String:
		return "matchmaker_ticket"


# The user with the parameters they sent to the server when asking for opponents.
class MatchmakerUser extends NakamaAsyncResult:

	const _SCHEMA = {
		"presence": {"name": "presence", "type": "UserPresence", "required": true},
		"party_id": {"name": "party_id", "type": TYPE_STRING, "required": false},
		"string_properties": {"name": "string_properties", "type": TYPE_DICTIONARY, "required": false, "content": TYPE_STRING},
		"numeric_properties": {"name": "numeric_properties", "type": TYPE_DICTIONARY, "required": false, "content": TYPE_FLOAT},
	}

	# The presence of the user.
	var presence : UserPresence

	# Party identifier, if this user was matched as a party member.
	var party_id : String

	# The numeric properties which this user asked to matchmake with.
	var numeric_properties : Dictionary

	# The string properties which this user asked to matchmake with.
	var string_properties : Dictionary

	func _init(p_ex = null):
		super(p_ex)

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "<MatchmakerUser presence=%s, numeric_properties=%s, string_properties=%s>" % [
			presence, numeric_properties, string_properties]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> MatchmakerUser:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "MatchmakerUser", p_dict), MatchmakerUser) as MatchmakerUser

	static func get_result_key() -> String:
		return "matchmaker_user"


# Receive status updates for users.
class Status extends NakamaAsyncResult:

	const _SCHEMA = {
		"presences": {"name": "presences", "type": TYPE_ARRAY, "required": true, "content": "UserPresence"},
	}

	# The status events for the users followed.
	var presences := Array()

	func _init(p_ex = null):
		super(p_ex)

	static func create(p_ns : GDScript, p_dict : Dictionary) -> Status:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "Status", p_dict), Status) as Status

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "<Status presences=%s>" % [presences]

	static func get_result_key() -> String:
		return "status"


# A status update event about other users who've come online or gone offline.
class StatusPresenceEvent extends NakamaAsyncResult:
	const _SCHEMA = {
		"joins": {"name": "joins", "type": TYPE_ARRAY, "required": false, "content" : "UserPresence"},
		"leaves": {"name": "leaves", "type": TYPE_ARRAY, "required": false, "content" : "UserPresence"},
	}

	# Presences of users who joined the server.
	# This join information is in response to a subscription made to be notified when a user comes online.
	var joins : Array

	# Presences of users who left the server.
	# This leave information is in response to a subscription made to be notified when a user goes offline.
	var leaves : Array

	func _init(p_ex = null):
		super(p_ex)

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "StatusPresenceEvent<joins=%s, leaves=%s>" % [joins, leaves]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> StatusPresenceEvent:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "StatusPresenceEvent", p_dict), StatusPresenceEvent) as StatusPresenceEvent

	static func get_result_key() -> String:
		return "status_presence_event"


# A realtime socket stream on the server.
class Stream extends NakamaAsyncResult:

	const _SCHEMA = {
		"mode": {"name": "mode", "type": TYPE_INT, "required": true},
		"subject": {"name": "subject", "type": TYPE_STRING, "required": false},
		"subcontext": {"name": "subcontext", "type": TYPE_STRING, "required": false},
		"label": {"name": "label", "type": TYPE_STRING, "required": false},
	}

	# The mode of the stream.
	var mode : int

	# The subject of the stream. This is usually a user id.
	var subject : String

	# The descriptor of the stream. Used with direct chat messages and contains a second user id.
	var subcontext : String

	# Identifies streams which have a context across users like a chat channel room.
	var label : String

	func _init(p_ex = null):
		super(p_ex)

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "Stream<mode=%s, subject=%s, subcontext=%s, label=%s>" % [mode, subject, subcontext, label]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> Stream:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "Stream", p_dict), Stream) as Stream

	static func get_result_key() -> String:
		return "stream"


# A batch of joins and leaves on the low level stream.
# Streams are built on to provide abstractions for matches, chat channels, etc. In most cases you'll never need to
# interact with the low level stream itself.
class StreamPresenceEvent extends NakamaAsyncResult:
	const _SCHEMA = {
		"stream": {"name": "stream", "type": "Stream", "required": true},
		"joins": {"name": "joins", "type": TYPE_ARRAY, "required": false, "content" : "UserPresence"},
		"leaves": {"name": "leaves", "type": TYPE_ARRAY, "required": false, "content" : "UserPresence"},
	}

	# Presences of users who left the stream.
	var joins : Array

	# Presences of users who joined the stream.
	var leaves : Array

	# The identifier for the stream.
	var stream : Stream = null

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "StreamPresenceEvent<stream=%s, joins=%s, leaves=%s>" % [stream, joins, leaves]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> StreamPresenceEvent:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "StreamPresenceEvent", p_dict), StreamPresenceEvent) as StreamPresenceEvent

	static func get_result_key() -> String:
		return "stream_presence_event"


# A state change received from a stream.
class StreamData extends NakamaAsyncResult:

	const _SCHEMA = {
		"stream": {"name": "stream", "type": "Stream", "required": true},
		"sender": {"name": "sender", "type": "UserPresence", "required": false},
		"data": {"name": "state", "type": TYPE_STRING, "required": false},
		"reliable": {"name": "reliable", "type": TYPE_BOOL, "required": false},
	}

	# The user who sent the state change. May be `null`.
	var sender : UserPresence = null

	# The contents of the state change.
	var state : String

	# The identifier for the stream.
	var stream : Stream

	# True if this data was delivered reliably, false otherwise.
	var reliable : bool

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "StreamData<sender=%s, state=%s, stream=%s>" % [sender, state, stream]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> StreamData:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "StreamData", p_dict), StreamData) as StreamData

	static func get_result_key() -> String:
		return "stream_data"


# An object which represents a connected user in the server.
# The server allows the same user to be connected with multiple sessions. To uniquely identify them a tuple of
# `{ node_id, user_id, session_id }` is used which is exposed as this object.
class UserPresence extends NakamaAsyncResult:

	const _SCHEMA = {
		"persistence": {"name": "persistence", "type": TYPE_BOOL, "required": false},
		"session_id": {"name": "session_id", "type": TYPE_STRING, "required": true},
		"status": {"name": "status", "type": TYPE_STRING, "required": false},
		"username": {"name": "username", "type": TYPE_STRING, "required": false},
		"user_id": {"name": "user_id", "type": TYPE_STRING, "required": true},
	}

	# If this presence generates stored events like persistent chat messages or notifications.
	var persistence : bool

	# The session id of the user.
	var session_id : String

	# The status of the user with the presence on the server.
	var status : String

	# The username for the user.
	var username : String

	# The id of the user.
	var user_id : String

	func _init(p_ex = null):
		super(p_ex)

	func serialize() -> Dictionary:
		return NakamaSerializer.serialize(self)

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "UserPresence<persistence=%s, session_id=%s, status=%s, username=%s, user_id=%s>" % [
			persistence, session_id, status, username, user_id]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> UserPresence:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "UserPresence", p_dict), UserPresence) as UserPresence

	static func get_result_key() -> String:
		return "user_presence"


class Party extends NakamaAsyncResult:

	const _SCHEMA = {
		"party_id": {"name": "party_id", "type": TYPE_STRING, "required": true},
		"open": {"name": "open", "type": TYPE_BOOL, "required": false},
		"max_size": {"name": "max_size", "type": TYPE_INT, "required": true},
		"self": {"name": "self_presence", "type": "UserPresence", "required": true},
		"leader": {"name": "leader", "type": "UserPresence", "required": true},
		"presences": {"name": "presences", "type": TYPE_ARRAY, "required": false, "content": "UserPresence"},
	}

	# Unique party identifier.
	var party_id : String

	# Open flag.
	var open : bool = false

	# Maximum number of party members.
	var max_size : int

	# The presence of the current user. i.e. Your self.
	var self_presence : NakamaRTAPI.UserPresence

	# Leader.
	var leader : NakamaRTAPI.UserPresence

	# All current party members.
	var presences : Array # of objects NakamaUserPresence

	func _init(p_ex = null):
		super(p_ex)

	func serialize() -> Dictionary:
		return NakamaSerializer.serialize(self)

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "Party<party_id=%s, open=%s, max_size=%d, self=%s, leader=%s, presences=%s>" % [
			party_id, open, max_size, self_presence, leader, presences]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> Party:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "Party", p_dict), Party) as Party

	static func get_result_key() -> String:
		return "party"


# Presence update for a particular party.
class PartyPresenceEvent extends NakamaAsyncResult:
	const _SCHEMA = {
		"party_id": {"name": "party_id", "type": TYPE_STRING, "required": true},
		"joins": {"name": "joins", "type": TYPE_ARRAY, "required": false, "content": "UserPresence"},
		"leaves": {"name": "leaves", "type": TYPE_ARRAY, "required": false, "content": "UserPresence"},
	}
	# The party ID.
	var party_id : String
	# User presences that have just joined the party.
	var joins : Array
	# User presences that have just left the party.
	var leaves : Array

	func _init(p_ex = null):
		super(p_ex)

	func serialize() -> Dictionary:
		return NakamaSerializer.serialize(self)

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "PartyPresenceEvent<party_id=%s, joins=%s, leaves=%s>" % [party_id, joins, leaves]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> PartyPresenceEvent:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "PartyPresenceEvent", p_dict), PartyPresenceEvent) as PartyPresenceEvent

	static func get_result_key() -> String:
		return "party_presence_event"


# Announcement of a new party leader.
class PartyLeader extends NakamaAsyncResult:
	const _SCHEMA = {
		"party_id": {"name": "party_id", "type": TYPE_STRING, "required": true},
		"presence": {"name": "presence", "type": "UserPresence", "required": true},
	}
	# Party ID to promote a new leader for.
	var party_id : String
	# The presence of an existing party member to promote as the new leader.
	var presence : NakamaRTAPI.UserPresence

	func _init(p_ex = null):
		super(p_ex)

	func serialize() -> Dictionary:
		return NakamaSerializer.serialize(self)

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "PartyLeader<party_id=%s, presence=%s>" % [party_id, presence]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> PartyLeader:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "PartyLeader", p_dict), PartyLeader) as PartyLeader

	static func get_result_key() -> String:
		return "party_leader"


# Incoming notification for one or more new presences attempting to join the party.
class PartyJoinRequest extends NakamaAsyncResult:
	const _SCHEMA = {
		"party_id": {"name": "party_id", "type": TYPE_STRING, "required": true},
		"presences": {"name": "presences", "type": TYPE_ARRAY, "required": false, "content": "UserPresence"},
	}
	# Party ID these presences are attempting to join.
	var party_id : String
	# Presences attempting to join.
	var presences : Array

	func _init(p_ex = null):
		super(p_ex)

	func serialize() -> Dictionary:
		return NakamaSerializer.serialize(self)

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "PartyJoinRequest<party_id=%s, presences=%s>" % [party_id, presences]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> PartyJoinRequest:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "PartyJoinRequest", p_dict), PartyJoinRequest) as PartyJoinRequest

	static func get_result_key() -> String:
		return "party_join_request"


# A response from starting a new party matchmaking process.
class PartyMatchmakerTicket extends NakamaAsyncResult:
	const _SCHEMA = {
		"party_id": {"name": "party_id", "type": TYPE_STRING, "required": true},
		"ticket": {"name": "ticket", "type": TYPE_STRING, "required": true},
	}
	# Party ID.
	var party_id : String
	# The ticket that can be used to cancel matchmaking.
	var ticket : String

	func _init(p_ex = null):
		super(p_ex)

	func serialize() -> Dictionary:
		return NakamaSerializer.serialize(self)

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "PartyMatchmakerTicket<party_id=%s, ticket=%s>" % [party_id, ticket]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> PartyMatchmakerTicket:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "PartyMatchmakerTicket", p_dict), PartyMatchmakerTicket) as PartyMatchmakerTicket

	static func get_result_key() -> String:
		return "party_matchmaker_ticket"


# Incoming party data delivered from the server.
class PartyData extends NakamaAsyncResult:
	const _SCHEMA = {
		"party_id": {"name": "party_id", "type": TYPE_STRING, "required": true},
		"presence": {"name": "presence", "type": "UserPresence", "required": false},
		"op_code": {"name": "op_code", "type": TYPE_INT, "required": true},
		"data": {"name": "data", "type": TYPE_STRING, "required": false}
	}
	# The party ID.
	var party_id : String
	# A reference to the user presence that sent this data, if any.
	var presence : NakamaRTAPI.UserPresence
	# Op code value.
	var op_code : int

	# The raw base64-encoded contents of the state change.
	var base64_data : String

	# The contents of the state change decoded as a UTF-8 string.
	var _data
	var data : String:
		get:
			if _data == null and base64_data != '':
				_data = Marshalls.base64_to_utf8(base64_data)
			return _data if _data != null else ''
		set(v):
			_data = v

	# The contents of the state change decoded as binary data.
	var _binary_data
	var binary_data : PackedByteArray:
		get:
			if _binary_data == null and base64_data != '':
				_binary_data = Marshalls.base64_to_raw(base64_data)
			return _binary_data

	func _init(p_ex = null):
		super(p_ex)

	func serialize() -> Dictionary:
		return NakamaSerializer.serialize(self)

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "PartyData<party_id=%s, presence=%s, op_code=%d, data%s>" % [party_id, presence, op_code, data]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> PartyData:
		var out := _safe_ret(NakamaSerializer.deserialize(p_ns, "PartyData", p_dict), PartyData) as PartyData
		# Store the base64 data, ready to be decoded when the developer requests it.
		if out._data != null:
			out.base64_data = out._data
			out._data = null
		return out

	static func get_result_key() -> String:
		return "party_data"

# End a party, kicking all party members and closing it. (this is both a message and a result)
class PartyClose extends NakamaAsyncResult:
	const _SCHEMA = {
		"party_id": {"name": "party_id", "type": TYPE_STRING, "required": true},
	}
	# Party ID to close.
	var party_id : String

	func _init(p_ex = null):
		super(p_ex)

	func serialize():
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "party_close"

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "PartyClose<party_id=%s>" % [party_id]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> PartyClose:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "PartyClose", p_dict), PartyClose) as PartyClose

	static func get_result_key() -> String:
		return "party_close"

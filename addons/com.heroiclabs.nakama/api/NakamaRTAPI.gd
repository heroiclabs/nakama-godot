extends NakamaAsyncResult

class_name NakamaRTAPI

### <summary>
### A chat channel on the server.
### </summary>
class Channel extends NakamaAsyncResult:

	const _SCHEMA = {
		"id": {"name": "id", "type": TYPE_STRING, "required": true},
		"presences": {"name": "presences", "type": TYPE_ARRAY, "required": true, "content": "UserPresence"},
		"self": {"name": "self_presence", "type": "UserPresence", "required": true},
		"room_name": {"name": "room_name", "type": TYPE_STRING, "required": false},
		"group_id": {"name": "group_id", "type": TYPE_STRING, "required": false},
		"user_id_one": {"name": "user_id_one", "type": TYPE_STRING, "required": false},
		"user_id_two": {"name": "user_id_two", "type": TYPE_STRING, "required": false}
	}

	### <summary>
	### The server-assigned channel ID.
	### </summary>
	var id : String

	### <summary>
	### The presences visible on the chat channel.
	### </summary>
	var presences : Array # of objects NakamaUserPresence

	### <summary>
	### The presence of the current user. i.e. Your self.
	### </summary>
	var self_presence : NakamaRTAPI.UserPresence

	### <summary>
	### The name of the chat room, or an empty string if this message was not sent through a chat room.
	### </summary>
	var room_name : String

	### <summary>
	### The ID of the group, or an empty string if this message was not sent through a group channel.
	### </summary>
	var group_id : String

	### <summary>
	### The ID of the first DM user, or an empty string if this message was not sent through a DM chat.
	### </summary>
	var user_id_one : String

	### <summary>
	### The ID of the second DM user, or an empty string if this message was not sent through a DM chat.
	### </summary>
	var user_id_two : String

	func _init(p_ex = null).(p_ex):
		pass

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

	### <summary>
	### The server-assigned channel ID.
	### </summary>
	var channel_id : String

	### <summary>
	### A user-defined code for the chat message.
	### </summary>
	var code : int

	### <summary>
	### The UNIX time when the message was created.
	### </summary>
	var create_time : String

	### <summary>
	### A unique ID for the chat message.
	### </summary>
	var message_id : String

	### <summary>
	### True if the chat message has been stored in history.
	### </summary>
	var persistent : bool

	### <summary>
	### The UNIX time when the message was updated.
	### </summary>
	var update_time : String

	### <summary>
	### The username of the sender of the message.
	### </summary>
	var username : String

	### <summary>
	### The name of the chat room, or an empty string if this message was not sent through a chat room.
	### </summary>
	var room_name : String

	### <summary>
	### The ID of the group, or an empty string if this message was not sent through a group channel.
	### </summary>
	var group_id : String

	### <summary>
	### The ID of the first DM user, or an empty string if this message was not sent through a DM chat.
	### </summary>
	var user_id_one : String

	### <summary>
	### The ID of the second DM user, or an empty string if this message was not sent through a DM chat.
	### </summary>
	var user_id_two : String

	func _init(p_ex = null).(p_ex):
		pass

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "ChannelMessageAck<channel_id=%s, code=%d, create_time=%s, message_id=%s, persistent=%s, update_time=%s, username=%s room_name=%s, group_id=%s, user_id_one=%s, user_id_two=%s>" % [
			channel_id, code, create_time, message_id, persistent, update_time, username, room_name, group_id, user_id_one, user_id_two
		]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> ChannelMessageAck:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "ChannelMessageAck", p_dict), ChannelMessageAck) as ChannelMessageAck

	static func get_result_key() -> String:
		return "channel_message_ack"


### <summary>
### A batch of join and leave presences on a chat channel.
### </summary>
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

	### <summary>
	### The unique identifier of the chat channel.
	### </summary>
	var channel_id : String

	### <summary>
	### Presences of the users who joined the channel.
	### </summary>
	var joins : Array # UserPresence

	### <summary>
	### Presences of users who left the channel.
	### </summary>
	var leaves : Array # UserPresence

	### <summary>
	### The name of the chat room, or an empty string if this message was not sent through a chat room.
	### </summary>
	var room_name : String

	### <summary>
	### The ID of the group, or an empty string if this message was not sent through a group channel.
	### </summary>
	var group_id : String

	### <summary>
	### The ID of the first DM user, or an empty string if this message was not sent through a DM chat.
	### </summary>
	var user_id_one : String

	### <summary>
	### The ID of the second DM user, or an empty string if this message was not sent through a DM chat.
	### </summary>
	var user_id_two : String

	func _init(p_ex = null).(p_ex):
		pass

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "ChannelPresenceEvent<channel_id=%s, joins=%s, leaves=%s, room_name=%s, group_id=%s, user_id_one=%s, user_id_two=%s>" % [
			channel_id, joins, leaves, room_name, group_id, user_id_one, user_id_two
		]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> ChannelPresenceEvent:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "ChannelPresenceEvent", p_dict), ChannelPresenceEvent) as ChannelPresenceEvent

	static func get_result_key() -> String:
		return "channel_presence_event"

### <summary>
### A multiplayer match.
### </summary>
class Match extends NakamaAsyncResult:

	const _SCHEMA = {
		"authoritative": {"name": "authoritative", "type": TYPE_BOOL, "required": false},
		"match_id": {"name": "match_id", "type": TYPE_STRING, "required": true},
		"label": {"name": "label", "type": TYPE_STRING, "required": false},
		"presences": {"name": "presences", "type": TYPE_ARRAY, "required": false, "content": "UserPresence"},
		"size": {"name": "size", "type": TYPE_INT, "required": false},
		"self": {"name": "self_user", "type": "UserPresence", "required": true}
	}

	### <summary>
	### If this match has an authoritative handler on the server.
	### </summary>
	var authoritative : bool

	### <summary>
	### The unique match identifier.
	### </summary>
	var match_id : String

	### <summary>
	### A label for the match which can be filtered on.
	### </summary>
	var label : String

	### <summary>
	### The presences already in the match.
	### </summary>
	var presences : Array # UserPresence

	### <summary>
	### The number of users currently in the match.
	### </summary>
	var size : int

	### <summary>
	### The current user in this match. i.e. Yourself.
	### </summary>
	var self_user : UserPresence

	func _init(p_ex = null).(p_ex):
		pass

	static func create(p_ns : GDScript, p_dict : Dictionary):
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "Match", p_dict), Match) as Match

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "Match<authoritative=%s, match_id=%s, label=%s, presences=%s, size=%d, self=%s>" % [authoritative, match_id, label, presences, size, self_user]

	static func get_result_key() -> String:
		return "match"


### <summary>
### Some game state update in a match.
### </summary>
class MatchData extends NakamaAsyncResult:
	const _SCHEMA = {
		"match_id": {"name": "match_id", "type": TYPE_STRING, "required": true},
		"presence": {"name": "presence", "type": "UserPresence", "required": false},
		"op_code": {"name": "op_code", "type": TYPE_STRING, "required": false},
		"data": {"name": "data", "type": TYPE_STRING, "required": false}
	}

	### <summary>
	### The unique match identifier.
	### </summary>
	var match_id : String

	### <summary>
	### The operation code for the state change.
	### </summary>
	### <remarks>
	### This value can be used to mark the type of the contents of the state.
	### </remarks>
	var op_code : int = 0

	### <summary>
	### The byte contents of the state change.
	### </summary>
	var data : String

	func _init(p_ex = null).(p_ex):
		pass

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "MatchData<match_id=%s, op_code=%s, data=%s>" % [match_id, op_code, data]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> MatchData:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "MatchData", p_dict), MatchData) as MatchData

	static func get_result_key() -> String:
		return "match_data"


### <summary>
### A batch of join and leave presences for a match.
### </summary>
class MatchPresenceEvent extends NakamaAsyncResult:
	const _SCHEMA = {
		"match_id": {"name": "match_id", "type": TYPE_STRING, "required": true},
		"joins": {"name": "joins", "type": TYPE_ARRAY, "required": false, "content" : "UserPresence"},
		"leaves": {"name": "leaves", "type": TYPE_ARRAY, "required": false, "content" : "UserPresence"},
	}

	### <summary>
	### Presences of users who joined the match.
	### </summary>
	var joins : Array

	### <summary>
	### Presences of users who left the match.
	### </summary>
	var leaves : Array

	### <summary>
	### The unique match identifier.
	### </summary>
	var match_id : String

	func _init(p_ex = null).(p_ex):
		pass

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "MatchPresenceEvent<match_id=%s, joins=%s, leaves=%s>" % [match_id, joins, leaves]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> MatchPresenceEvent:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "MatchPresenceEvent", p_dict), MatchPresenceEvent) as MatchPresenceEvent

	static func get_result_key() -> String:
		return "match_presence_event"

### <summary>
### The result of a successful matchmaker operation sent to the server.
### </summary>
class MatchmakerMatched extends NakamaAsyncResult:

	const _SCHEMA = {
		"match_id": {"name": "match_id", "type": TYPE_STRING, "required": false},
		"ticket": {"name": "ticket", "type": TYPE_STRING, "required": true},
		"token": {"name": "token", "type": TYPE_STRING, "required": false},
		"users": {"name": "users", "type": TYPE_ARRAY, "required": false, "content": "MatchmakerUser"},
		"self": {"name": "self_user", "type": "MatchmakerUser", "required": true}
	}

	### <summary>
	### The id used to join the match.
	### </summary>
	### <remarks>
	### A match ID used to join the match.
	### </remarks>
	var match_id : String

	### <summary>
	### The ticket sent by the server when the user requested to matchmake for other players.
	### </summary>
	var ticket : String

	### <summary>
	### The token used to join a match.
	### </summary>
	var token : String

	### <summary>
	### The other users matched with this user and the parameters they sent.
	### </summary>
	var users : Array # MatchmakerUser
	
	### <summary>
	### The current user who matched with opponents.
	### </summary>
	var self_user : MatchmakerUser

	func _init(p_ex = null).(p_ex):
		pass

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "<MatchmakerMatched match_id=%s, ticket=%s, token=%s, users=%s, self=%s>" % [
			match_id, ticket, token, users, self_user
		]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> MatchmakerMatched:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "MatchmakerMatched", p_dict), MatchmakerMatched) as MatchmakerMatched

	static func get_result_key() -> String:
		return "matchmaker_matched"


### <summary>
### The matchmaker ticket received from the server.
### </summary>
class MatchmakerTicket extends NakamaAsyncResult:

	const _SCHEMA = {
		"ticket": {"name": "ticket", "type": TYPE_STRING, "required": true}
	}

	### <summary>
	### The ticket generated by the matchmaker.
	### </summary>
	var ticket : String

	func _init(p_ex = null).(p_ex):
		pass

	static func create(p_ns : GDScript, p_dict : Dictionary) -> MatchmakerTicket:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "MatchmakerTicket", p_dict), MatchmakerTicket) as MatchmakerTicket

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "<MatchmakerTicket ticket=%s>" % ticket

	static func get_result_key() -> String:
		return "matchmaker_ticket"


### <summary>
### The user with the parameters they sent to the server when asking for opponents.
### </summary>
class MatchmakerUser extends NakamaAsyncResult:

	const _SCHEMA = {
		"numeric_properties": {"name": "numeric_properties", "type": TYPE_DICTIONARY, "required": false, "content": TYPE_REAL},
		"string_properties": {"name": "string_properties", "type": TYPE_DICTIONARY, "required": false, "content": TYPE_STRING},
		"presence": {"name": "presence", "type": "UserPresence", "required": true}
	}

	### <summary>
	### The numeric properties which this user asked to matchmake with.
	### </summary>
	var numeric_properties : Dictionary

	### <summary>
	### The presence of the user.
	### </summary>
	var presence : UserPresence

	### <summary>
	### The string properties which this user asked to matchmake with.
	### </summary>
	var string_properties : Dictionary

	func _init(p_ex = null).(p_ex):
		pass

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "<MatchmakerUser presence=%s, numeric_properties=%s, string_properties=%s>" % [
			presence, numeric_properties, string_properties]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> MatchmakerUser:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "MatchmakerUser", p_dict), MatchmakerUser) as MatchmakerUser

	static func get_result_key() -> String:
		return "matchmaker_user"


### <summary>
### Receive status updates for users.
### </summary>
class Status extends NakamaAsyncResult:

	const _SCHEMA = {
		"users": {"name": "users", "type": TYPE_ARRAY, "required": false, "content": "UserPresence"},
	}

	### <summary>
	### The status events for the users followed.
	### </summary>
	var presences := Array()

	func _init(p_ex = null).(p_ex):
		pass

	static func create(p_ns : GDScript, p_dict : Dictionary) -> Status:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "Status", p_dict), Status) as Status

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "<Status presences=%s>" % [presences]

	static func get_result_key() -> String:
		return "status"


### <summary>
### A status update event about other users who've come online or gone offline.
### </summary>
class StatusPresenceEvent extends NakamaAsyncResult:
	const _SCHEMA = {
		"joins": {"name": "joins", "type": TYPE_ARRAY, "required": false, "content" : "UserPresence"},
		"leaves": {"name": "leaves", "type": TYPE_ARRAY, "required": false, "content" : "UserPresence"},
	}

	### <summary>
	### Presences of users who joined the server.
	### </summary>
	### <remarks>
	### This join information is in response to a subscription made to be notified when a user comes online.
	### </remarks>
	var joins : Array

	### <summary>
	### Presences of users who left the server.
	### </summary>
	### <remarks>
	### This leave information is in response to a subscription made to be notified when a user goes offline.
	### </remarks>
	var leaves : Array

	func _init(p_ex = null).(p_ex):
		pass

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "StatusPresenceEvent<joins=%s, leaves=%s>" % [joins, leaves]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> StatusPresenceEvent:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "StatusPresenceEvent", p_dict), StatusPresenceEvent) as StatusPresenceEvent

	static func get_result_key() -> String:
		return "status_presence_event"


### <summary>
### A realtime socket stream on the server.
### </summary>
class Stream extends NakamaAsyncResult:

	const _SCHEMA = {
		"descriptor": {"name": "descriptor", "type": TYPE_STRING, "required": false},
		"label": {"name": "label", "type": TYPE_STRING, "required": false},
		"mode": {"name": "mode", "type": TYPE_INT, "required": true},
		"subject": {"name": "subject", "type": TYPE_STRING, "required": false},
	}

	### <summary>
	### The descriptor of the stream. Used with direct chat messages and contains a second user id.
	### </summary>
	var descriptor : String

	### <summary>
	### Identifies streams which have a context across users like a chat channel room.
	### </summary>
	var label : String

	### <summary>
	### The mode of the stream.
	### </summary>
	var mode : int

	### <summary>
	### The subject of the stream. This is usually a user id.
	### </summary>
	var subject : String

	func _init(p_ex = null).(p_ex):
		pass

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "Stream<descriptor=%s, label=%s, mode=%s, subject=%s>" % [descriptor, label, mode, subject]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> Stream:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "Stream", p_dict), Stream) as Stream

	static func get_result_key() -> String:
		return "stream"


### <summary>
### A batch of joins and leaves on the low level stream.
### </summary>
### <remarks>
### Streams are built on to provide abstractions for matches, chat channels, etc. In most cases you'll never need to
### interact with the low level stream itself.
### </remarks>
class StreamPresenceEvent extends NakamaAsyncResult:
	const _SCHEMA = {
		"stream": {"name": "stream", "type": "Stream", "required": true},
		"joins": {"name": "joins", "type": TYPE_ARRAY, "required": false, "content" : "UserPresence"},
		"leaves": {"name": "leaves", "type": TYPE_ARRAY, "required": false, "content" : "UserPresence"},
	}

	### <summary>
	### Presences of users who left the stream.
	### </summary>
	var joins : Array

	### <summary>
	### Presences of users who joined the stream.
	### </summary>
	var leaves : Array

	### <summary>
	### The identifier for the stream.
	### </summary>
	var stream : Stream = null

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "StreamPresenceEvent<stream=%s, joins=%s, leaves=%s>" % [stream, joins, leaves]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> StreamPresenceEvent:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "StreamPresenceEvent", p_dict), StreamPresenceEvent) as StreamPresenceEvent

	static func get_result_key() -> String:
		return "stream_presence_event"


### <summary>
### A state change received from a stream.
### </summary>
class StreamData extends NakamaAsyncResult:

	const _SCHEMA = {
		"stream": {"name": "stream", "type": "Stream", "required": true},
		"sender": {"name": "sender", "type": "UserPresence", "required": false},
		"data": {"name": "state", "type": TYPE_STRING, "required": false},
		"reliable": {"name": "reliable", "type": TYPE_BOOL, "required": false},
	}

	### <summary>
	### The user who sent the state change. May be <c>null</c>.
	### </summary>
	var sender : UserPresence = null

	### <summary>
	### The contents of the state change.
	### </summary>
	var state : String

	### <summary>
	### The identifier for the stream.
	### </summary>
	var stream : Stream

	### <summary>
	### True if this data was delivered reliably, false otherwise.
	### </summary>
	var reliable : bool

	func _to_string():
		if is_exception(): return get_exception()._to_string()
		return "StreamData<sender=%s, state=%s, stream=%s>" % [sender, state, stream]

	static func create(p_ns : GDScript, p_dict : Dictionary) -> StreamData:
		return _safe_ret(NakamaSerializer.deserialize(p_ns, "StreamData", p_dict), StreamData) as StreamData

	static func get_result_key() -> String:
		return "stream_data"

### <summary>
### An object which represents a connected user in the server.
### </summary>
### <remarks>
### The server allows the same user to be connected with multiple sessions. To uniquely identify them a tuple of
### <c>{ node_id, user_id, session_id }</c> is used which is exposed as this object.
### </remarks>
class UserPresence extends NakamaAsyncResult:

	const _SCHEMA = {
		"persistence": {"name": "persistence", "type": TYPE_BOOL, "required": false},
		"session_id": {"name": "session_id", "type": TYPE_STRING, "required": true},
		"status": {"name": "status", "type": TYPE_STRING, "required": false},
		"username": {"name": "username", "type": TYPE_STRING, "required": false},
		"user_id": {"name": "user_id", "type": TYPE_STRING, "required": true},
	}

	### <summary>
	### If this presence generates stored events like persistent chat messages or notifications.
	### </summary>
	var persistence : bool

	### <summary>
	### The session id of the user.
	### </summary>
	var session_id : String

	### <summary>
	### The status of the user with the presence on the server.
	### </summary>
	var status : String

	### <summary>
	### The username for the user.
	### </summary>
	var username : String

	### <summary>
	### The id of the user.
	### </summary>
	var user_id : String

	func _init(p_ex = null).(p_ex):
		pass

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

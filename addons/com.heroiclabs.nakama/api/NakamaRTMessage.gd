extends RefCounted
class_name NakamaRTMessage

# Send a channel join message to the server.
class ChannelJoin:

	const _SCHEMA = {
		"persistence": {"name": "persistence", "type": TYPE_BOOL, "required": true},
		"hidden": {"name": "hidden", "type": TYPE_BOOL, "required": true},
		"target": {"name": "target", "type": TYPE_STRING, "required": true},
		"type": {"name": "type", "type": TYPE_INT, "required": true},
	}

	enum ChannelType {
		# A chat room which can be created dynamically with a name.
		Room = 1,
		# A private chat between two users.
		DirectMessage = 2,
		# A chat within a group on the server.
		Group = 3
	}

	var persistence : bool
	var hidden : bool
	var target : String
	var type : int

	func _init(p_target : String, p_type : int, p_persistence : bool, p_hidden : bool):
		persistence = p_persistence
		hidden = p_hidden
		target = p_target
		type = p_type if p_type >= ChannelType.Room and p_type <= ChannelType.Group else 0 # Will cause error server side

	func serialize() -> Dictionary:
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "channel_join"

	func _to_string():
		return "ChannelJoin<persistence=%s, hidden=%s, target=%s, type=%d>" % [persistence, hidden, target, type]


# A leave message for a match on the server.
class ChannelLeave extends NakamaAsyncResult:

	const _SCHEMA = {
		"channel_id": {"name": "channel_id", "type": TYPE_STRING, "required": true}
	}
	var channel_id : String

	func _init(p_channel_id : String):
		channel_id = p_channel_id

	func serialize() -> Dictionary:
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "channel_leave"

	func _to_string():
		return "ChannelLeave<channel_id=%s>" % [channel_id]


class ChannelMessageRemove extends NakamaAsyncResult:

	const _SCHEMA = {
		"channel_id": {"name": "channel_id", "type": TYPE_STRING, "required": true},
		"message_id": {"name": "message_id", "type": TYPE_STRING, "required": true}
	}

	var channel_id : String
	var message_id : String

	func _init(p_channel_id : String, p_message_id):
		channel_id = p_channel_id
		message_id = p_message_id

	func serialize() -> Dictionary:
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "channel_message_remove"

	func _to_string():
		return "ChannelMessageRemove<channel_id=%s, message_id=%s>" % [channel_id, message_id]


# Send a chat message to a channel on the server.
class ChannelMessageSend extends NakamaAsyncResult:

	const _SCHEMA = {
		"channel_id": {"name": "channel_id", "type": TYPE_STRING, "required": true},
		"content": {"name": "content", "type": TYPE_STRING, "required": true}
	}

	var channel_id : String
	var content : String

	func _init(p_channel_id : String, p_content):
		channel_id = p_channel_id
		content = p_content

	func serialize() -> Dictionary:
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "channel_message_send"

	func _to_string():
		return "ChannelMessageSend<channel_id=%s, content=%s>" % [channel_id, content]


class ChannelMessageUpdate extends NakamaAsyncResult:

	const _SCHEMA = {
		"channel_id": {"name": "channel_id", "type": TYPE_STRING, "required": true},
		"message_id": {"name": "message_id", "type": TYPE_STRING, "required": true},
		"content": {"name": "content", "type": TYPE_STRING, "required": true}
	}

	var channel_id : String
	var message_id : String
	var content : String

	func _init(p_channel_id : String, p_message_id, p_content : String):
		channel_id = p_channel_id
		message_id = p_message_id
		content = p_content

	func serialize() -> Dictionary:
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "channel_message_update"

	func _to_string():
		return "ChannelMessageUpdate<channel_id=%s, message_id=%s, content=%s>" % [channel_id, message_id, content]


# A create message for a match on the server.
class MatchCreate extends NakamaAsyncResult:

	const _SCHEMA = {
		"name": {"name": "name", "type": TYPE_STRING, "required": false},
	}

	var name = null

	func _init(p_name = null):
		name = p_name if p_name else null

	func serialize():
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "match_create"

	func _to_string():
		return "MatchCreate<name=%s>" % [name]


# A join message for a match on the server.
class MatchJoin extends NakamaAsyncResult:

	const _SCHEMA = {
		"match_id": {"name": "match_id", "type": TYPE_STRING, "required": false},
		"token": {"name": "token", "type": TYPE_STRING, "required": false},
		"metadata": {"name": "metadata", "type": TYPE_DICTIONARY, "required": false, "content": TYPE_STRING},
	}

	# These two are mutually exclusive and set manually by socket for now, so use null.
	var match_id = null
	var token = null
	var metadata = null

	func _init(p_ex=null):
		super(p_ex)

	func serialize() -> Dictionary:
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "match_join"

	func _to_string():
		return "MatchJoin<match_id=%s, token=%s, metadata=%s>" % [match_id, token, metadata]


# A leave message for a match on the server.
class MatchLeave extends NakamaAsyncResult:

	const _SCHEMA = {
		"match_id": {"name": "match_id", "type": TYPE_STRING, "required": true}
	}
	var match_id : String

	func _init(p_match_id : String):
		match_id = p_match_id

	func serialize() -> Dictionary:
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "match_leave"

	func _to_string():
		return "MatchLeave<match_id=%s>" % [match_id]


# Send new state to a match on the server.
class MatchDataSend extends NakamaAsyncResult:

	const _SCHEMA = {
		"match_id": {"name": "match_id", "type": TYPE_STRING, "required": true},
		"op_code": {"name": "op_code", "type": TYPE_INT, "required": true},
		"presences": {"name": "presences", "type": TYPE_ARRAY, "required": false, "content": "UserPresence"},
		"data": {"name": "data", "type": TYPE_STRING, "required": true},
	}

	var match_id : String
	var presences = null
	var op_code : int
	var data : String

	func _init(p_match_id : String, p_op_code : int, p_data : String, p_presences):
		match_id = p_match_id
		presences = p_presences
		op_code = p_op_code
		data = p_data

	func serialize():
		return NakamaSerializer.serialize(self)

	func get_msg_key():
		return "match_data_send"

	func _to_string():
		return "MatchDataSend<match_id=%s, op_code=%s, presences=%s, data=%s>" % [match_id, op_code, presences, data]


# Add the user to the matchmaker pool with properties.
class MatchmakerAdd extends NakamaAsyncResult:

	const _SCHEMA = {
		"query": {"name": "query", "type": TYPE_STRING, "required": true},
		"max_count": {"name": "max_count", "type": TYPE_INT, "required": true},
		"min_count": {"name": "min_count", "type": TYPE_INT, "required": true},
		"numeric_properties": {"name": "numeric_properties", "type": TYPE_DICTIONARY, "required": false, "content": TYPE_FLOAT},
		"string_properties": {"name": "string_properties", "type": TYPE_DICTIONARY, "required": false, "content": TYPE_STRING},
		"count_multiple": {"name": "count_multiple", "type": TYPE_INT, "required": false},
	}

	var query : String = "*"
	var max_count : int = 8
	var min_count : int = 2
	var string_properties : Dictionary
	var numeric_properties : Dictionary
	var count_multiple

	func _init(p_query : String = "*", p_min_count : int = 2, p_max_count : int = 8,
			p_string_props : Dictionary = Dictionary(), p_numeric_props : Dictionary = Dictionary(),
			p_count_multiple : int = 0):
		query = p_query
		min_count = p_min_count
		max_count = p_max_count
		string_properties = p_string_props
		numeric_properties = p_numeric_props
		count_multiple = p_count_multiple if p_count_multiple > 0 else null

	func serialize() -> Dictionary:
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "matchmaker_add"

	func _to_string():
		return "MatchmakerAdd<query=%s, max_count=%d, min_count=%d, numeric_properties=%s, string_properties=%s, count_multiple=%s>" % [query, max_count, min_count, numeric_properties, string_properties, count_multiple]


# Remove the user from the matchmaker pool by ticket.
class MatchmakerRemove extends NakamaAsyncResult:

	const _SCHEMA = {
		"ticket": {"name": "ticket", "type": TYPE_STRING, "required": true}
	}

	var ticket : String

	func _init(p_ticket : String):
		ticket = p_ticket

	func serialize():
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "matchmaker_remove"

	func _to_string():
		return "MatchmakerRemove<ticket=%s>" % [ticket]


# Follow one or more other users for status updates.
class StatusFollow extends NakamaAsyncResult:

	const _SCHEMA = {
		"user_ids": {"name": "user_ids", "type": TYPE_DICTIONARY, "required": false, "content": TYPE_STRING},
		"usernames": {"name": "usernames", "type": TYPE_DICTIONARY, "required": false, "content": TYPE_STRING},
	}

	var user_ids := PackedStringArray()
	var usernames := PackedStringArray()

	func _init(p_ids : PackedStringArray, p_usernames : PackedStringArray):
		user_ids = p_ids
		usernames = p_usernames

	func serialize():
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "status_follow"

	func _to_string():
		return "StatusFollow<user_ids=%s, usernames=%s>" % [user_ids, usernames]


# Unfollow one or more users on the server.
class StatusUnfollow extends NakamaAsyncResult:

	const _SCHEMA = {
		"user_ids": {"name": "user_ids", "type": TYPE_DICTIONARY, "required": false, "content": TYPE_STRING},
	}

	var user_ids := PackedStringArray()

	func _init(p_ids : PackedStringArray):
		user_ids = p_ids

	func serialize():
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "status_unfollow"

	func _to_string():
		return "StatusUnfollow<user_ids=%s>" % [user_ids]


# Unfollow one or more users on the server.
class StatusUpdate extends NakamaAsyncResult:

	const _SCHEMA = {
		"status": {"name": "status", "type": TYPE_STRING, "required": true},
	}

	var status : String

	func _init(p_status : String):
		status = p_status

	func serialize():
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "status_update"

	func _to_string():
		return "StatusUpdate<status=%s>" % [status]

# Create a party.
class PartyCreate extends NakamaAsyncResult:

	const _SCHEMA = {
		"open": {"name": "open", "type": TYPE_BOOL, "required": true},
		"max_size": {"name": "max_size", "type": TYPE_INT, "required": true},
	}
	# Whether or not the party will require join requests to be approved by the party leader.
	var open : bool
	# Maximum number of party members.
	var max_size : int

	func _init(p_open : bool, p_max_size : int):
		open = p_open
		max_size = p_max_size

	func serialize():
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "party_create"

	func _to_string():
		return "PartyCreate<open=%s, max_size=%d>" % [open, max_size]


# Join a party, or request to join if the party is not open.
class PartyJoin extends NakamaAsyncResult:

	const _SCHEMA = {
		"party_id": {"name": "party_id", "type": TYPE_STRING, "required": true},
	}
	# Party ID to join.
	var party_id : String

	func _init(p_id : String):
		party_id = p_id

	func serialize():
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "party_join"

	func _to_string():
		return "PartyJoin<party_id=%s>" % [party_id]


# Leave a party.
class PartyLeave extends NakamaAsyncResult:

	const _SCHEMA = {
		"party_id": {"name": "party_id", "type": TYPE_STRING, "required": true},
	}
	# Party ID to leave.
	var party_id : String

	func _init(p_id : String):
		party_id = p_id

	func serialize():
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "party_leave"

	func _to_string():
		return "PartyLeave<party_id=%s>" % [party_id]


# Promote a new party leader.
class PartyPromote extends NakamaAsyncResult:

	const _SCHEMA = {
		"party_id": {"name": "party_id", "type": TYPE_STRING, "required": true},
		"presence": {"name": "presence", "type": "UserPresence", "required": true},
	}
	# Party ID to promote a new leader for.
	var party_id : String
	# The presence of an existing party member to promote as the new leader.
	var presence : NakamaRTAPI.UserPresence

	func _init(p_id : String, p_presence : NakamaRTAPI.UserPresence):
		party_id = p_id
		presence = p_presence

	func serialize():
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "party_promote"

	func _to_string():
		return "PartyPromote<party_id=%s, presence=%s>" % [party_id, presence]


# Accept a request to join.
class PartyAccept extends NakamaAsyncResult:
	const _SCHEMA = {
		"party_id": {"name": "party_id", "type": TYPE_STRING, "required": true},
		"presence": {"name": "presence", "type": "UserPresence", "required": true},
	}
	# Party ID to accept a join request for.
	var party_id : String
	# The presence to accept as a party member.
	var presence : NakamaRTAPI.UserPresence

	func _init(p_id : String, p_presence : NakamaRTAPI.UserPresence):
		party_id = p_id
		presence = p_presence

	func serialize():
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "party_accept"

	func _to_string():
		return "PartyAccept<party_id=%s, presence=%s>" % [party_id, presence]


# Kick a party member, or decline a request to join.
class PartyRemove extends NakamaAsyncResult:
	const _SCHEMA = {
		"party_id": {"name": "party_id", "type": TYPE_STRING, "required": true},
		"presence": {"name": "presence", "type": "UserPresence", "required": true},
	}
	# Party ID to remove/reject from.
	var party_id : String
	# The presence to remove or reject.
	var presence : NakamaRTAPI.UserPresence

	func _init(p_id : String, p_presence : NakamaRTAPI.UserPresence):
		party_id = p_id
		presence = p_presence

	func serialize():
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "party_remove"

	func _to_string():
		return "PartyRemove<party_id=%s, presence=%s>" % [party_id, presence]


# Request a list of pending join requests for a party.
class PartyJoinRequestList extends NakamaAsyncResult:
	const _SCHEMA = {
		"party_id": {"name": "party_id", "type": TYPE_STRING, "required": true},
	}
	# Party ID to get a list of join requests for.
	var party_id : String

	func _init(p_id : String):
		party_id = p_id

	func serialize():
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "party_join_request_list"

	func _to_string():
		return "PartyJoinRequestList<party_id=%s>" % [party_id]


# Begin matchmaking as a party.
class PartyMatchmakerAdd extends NakamaAsyncResult:

	const _SCHEMA = {
		"party_id": {"name": "party_id", "type": TYPE_STRING, "required": true},
		"min_count": {"name": "min_count", "type": TYPE_INT, "required": true},
		"max_count": {"name": "max_count", "type": TYPE_INT, "required": true},
		"query": {"name": "query", "type": TYPE_STRING, "required": false},
		"string_properties": {"name": "string_properties", "type": TYPE_DICTIONARY, "required": false, "content": TYPE_STRING},
		"numeric_properties": {"name": "numeric_properties", "type": TYPE_DICTIONARY, "required": false, "content": TYPE_FLOAT},
	}

	# Party ID.
	var party_id : String
	# Minimum total user count to match together.
	var min_count : int
	# Maximum total user count to match together.
	var max_count : int
	# Filter query used to identify suitable users.
	var query : String
	# String properties.
	var string_properties : Dictionary
	# Numeric properties.
	var numeric_properties : Dictionary
	# Optional multiple of the count that must be satisfied.
	var count_multiple

	func _init(p_id : String, p_min_count : int, p_max_count : int, p_query : String, p_string_properties = null, p_numeric_properties = null, p_count_multiple = null):
		party_id = p_id
		min_count = p_min_count
		max_count = p_max_count
		query = p_query
		string_properties = p_string_properties
		numeric_properties = p_numeric_properties
		count_multiple = p_count_multiple

	func serialize():
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "party_matchmaker_add"

	func _to_string():
		return "PartyMatchmakerAdd<party_id=%s, min_count=%d, max_count=%d, query=%s, string_properties=%s, numeric_properties=%s, count_multiple=%s>" % [party_id, min_count, max_count, query, string_properties, numeric_properties, count_multiple]


# Cancel a party matchmaking process using a ticket.
class PartyMatchmakerRemove extends NakamaAsyncResult:
	const _SCHEMA = {
		"party_id": {"name": "party_id", "type": TYPE_STRING, "required": true},
		"ticket": {"name": "ticket", "type": TYPE_STRING, "required": true},
	}
	# Party ID.
	var party_id : String
	# The ticket to cancel.
	var ticket : String

	func _init(p_id : String, p_ticket : String):
		party_id = p_id
		ticket = p_ticket

	func serialize():
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "party_matchmaker_remove"

	func _to_string():
		return "PartyMatchmakerRemove<party_id=%s, ticket=%s>" % [party_id, ticket]


# Send data to a party.
class PartyDataSend extends NakamaAsyncResult:
	const _SCHEMA = {
		"party_id": {"name": "party_id", "type": TYPE_STRING, "required": true},
		"op_code": {"name": "op_code", "type": TYPE_INT, "required": true},
		"data": {"name": "data", "type": TYPE_STRING, "required": false}
	}
	# Party ID to send to.
	var party_id : String
	# Op code value.
	var op_code : int
	# Data payload, if any.
	var data = null

	func _init(p_id : String, p_op_code : int, p_data = null):
		party_id = p_id
		op_code = p_op_code
		data = p_data

	func serialize():
		return NakamaSerializer.serialize(self)

	func get_msg_key() -> String:
		return "party_data_send"

	func _to_string():
		return "PartyDataSend<party_id=%s, op_code=%d, data=%s>" % [party_id, op_code, data]

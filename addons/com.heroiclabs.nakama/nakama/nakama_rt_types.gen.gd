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

# Code generated from the Nakama protos. DO NOT EDIT.
class_name NakamaRtTypes
extends RefCounted

## The type of chat channel.
enum ChannelJoinType {
	TYPE_UNSPECIFIED = 0,
	ROOM = 1,
	DIRECT_MESSAGE = 2,
	GROUP = 3,
}

## The selection of possible error codes.
enum ErrorCode {
	RUNTIME_EXCEPTION = 0,
	UNRECOGNIZED_PAYLOAD = 1,
	MISSING_PAYLOAD = 2,
	BAD_INPUT = 3,
	MATCH_NOT_FOUND = 4,
	MATCH_JOIN_REJECTED = 5,
	RUNTIME_FUNCTION_NOT_FOUND = 6,
	RUNTIME_FUNCTION_EXCEPTION = 7,
}


## A user session associated with a stream, usually through a list operation or a join/leave event.
class UserPresence:
	extends RefCounted
	var user_id: String
	var session_id: String
	var username: String
	var persistence: bool
	## String, or null when unset.
	var status: Variant


	static func from_json(_json: Variant) -> UserPresence:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := UserPresence.new()
		_message.user_id = _data.get("user_id", "")
		_message.session_id = _data.get("session_id", "")
		_message.username = _data.get("username", "")
		_message.persistence = _data.get("persistence", false)
		_message.status = _data["status"] if _data.get("status") != null else null
		return _message


	func _init(p_user_id: String = "", p_session_id: String = "", p_username: String = "",
			p_persistence: bool = false, p_status: Variant = null) -> void:
		user_id = p_user_id
		session_id = p_session_id
		username = p_username
		persistence = p_persistence
		status = p_status


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not user_id.is_empty():
			_fields.append('"user_id":' + JSON.stringify(user_id))
		if not session_id.is_empty():
			_fields.append('"session_id":' + JSON.stringify(session_id))
		if not username.is_empty():
			_fields.append('"username":' + JSON.stringify(username))
		if persistence:
			_fields.append('"persistence":' + JSON.stringify(persistence))
		if status != null:
			_fields.append('"status":' + JSON.stringify(status))
		return "{%s}" % ",".join(_fields)


## A realtime chat channel.
class Channel:
	extends RefCounted
	var id: String
	var self_: UserPresence
	var room_name: String
	var group_id: String
	var user_id_one: String
	var user_id_two: String
	var presences: Array = []


	static func from_json(_json: Variant) -> Channel:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Channel.new()
		_message.id = _data.get("id", "")
		_message.self_ = UserPresence.from_json(_data["self"]) if _data.get("self") != null else null
		_message.room_name = _data.get("room_name", "")
		_message.group_id = _data.get("group_id", "")
		_message.user_id_one = _data.get("user_id_one", "")
		_message.user_id_two = _data.get("user_id_two", "")
		var _list_presences: Array = _data.get("presences", [])
		_message.presences = _list_presences.map(func(_v: Variant) -> UserPresence: return UserPresence.from_json(_v))
		return _message


	func _init(p_id: String = "", p_presences: Array = [], p_self_: UserPresence = null,
			p_room_name: String = "", p_group_id: String = "", p_user_id_one: String = "",
			p_user_id_two: String = "") -> void:
		id = p_id
		presences = p_presences
		self_ = p_self_
		room_name = p_room_name
		group_id = p_group_id
		user_id_one = p_user_id_one
		user_id_two = p_user_id_two


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not id.is_empty():
			_fields.append('"id":' + JSON.stringify(id))
		if self_ != null:
			_fields.append('"self":' + self_.to_json())
		if not room_name.is_empty():
			_fields.append('"room_name":' + JSON.stringify(room_name))
		if not group_id.is_empty():
			_fields.append('"group_id":' + JSON.stringify(group_id))
		if not user_id_one.is_empty():
			_fields.append('"user_id_one":' + JSON.stringify(user_id_one))
		if not user_id_two.is_empty():
			_fields.append('"user_id_two":' + JSON.stringify(user_id_two))
		_fields.append('"presences":[%s]' % ",".join(PackedStringArray(presences.map(func(_v: UserPresence) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Join operation for a realtime chat channel.
class ChannelJoin:
	extends RefCounted
	var target: String
	var type: int
	## bool, or null when unset.
	var persistence: Variant
	## bool, or null when unset.
	var hidden: Variant


	static func from_json(_json: Variant) -> ChannelJoin:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ChannelJoin.new()
		_message.target = _data.get("target", "")
		_message.type = type_convert(_data.get("type", 0), TYPE_INT)
		_message.persistence = _data["persistence"] if _data.get("persistence") != null else null
		_message.hidden = _data["hidden"] if _data.get("hidden") != null else null
		return _message


	func _init(p_target: String = "", p_type: int = 0, p_persistence: Variant = null,
			p_hidden: Variant = null) -> void:
		target = p_target
		type = p_type
		persistence = p_persistence
		hidden = p_hidden


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not target.is_empty():
			_fields.append('"target":' + JSON.stringify(target))
		if type != 0:
			_fields.append('"type":' + JSON.stringify(type))
		if persistence != null:
			_fields.append('"persistence":' + JSON.stringify(persistence))
		if hidden != null:
			_fields.append('"hidden":' + JSON.stringify(hidden))
		return "{%s}" % ",".join(_fields)


## Leave a realtime channel.
class ChannelLeave:
	extends RefCounted
	var channel_id: String


	static func from_json(_json: Variant) -> ChannelLeave:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ChannelLeave.new()
		_message.channel_id = _data.get("channel_id", "")
		return _message


	func _init(p_channel_id: String = "") -> void:
		channel_id = p_channel_id


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not channel_id.is_empty():
			_fields.append('"channel_id":' + JSON.stringify(channel_id))
		return "{%s}" % ",".join(_fields)


## A receipt reply from a channel message send operation.
class ChannelMessageAck:
	extends RefCounted
	var channel_id: String
	var message_id: String
	## int, or null when unset.
	var code: Variant
	var username: String
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var create_time: Variant
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var update_time: Variant
	## bool, or null when unset.
	var persistent: Variant
	var room_name: String
	var group_id: String
	var user_id_one: String
	var user_id_two: String


	static func from_json(_json: Variant) -> ChannelMessageAck:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ChannelMessageAck.new()
		_message.channel_id = _data.get("channel_id", "")
		_message.message_id = _data.get("message_id", "")
		_message.code = type_convert(_data["code"], TYPE_INT) if _data.get("code") != null else null
		_message.username = _data.get("username", "")
		_message.create_time = _data.get("create_time")
		_message.update_time = _data.get("update_time")
		_message.persistent = _data["persistent"] if _data.get("persistent") != null else null
		_message.room_name = _data.get("room_name", "")
		_message.group_id = _data.get("group_id", "")
		_message.user_id_one = _data.get("user_id_one", "")
		_message.user_id_two = _data.get("user_id_two", "")
		return _message


	func _init(p_channel_id: String = "", p_message_id: String = "", p_code: Variant = null,
			p_username: String = "", p_create_time: Variant = null, p_update_time: Variant = null,
			p_persistent: Variant = null, p_room_name: String = "", p_group_id: String = "",
			p_user_id_one: String = "", p_user_id_two: String = "") -> void:
		channel_id = p_channel_id
		message_id = p_message_id
		code = p_code
		username = p_username
		create_time = p_create_time
		update_time = p_update_time
		persistent = p_persistent
		room_name = p_room_name
		group_id = p_group_id
		user_id_one = p_user_id_one
		user_id_two = p_user_id_two


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not channel_id.is_empty():
			_fields.append('"channel_id":' + JSON.stringify(channel_id))
		if not message_id.is_empty():
			_fields.append('"message_id":' + JSON.stringify(message_id))
		if code != null:
			_fields.append('"code":' + JSON.stringify(code))
		if not username.is_empty():
			_fields.append('"username":' + JSON.stringify(username))
		if create_time != null:
			_fields.append('"create_time":' + JSON.stringify(create_time))
		if update_time != null:
			_fields.append('"update_time":' + JSON.stringify(update_time))
		if persistent != null:
			_fields.append('"persistent":' + JSON.stringify(persistent))
		if not room_name.is_empty():
			_fields.append('"room_name":' + JSON.stringify(room_name))
		if not group_id.is_empty():
			_fields.append('"group_id":' + JSON.stringify(group_id))
		if not user_id_one.is_empty():
			_fields.append('"user_id_one":' + JSON.stringify(user_id_one))
		if not user_id_two.is_empty():
			_fields.append('"user_id_two":' + JSON.stringify(user_id_two))
		return "{%s}" % ",".join(_fields)


## Send a message to a realtime channel.
class ChannelMessageSend:
	extends RefCounted
	var channel_id: String
	var content: String


	static func from_json(_json: Variant) -> ChannelMessageSend:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ChannelMessageSend.new()
		_message.channel_id = _data.get("channel_id", "")
		_message.content = _data.get("content", "")
		return _message


	func _init(p_channel_id: String = "", p_content: String = "") -> void:
		channel_id = p_channel_id
		content = p_content


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not channel_id.is_empty():
			_fields.append('"channel_id":' + JSON.stringify(channel_id))
		if not content.is_empty():
			_fields.append('"content":' + JSON.stringify(content))
		return "{%s}" % ",".join(_fields)


## Update a message previously sent to a realtime channel.
class ChannelMessageUpdate:
	extends RefCounted
	var channel_id: String
	var message_id: String
	var content: String


	static func from_json(_json: Variant) -> ChannelMessageUpdate:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ChannelMessageUpdate.new()
		_message.channel_id = _data.get("channel_id", "")
		_message.message_id = _data.get("message_id", "")
		_message.content = _data.get("content", "")
		return _message


	func _init(p_channel_id: String = "", p_message_id: String = "",
			p_content: String = "") -> void:
		channel_id = p_channel_id
		message_id = p_message_id
		content = p_content


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not channel_id.is_empty():
			_fields.append('"channel_id":' + JSON.stringify(channel_id))
		if not message_id.is_empty():
			_fields.append('"message_id":' + JSON.stringify(message_id))
		if not content.is_empty():
			_fields.append('"content":' + JSON.stringify(content))
		return "{%s}" % ",".join(_fields)


## Remove a message previously sent to a realtime channel.
class ChannelMessageRemove:
	extends RefCounted
	var channel_id: String
	var message_id: String


	static func from_json(_json: Variant) -> ChannelMessageRemove:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ChannelMessageRemove.new()
		_message.channel_id = _data.get("channel_id", "")
		_message.message_id = _data.get("message_id", "")
		return _message


	func _init(p_channel_id: String = "", p_message_id: String = "") -> void:
		channel_id = p_channel_id
		message_id = p_message_id


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not channel_id.is_empty():
			_fields.append('"channel_id":' + JSON.stringify(channel_id))
		if not message_id.is_empty():
			_fields.append('"message_id":' + JSON.stringify(message_id))
		return "{%s}" % ",".join(_fields)


## A set of joins and leaves on a particular channel.
class ChannelPresenceEvent:
	extends RefCounted
	var channel_id: String
	var room_name: String
	var group_id: String
	var user_id_one: String
	var user_id_two: String
	var joins: Array = []
	var leaves: Array = []


	static func from_json(_json: Variant) -> ChannelPresenceEvent:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ChannelPresenceEvent.new()
		_message.channel_id = _data.get("channel_id", "")
		_message.room_name = _data.get("room_name", "")
		_message.group_id = _data.get("group_id", "")
		_message.user_id_one = _data.get("user_id_one", "")
		_message.user_id_two = _data.get("user_id_two", "")
		var _list_joins: Array = _data.get("joins", [])
		_message.joins = _list_joins.map(func(_v: Variant) -> UserPresence: return UserPresence.from_json(_v))
		var _list_leaves: Array = _data.get("leaves", [])
		_message.leaves = _list_leaves.map(func(_v: Variant) -> UserPresence: return UserPresence.from_json(_v))
		return _message


	func _init(p_channel_id: String = "", p_joins: Array = [], p_leaves: Array = [],
			p_room_name: String = "", p_group_id: String = "", p_user_id_one: String = "",
			p_user_id_two: String = "") -> void:
		channel_id = p_channel_id
		joins = p_joins
		leaves = p_leaves
		room_name = p_room_name
		group_id = p_group_id
		user_id_one = p_user_id_one
		user_id_two = p_user_id_two


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not channel_id.is_empty():
			_fields.append('"channel_id":' + JSON.stringify(channel_id))
		if not room_name.is_empty():
			_fields.append('"room_name":' + JSON.stringify(room_name))
		if not group_id.is_empty():
			_fields.append('"group_id":' + JSON.stringify(group_id))
		if not user_id_one.is_empty():
			_fields.append('"user_id_one":' + JSON.stringify(user_id_one))
		if not user_id_two.is_empty():
			_fields.append('"user_id_two":' + JSON.stringify(user_id_two))
		_fields.append('"joins":[%s]' % ",".join(PackedStringArray(joins.map(func(_v: UserPresence) -> String: return _v.to_json()))))
		_fields.append('"leaves":[%s]' % ",".join(PackedStringArray(leaves.map(func(_v: UserPresence) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## A logical error which may occur on the server.
class Error_:
	extends RefCounted
	var code: int
	var message: String
	var context: Dictionary = {}


	static func from_json(_json: Variant) -> Error_:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Error_.new()
		_message.code = type_convert(_data.get("code", 0), TYPE_INT)
		_message.message = _data.get("message", "")
		var _map_context: Dictionary = _data.get("context", {})
		for _k: Variant in _map_context:
			_message.context[_k] = _map_context[_k]
		return _message


	func _init(p_code: int = 0, p_message: String = "", p_context: Dictionary = {}) -> void:
		code = p_code
		message = p_message
		context = p_context


	func to_json() -> String:
		var _fields := PackedStringArray()
		if code != 0:
			_fields.append('"code":' + JSON.stringify(code))
		if not message.is_empty():
			_fields.append('"message":' + JSON.stringify(message))
		var _map_context := PackedStringArray()
		for _k: Variant in context:
			var _v: String = str(context[_k])
			_map_context.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"context":{%s}' % ",".join(_map_context))
		return "{%s}" % ",".join(_fields)


## A realtime match.
class Match:
	extends RefCounted
	var match_id: String
	var authoritative: bool
	## String, or null when unset.
	var label: Variant
	var size: int
	var self_: UserPresence
	var presences: Array = []


	static func from_json(_json: Variant) -> Match:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Match.new()
		_message.match_id = _data.get("match_id", "")
		_message.authoritative = _data.get("authoritative", false)
		_message.label = _data["label"] if _data.get("label") != null else null
		_message.size = type_convert(_data.get("size", 0), TYPE_INT)
		_message.self_ = UserPresence.from_json(_data["self"]) if _data.get("self") != null else null
		var _list_presences: Array = _data.get("presences", [])
		_message.presences = _list_presences.map(func(_v: Variant) -> UserPresence: return UserPresence.from_json(_v))
		return _message


	func _init(p_match_id: String = "", p_authoritative: bool = false, p_label: Variant = null,
			p_size: int = 0, p_presences: Array = [], p_self_: UserPresence = null) -> void:
		match_id = p_match_id
		authoritative = p_authoritative
		label = p_label
		size = p_size
		presences = p_presences
		self_ = p_self_


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not match_id.is_empty():
			_fields.append('"match_id":' + JSON.stringify(match_id))
		if authoritative:
			_fields.append('"authoritative":' + JSON.stringify(authoritative))
		if label != null:
			_fields.append('"label":' + JSON.stringify(label))
		if size != 0:
			_fields.append('"size":' + JSON.stringify(size))
		if self_ != null:
			_fields.append('"self":' + self_.to_json())
		_fields.append('"presences":[%s]' % ",".join(PackedStringArray(presences.map(func(_v: UserPresence) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Create a new realtime match.
class MatchCreate:
	extends RefCounted
	var name: String


	static func from_json(_json: Variant) -> MatchCreate:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := MatchCreate.new()
		_message.name = _data.get("name", "")
		return _message


	func _init(p_name: String = "") -> void:
		name = p_name


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not name.is_empty():
			_fields.append('"name":' + JSON.stringify(name))
		return "{%s}" % ",".join(_fields)


## Realtime match data received from the server.
class MatchData:
	extends RefCounted
	var match_id: String
	var presence: UserPresence
	var op_code: int
	var data: PackedByteArray
	var reliable: bool


	static func from_json(_json: Variant) -> MatchData:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := MatchData.new()
		_message.match_id = _data.get("match_id", "")
		_message.presence = UserPresence.from_json(_data["presence"]) if _data.get("presence") != null else null
		_message.op_code = type_convert(_data.get("op_code", 0), TYPE_INT)
		_message.data = Marshalls.base64_to_raw(str(_data.get("data", "")))
		_message.reliable = _data.get("reliable", false)
		return _message


	func _init(p_match_id: String = "", p_presence: UserPresence = null, p_op_code: int = 0,
			p_data: PackedByteArray = PackedByteArray(), p_reliable: bool = false) -> void:
		match_id = p_match_id
		presence = p_presence
		op_code = p_op_code
		data = p_data
		reliable = p_reliable


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not match_id.is_empty():
			_fields.append('"match_id":' + JSON.stringify(match_id))
		if presence != null:
			_fields.append('"presence":' + presence.to_json())
		if op_code != 0:
			_fields.append('"op_code":' + JSON.stringify(op_code))
		if not data.is_empty():
			var _data: PackedByteArray = data
			_fields.append('"data":' + JSON.stringify(Marshalls.raw_to_base64(_data)))
		if reliable:
			_fields.append('"reliable":' + JSON.stringify(reliable))
		return "{%s}" % ",".join(_fields)


## Send realtime match data to the server.
class MatchDataSend:
	extends RefCounted
	var match_id: String
	var op_code: int
	var data: PackedByteArray
	var reliable: bool
	var presences: Array = []


	static func from_json(_json: Variant) -> MatchDataSend:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := MatchDataSend.new()
		_message.match_id = _data.get("match_id", "")
		_message.op_code = type_convert(_data.get("op_code", 0), TYPE_INT)
		_message.data = Marshalls.base64_to_raw(str(_data.get("data", "")))
		_message.reliable = _data.get("reliable", false)
		var _list_presences: Array = _data.get("presences", [])
		_message.presences = _list_presences.map(func(_v: Variant) -> UserPresence: return UserPresence.from_json(_v))
		return _message


	func _init(p_match_id: String = "", p_op_code: int = 0,
			p_data: PackedByteArray = PackedByteArray(), p_presences: Array = [],
			p_reliable: bool = false) -> void:
		match_id = p_match_id
		op_code = p_op_code
		data = p_data
		presences = p_presences
		reliable = p_reliable


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not match_id.is_empty():
			_fields.append('"match_id":' + JSON.stringify(match_id))
		if op_code != 0:
			_fields.append('"op_code":' + JSON.stringify(op_code))
		if not data.is_empty():
			var _data: PackedByteArray = data
			_fields.append('"data":' + JSON.stringify(Marshalls.raw_to_base64(_data)))
		if reliable:
			_fields.append('"reliable":' + JSON.stringify(reliable))
		_fields.append('"presences":[%s]' % ",".join(PackedStringArray(presences.map(func(_v: UserPresence) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Join an existing realtime match.
class MatchJoin:
	extends RefCounted
	## String, or null when unset.
	var match_id: Variant
	## String, or null when unset.
	var token: Variant
	var metadata: Dictionary = {}


	static func from_json(_json: Variant) -> MatchJoin:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := MatchJoin.new()
		_message.match_id = _data["match_id"] if _data.get("match_id") != null else null
		_message.token = _data["token"] if _data.get("token") != null else null
		var _map_metadata: Dictionary = _data.get("metadata", {})
		for _k: Variant in _map_metadata:
			_message.metadata[_k] = _map_metadata[_k]
		return _message


	func _init(p_match_id: Variant = null, p_token: Variant = null,
			p_metadata: Dictionary = {}) -> void:
		match_id = p_match_id
		token = p_token
		metadata = p_metadata


	func to_json() -> String:
		var _fields := PackedStringArray()
		if match_id != null:
			_fields.append('"match_id":' + JSON.stringify(match_id))
		if token != null:
			_fields.append('"token":' + JSON.stringify(token))
		var _map_metadata := PackedStringArray()
		for _k: Variant in metadata:
			var _v: String = str(metadata[_k])
			_map_metadata.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"metadata":{%s}' % ",".join(_map_metadata))
		return "{%s}" % ",".join(_fields)


## Leave a realtime match.
class MatchLeave:
	extends RefCounted
	var match_id: String


	static func from_json(_json: Variant) -> MatchLeave:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := MatchLeave.new()
		_message.match_id = _data.get("match_id", "")
		return _message


	func _init(p_match_id: String = "") -> void:
		match_id = p_match_id


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not match_id.is_empty():
			_fields.append('"match_id":' + JSON.stringify(match_id))
		return "{%s}" % ",".join(_fields)


## A set of joins and leaves on a particular realtime match.
class MatchPresenceEvent:
	extends RefCounted
	var match_id: String
	var joins: Array = []
	var leaves: Array = []


	static func from_json(_json: Variant) -> MatchPresenceEvent:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := MatchPresenceEvent.new()
		_message.match_id = _data.get("match_id", "")
		var _list_joins: Array = _data.get("joins", [])
		_message.joins = _list_joins.map(func(_v: Variant) -> UserPresence: return UserPresence.from_json(_v))
		var _list_leaves: Array = _data.get("leaves", [])
		_message.leaves = _list_leaves.map(func(_v: Variant) -> UserPresence: return UserPresence.from_json(_v))
		return _message


	func _init(p_match_id: String = "", p_joins: Array = [], p_leaves: Array = []) -> void:
		match_id = p_match_id
		joins = p_joins
		leaves = p_leaves


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not match_id.is_empty():
			_fields.append('"match_id":' + JSON.stringify(match_id))
		_fields.append('"joins":[%s]' % ",".join(PackedStringArray(joins.map(func(_v: UserPresence) -> String: return _v.to_json()))))
		_fields.append('"leaves":[%s]' % ",".join(PackedStringArray(leaves.map(func(_v: UserPresence) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Start a new matchmaking process.
class MatchmakerAdd:
	extends RefCounted
	var min_count: int
	var max_count: int
	var query: String
	## int, or null when unset.
	var count_multiple: Variant
	var string_properties: Dictionary = {}
	var numeric_properties: Dictionary = {}


	static func from_json(_json: Variant) -> MatchmakerAdd:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := MatchmakerAdd.new()
		_message.min_count = type_convert(_data.get("min_count", 0), TYPE_INT)
		_message.max_count = type_convert(_data.get("max_count", 0), TYPE_INT)
		_message.query = _data.get("query", "")
		_message.count_multiple = type_convert(_data["count_multiple"], TYPE_INT) if _data.get("count_multiple") != null else null
		var _map_string_properties: Dictionary = _data.get("string_properties", {})
		for _k: Variant in _map_string_properties:
			_message.string_properties[_k] = _map_string_properties[_k]
		var _map_numeric_properties: Dictionary = _data.get("numeric_properties", {})
		for _k: Variant in _map_numeric_properties:
			_message.numeric_properties[_k] = {"NaN": NAN, "Infinity": INF, "-Infinity": -INF}.get(_map_numeric_properties[_k], type_convert(_map_numeric_properties[_k], TYPE_FLOAT))
		return _message


	func _init(p_min_count: int = 0, p_max_count: int = 0, p_query: String = "",
			p_string_properties: Dictionary = {}, p_numeric_properties: Dictionary = {},
			p_count_multiple: Variant = null) -> void:
		min_count = p_min_count
		max_count = p_max_count
		query = p_query
		string_properties = p_string_properties
		numeric_properties = p_numeric_properties
		count_multiple = p_count_multiple


	func to_json() -> String:
		var _fields := PackedStringArray()
		if min_count != 0:
			_fields.append('"min_count":' + JSON.stringify(min_count))
		if max_count != 0:
			_fields.append('"max_count":' + JSON.stringify(max_count))
		if not query.is_empty():
			_fields.append('"query":' + JSON.stringify(query))
		if count_multiple != null:
			_fields.append('"count_multiple":' + JSON.stringify(count_multiple))
		var _map_string_properties := PackedStringArray()
		for _k: Variant in string_properties:
			var _v: String = str(string_properties[_k])
			_map_string_properties.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"string_properties":{%s}' % ",".join(_map_string_properties))
		var _map_numeric_properties := PackedStringArray()
		for _k: Variant in numeric_properties:
			var _v: float = numeric_properties[_k]
			_map_numeric_properties.append(JSON.stringify(str(_k)) + ":" + (JSON.stringify(_v) if is_finite(_v) else '"NaN"' if is_nan(_v) else '"Infinity"' if _v > 0 else '"-Infinity"'))
		_fields.append('"numeric_properties":{%s}' % ",".join(_map_numeric_properties))
		return "{%s}" % ",".join(_fields)


class MatchmakerMatchedMatchmakerUser:
	extends RefCounted
	var presence: UserPresence
	var party_id: String
	var string_properties: Dictionary = {}
	var numeric_properties: Dictionary = {}


	static func from_json(_json: Variant) -> MatchmakerMatchedMatchmakerUser:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := MatchmakerMatchedMatchmakerUser.new()
		_message.presence = UserPresence.from_json(_data["presence"]) if _data.get("presence") != null else null
		_message.party_id = _data.get("party_id", "")
		var _map_string_properties: Dictionary = _data.get("string_properties", {})
		for _k: Variant in _map_string_properties:
			_message.string_properties[_k] = _map_string_properties[_k]
		var _map_numeric_properties: Dictionary = _data.get("numeric_properties", {})
		for _k: Variant in _map_numeric_properties:
			_message.numeric_properties[_k] = {"NaN": NAN, "Infinity": INF, "-Infinity": -INF}.get(_map_numeric_properties[_k], type_convert(_map_numeric_properties[_k], TYPE_FLOAT))
		return _message


	func _init(p_presence: UserPresence = null, p_party_id: String = "",
			p_string_properties: Dictionary = {}, p_numeric_properties: Dictionary = {}) -> void:
		presence = p_presence
		party_id = p_party_id
		string_properties = p_string_properties
		numeric_properties = p_numeric_properties


	func to_json() -> String:
		var _fields := PackedStringArray()
		if presence != null:
			_fields.append('"presence":' + presence.to_json())
		if not party_id.is_empty():
			_fields.append('"party_id":' + JSON.stringify(party_id))
		var _map_string_properties := PackedStringArray()
		for _k: Variant in string_properties:
			var _v: String = str(string_properties[_k])
			_map_string_properties.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"string_properties":{%s}' % ",".join(_map_string_properties))
		var _map_numeric_properties := PackedStringArray()
		for _k: Variant in numeric_properties:
			var _v: float = numeric_properties[_k]
			_map_numeric_properties.append(JSON.stringify(str(_k)) + ":" + (JSON.stringify(_v) if is_finite(_v) else '"NaN"' if is_nan(_v) else '"Infinity"' if _v > 0 else '"-Infinity"'))
		_fields.append('"numeric_properties":{%s}' % ",".join(_map_numeric_properties))
		return "{%s}" % ",".join(_fields)


## A successful matchmaking result.
class MatchmakerMatched:
	extends RefCounted
	var ticket: String
	## String, or null when unset.
	var match_id: Variant
	## String, or null when unset.
	var token: Variant
	var self_: MatchmakerMatchedMatchmakerUser
	var users: Array = []


	static func from_json(_json: Variant) -> MatchmakerMatched:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := MatchmakerMatched.new()
		_message.ticket = _data.get("ticket", "")
		_message.match_id = _data["match_id"] if _data.get("match_id") != null else null
		_message.token = _data["token"] if _data.get("token") != null else null
		_message.self_ = MatchmakerMatchedMatchmakerUser.from_json(_data["self"]) if _data.get("self") != null else null
		var _list_users: Array = _data.get("users", [])
		_message.users = _list_users.map(func(_v: Variant) -> MatchmakerMatchedMatchmakerUser: return MatchmakerMatchedMatchmakerUser.from_json(_v))
		return _message


	func _init(p_ticket: String = "", p_match_id: Variant = null, p_token: Variant = null,
			p_users: Array = [], p_self_: MatchmakerMatchedMatchmakerUser = null) -> void:
		ticket = p_ticket
		match_id = p_match_id
		token = p_token
		users = p_users
		self_ = p_self_


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not ticket.is_empty():
			_fields.append('"ticket":' + JSON.stringify(ticket))
		if match_id != null:
			_fields.append('"match_id":' + JSON.stringify(match_id))
		if token != null:
			_fields.append('"token":' + JSON.stringify(token))
		if self_ != null:
			_fields.append('"self":' + self_.to_json())
		_fields.append('"users":[%s]' % ",".join(PackedStringArray(users.map(func(_v: MatchmakerMatchedMatchmakerUser) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Cancel an existing ongoing matchmaking process.
class MatchmakerRemove:
	extends RefCounted
	var ticket: String


	static func from_json(_json: Variant) -> MatchmakerRemove:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := MatchmakerRemove.new()
		_message.ticket = _data.get("ticket", "")
		return _message


	func _init(p_ticket: String = "") -> void:
		ticket = p_ticket


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not ticket.is_empty():
			_fields.append('"ticket":' + JSON.stringify(ticket))
		return "{%s}" % ",".join(_fields)


## A ticket representing a new matchmaking process.
class MatchmakerTicket:
	extends RefCounted
	var ticket: String


	static func from_json(_json: Variant) -> MatchmakerTicket:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := MatchmakerTicket.new()
		_message.ticket = _data.get("ticket", "")
		return _message


	func _init(p_ticket: String = "") -> void:
		ticket = p_ticket


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not ticket.is_empty():
			_fields.append('"ticket":' + JSON.stringify(ticket))
		return "{%s}" % ",".join(_fields)


## A collection of zero or more notifications.
class Notifications:
	extends RefCounted
	var notifications: Array = []


	static func from_json(_json: Variant) -> Notifications:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Notifications.new()
		var _list_notifications: Array = _data.get("notifications", [])
		_message.notifications = _list_notifications.map(func(_v: Variant) -> NakamaTypes.Notification: return NakamaTypes.Notification.from_json(_v))
		return _message


	func _init(p_notifications: Array = []) -> void:
		notifications = p_notifications


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"notifications":[%s]' % ",".join(PackedStringArray(notifications.map(func(_v: NakamaTypes.Notification) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## A snapshot of statuses for some set of users.
class Status:
	extends RefCounted
	var presences: Array = []


	static func from_json(_json: Variant) -> Status:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Status.new()
		var _list_presences: Array = _data.get("presences", [])
		_message.presences = _list_presences.map(func(_v: Variant) -> UserPresence: return UserPresence.from_json(_v))
		return _message


	func _init(p_presences: Array = []) -> void:
		presences = p_presences


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"presences":[%s]' % ",".join(PackedStringArray(presences.map(func(_v: UserPresence) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Start receiving status updates for some set of users.
class StatusFollow:
	extends RefCounted
	var user_ids: Array = []
	var usernames: Array = []


	static func from_json(_json: Variant) -> StatusFollow:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := StatusFollow.new()
		_message.user_ids = _data.get("user_ids", [])
		_message.usernames = _data.get("usernames", [])
		return _message


	func _init(p_user_ids: Array = [], p_usernames: Array = []) -> void:
		user_ids = p_user_ids
		usernames = p_usernames


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"user_ids":[%s]' % ",".join(PackedStringArray(user_ids.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		_fields.append('"usernames":[%s]' % ",".join(PackedStringArray(usernames.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## A batch of status updates for a given user.
class StatusPresenceEvent:
	extends RefCounted
	var joins: Array = []
	var leaves: Array = []


	static func from_json(_json: Variant) -> StatusPresenceEvent:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := StatusPresenceEvent.new()
		var _list_joins: Array = _data.get("joins", [])
		_message.joins = _list_joins.map(func(_v: Variant) -> UserPresence: return UserPresence.from_json(_v))
		var _list_leaves: Array = _data.get("leaves", [])
		_message.leaves = _list_leaves.map(func(_v: Variant) -> UserPresence: return UserPresence.from_json(_v))
		return _message


	func _init(p_joins: Array = [], p_leaves: Array = []) -> void:
		joins = p_joins
		leaves = p_leaves


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"joins":[%s]' % ",".join(PackedStringArray(joins.map(func(_v: UserPresence) -> String: return _v.to_json()))))
		_fields.append('"leaves":[%s]' % ",".join(PackedStringArray(leaves.map(func(_v: UserPresence) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Stop receiving status updates for some set of users.
class StatusUnfollow:
	extends RefCounted
	var user_ids: Array = []


	static func from_json(_json: Variant) -> StatusUnfollow:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := StatusUnfollow.new()
		_message.user_ids = _data.get("user_ids", [])
		return _message


	func _init(p_user_ids: Array = []) -> void:
		user_ids = p_user_ids


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"user_ids":[%s]' % ",".join(PackedStringArray(user_ids.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## Set the user's own status.
class StatusUpdate:
	extends RefCounted
	## String, or null when unset.
	var status: Variant


	static func from_json(_json: Variant) -> StatusUpdate:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := StatusUpdate.new()
		_message.status = _data["status"] if _data.get("status") != null else null
		return _message


	func _init(p_status: Variant = null) -> void:
		status = p_status


	func to_json() -> String:
		var _fields := PackedStringArray()
		if status != null:
			_fields.append('"status":' + JSON.stringify(status))
		return "{%s}" % ",".join(_fields)


## Represents identifying information for a stream.
class Stream:
	extends RefCounted
	var mode: int
	var subject: String
	var subcontext: String
	var label: String


	static func from_json(_json: Variant) -> Stream:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Stream.new()
		_message.mode = type_convert(_data.get("mode", 0), TYPE_INT)
		_message.subject = _data.get("subject", "")
		_message.subcontext = _data.get("subcontext", "")
		_message.label = _data.get("label", "")
		return _message


	func _init(p_mode: int = 0, p_subject: String = "", p_subcontext: String = "",
			p_label: String = "") -> void:
		mode = p_mode
		subject = p_subject
		subcontext = p_subcontext
		label = p_label


	func to_json() -> String:
		var _fields := PackedStringArray()
		if mode != 0:
			_fields.append('"mode":' + JSON.stringify(mode))
		if not subject.is_empty():
			_fields.append('"subject":' + JSON.stringify(subject))
		if not subcontext.is_empty():
			_fields.append('"subcontext":' + JSON.stringify(subcontext))
		if not label.is_empty():
			_fields.append('"label":' + JSON.stringify(label))
		return "{%s}" % ",".join(_fields)


## A data message delivered over a stream.
class StreamData:
	extends RefCounted
	var stream: Stream
	var sender: UserPresence
	var data: String
	var reliable: bool


	static func from_json(_json: Variant) -> StreamData:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := StreamData.new()
		_message.stream = Stream.from_json(_data["stream"]) if _data.get("stream") != null else null
		_message.sender = UserPresence.from_json(_data["sender"]) if _data.get("sender") != null else null
		_message.data = _data.get("data", "")
		_message.reliable = _data.get("reliable", false)
		return _message


	func _init(p_stream: Stream = null, p_sender: UserPresence = null, p_data: String = "",
			p_reliable: bool = false) -> void:
		stream = p_stream
		sender = p_sender
		data = p_data
		reliable = p_reliable


	func to_json() -> String:
		var _fields := PackedStringArray()
		if stream != null:
			_fields.append('"stream":' + stream.to_json())
		if sender != null:
			_fields.append('"sender":' + sender.to_json())
		if not data.is_empty():
			_fields.append('"data":' + JSON.stringify(data))
		if reliable:
			_fields.append('"reliable":' + JSON.stringify(reliable))
		return "{%s}" % ",".join(_fields)


## A set of joins and leaves on a particular stream.
class StreamPresenceEvent:
	extends RefCounted
	var stream: Stream
	var joins: Array = []
	var leaves: Array = []


	static func from_json(_json: Variant) -> StreamPresenceEvent:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := StreamPresenceEvent.new()
		_message.stream = Stream.from_json(_data["stream"]) if _data.get("stream") != null else null
		var _list_joins: Array = _data.get("joins", [])
		_message.joins = _list_joins.map(func(_v: Variant) -> UserPresence: return UserPresence.from_json(_v))
		var _list_leaves: Array = _data.get("leaves", [])
		_message.leaves = _list_leaves.map(func(_v: Variant) -> UserPresence: return UserPresence.from_json(_v))
		return _message


	func _init(p_stream: Stream = null, p_joins: Array = [], p_leaves: Array = []) -> void:
		stream = p_stream
		joins = p_joins
		leaves = p_leaves


	func to_json() -> String:
		var _fields := PackedStringArray()
		if stream != null:
			_fields.append('"stream":' + stream.to_json())
		_fields.append('"joins":[%s]' % ",".join(PackedStringArray(joins.map(func(_v: UserPresence) -> String: return _v.to_json()))))
		_fields.append('"leaves":[%s]' % ",".join(PackedStringArray(leaves.map(func(_v: UserPresence) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Application-level heartbeat and connection check.
class Ping:
	extends RefCounted


	static func from_json(_json: Variant) -> Ping:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Ping.new()
		return _message


	func to_json() -> String:
		var _fields := PackedStringArray()
		return "{%s}" % ",".join(_fields)


## Application-level heartbeat and connection check response.
class Pong:
	extends RefCounted


	static func from_json(_json: Variant) -> Pong:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Pong.new()
		return _message


	func to_json() -> String:
		var _fields := PackedStringArray()
		return "{%s}" % ",".join(_fields)


## Incoming information about a party.
class Party:
	extends RefCounted
	var party_id: String
	var open: bool
	var hidden: bool
	var max_size: int
	var self_: UserPresence
	var leader: UserPresence
	var label: String
	var presences: Array = []


	static func from_json(_json: Variant) -> Party:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Party.new()
		_message.party_id = _data.get("party_id", "")
		_message.open = _data.get("open", false)
		_message.hidden = _data.get("hidden", false)
		_message.max_size = type_convert(_data.get("max_size", 0), TYPE_INT)
		_message.self_ = UserPresence.from_json(_data["self"]) if _data.get("self") != null else null
		_message.leader = UserPresence.from_json(_data["leader"]) if _data.get("leader") != null else null
		_message.label = _data.get("label", "")
		var _list_presences: Array = _data.get("presences", [])
		_message.presences = _list_presences.map(func(_v: Variant) -> UserPresence: return UserPresence.from_json(_v))
		return _message


	func _init(p_party_id: String = "", p_open: bool = false, p_hidden: bool = false,
			p_max_size: int = 0, p_self_: UserPresence = null, p_leader: UserPresence = null,
			p_presences: Array = [], p_label: String = "") -> void:
		party_id = p_party_id
		open = p_open
		hidden = p_hidden
		max_size = p_max_size
		self_ = p_self_
		leader = p_leader
		presences = p_presences
		label = p_label


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not party_id.is_empty():
			_fields.append('"party_id":' + JSON.stringify(party_id))
		if open:
			_fields.append('"open":' + JSON.stringify(open))
		if hidden:
			_fields.append('"hidden":' + JSON.stringify(hidden))
		if max_size != 0:
			_fields.append('"max_size":' + JSON.stringify(max_size))
		if self_ != null:
			_fields.append('"self":' + self_.to_json())
		if leader != null:
			_fields.append('"leader":' + leader.to_json())
		if not label.is_empty():
			_fields.append('"label":' + JSON.stringify(label))
		_fields.append('"presences":[%s]' % ",".join(PackedStringArray(presences.map(func(_v: UserPresence) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Create a party.
class PartyCreate:
	extends RefCounted
	var open: bool
	var max_size: int
	var label: String
	var hidden: bool


	static func from_json(_json: Variant) -> PartyCreate:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := PartyCreate.new()
		_message.open = _data.get("open", false)
		_message.max_size = type_convert(_data.get("max_size", 0), TYPE_INT)
		_message.label = _data.get("label", "")
		_message.hidden = _data.get("hidden", false)
		return _message


	func _init(p_open: bool = false, p_max_size: int = 0, p_label: String = "",
			p_hidden: bool = false) -> void:
		open = p_open
		max_size = p_max_size
		label = p_label
		hidden = p_hidden


	func to_json() -> String:
		var _fields := PackedStringArray()
		if open:
			_fields.append('"open":' + JSON.stringify(open))
		if max_size != 0:
			_fields.append('"max_size":' + JSON.stringify(max_size))
		if not label.is_empty():
			_fields.append('"label":' + JSON.stringify(label))
		if hidden:
			_fields.append('"hidden":' + JSON.stringify(hidden))
		return "{%s}" % ",".join(_fields)


## Join a party, or request to join if the party is not open.
class PartyJoin:
	extends RefCounted
	var party_id: String


	static func from_json(_json: Variant) -> PartyJoin:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := PartyJoin.new()
		_message.party_id = _data.get("party_id", "")
		return _message


	func _init(p_party_id: String = "") -> void:
		party_id = p_party_id


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not party_id.is_empty():
			_fields.append('"party_id":' + JSON.stringify(party_id))
		return "{%s}" % ",".join(_fields)


## Leave a party.
class PartyLeave:
	extends RefCounted
	var party_id: String


	static func from_json(_json: Variant) -> PartyLeave:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := PartyLeave.new()
		_message.party_id = _data.get("party_id", "")
		return _message


	func _init(p_party_id: String = "") -> void:
		party_id = p_party_id


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not party_id.is_empty():
			_fields.append('"party_id":' + JSON.stringify(party_id))
		return "{%s}" % ",".join(_fields)


## Promote a new party leader.
class PartyPromote:
	extends RefCounted
	var party_id: String
	var presence: UserPresence


	static func from_json(_json: Variant) -> PartyPromote:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := PartyPromote.new()
		_message.party_id = _data.get("party_id", "")
		_message.presence = UserPresence.from_json(_data["presence"]) if _data.get("presence") != null else null
		return _message


	func _init(p_party_id: String = "", p_presence: UserPresence = null) -> void:
		party_id = p_party_id
		presence = p_presence


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not party_id.is_empty():
			_fields.append('"party_id":' + JSON.stringify(party_id))
		if presence != null:
			_fields.append('"presence":' + presence.to_json())
		return "{%s}" % ",".join(_fields)


## Announcement of a new party leader.
class PartyLeader:
	extends RefCounted
	var party_id: String
	var presence: UserPresence


	static func from_json(_json: Variant) -> PartyLeader:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := PartyLeader.new()
		_message.party_id = _data.get("party_id", "")
		_message.presence = UserPresence.from_json(_data["presence"]) if _data.get("presence") != null else null
		return _message


	func _init(p_party_id: String = "", p_presence: UserPresence = null) -> void:
		party_id = p_party_id
		presence = p_presence


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not party_id.is_empty():
			_fields.append('"party_id":' + JSON.stringify(party_id))
		if presence != null:
			_fields.append('"presence":' + presence.to_json())
		return "{%s}" % ",".join(_fields)


## Accept a request to join.
class PartyAccept:
	extends RefCounted
	var party_id: String
	var presence: UserPresence


	static func from_json(_json: Variant) -> PartyAccept:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := PartyAccept.new()
		_message.party_id = _data.get("party_id", "")
		_message.presence = UserPresence.from_json(_data["presence"]) if _data.get("presence") != null else null
		return _message


	func _init(p_party_id: String = "", p_presence: UserPresence = null) -> void:
		party_id = p_party_id
		presence = p_presence


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not party_id.is_empty():
			_fields.append('"party_id":' + JSON.stringify(party_id))
		if presence != null:
			_fields.append('"presence":' + presence.to_json())
		return "{%s}" % ",".join(_fields)


## Kick a party member, or decline a request to join.
class PartyRemove:
	extends RefCounted
	var party_id: String
	var presence: UserPresence


	static func from_json(_json: Variant) -> PartyRemove:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := PartyRemove.new()
		_message.party_id = _data.get("party_id", "")
		_message.presence = UserPresence.from_json(_data["presence"]) if _data.get("presence") != null else null
		return _message


	func _init(p_party_id: String = "", p_presence: UserPresence = null) -> void:
		party_id = p_party_id
		presence = p_presence


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not party_id.is_empty():
			_fields.append('"party_id":' + JSON.stringify(party_id))
		if presence != null:
			_fields.append('"presence":' + presence.to_json())
		return "{%s}" % ",".join(_fields)


## End a party, kicking all party members and closing it.
class PartyClose:
	extends RefCounted
	var party_id: String


	static func from_json(_json: Variant) -> PartyClose:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := PartyClose.new()
		_message.party_id = _data.get("party_id", "")
		return _message


	func _init(p_party_id: String = "") -> void:
		party_id = p_party_id


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not party_id.is_empty():
			_fields.append('"party_id":' + JSON.stringify(party_id))
		return "{%s}" % ",".join(_fields)


## Request a list of pending join requests for a party.
class PartyJoinRequestList:
	extends RefCounted
	var party_id: String


	static func from_json(_json: Variant) -> PartyJoinRequestList:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := PartyJoinRequestList.new()
		_message.party_id = _data.get("party_id", "")
		return _message


	func _init(p_party_id: String = "") -> void:
		party_id = p_party_id


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not party_id.is_empty():
			_fields.append('"party_id":' + JSON.stringify(party_id))
		return "{%s}" % ",".join(_fields)


## Incoming notification for one or more new presences attempting to join the party.
class PartyJoinRequest:
	extends RefCounted
	var party_id: String
	var presences: Array = []


	static func from_json(_json: Variant) -> PartyJoinRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := PartyJoinRequest.new()
		_message.party_id = _data.get("party_id", "")
		var _list_presences: Array = _data.get("presences", [])
		_message.presences = _list_presences.map(func(_v: Variant) -> UserPresence: return UserPresence.from_json(_v))
		return _message


	func _init(p_party_id: String = "", p_presences: Array = []) -> void:
		party_id = p_party_id
		presences = p_presences


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not party_id.is_empty():
			_fields.append('"party_id":' + JSON.stringify(party_id))
		_fields.append('"presences":[%s]' % ",".join(PackedStringArray(presences.map(func(_v: UserPresence) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Begin matchmaking as a party.
class PartyMatchmakerAdd:
	extends RefCounted
	var party_id: String
	var min_count: int
	var max_count: int
	var query: String
	## int, or null when unset.
	var count_multiple: Variant
	var string_properties: Dictionary = {}
	var numeric_properties: Dictionary = {}


	static func from_json(_json: Variant) -> PartyMatchmakerAdd:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := PartyMatchmakerAdd.new()
		_message.party_id = _data.get("party_id", "")
		_message.min_count = type_convert(_data.get("min_count", 0), TYPE_INT)
		_message.max_count = type_convert(_data.get("max_count", 0), TYPE_INT)
		_message.query = _data.get("query", "")
		_message.count_multiple = type_convert(_data["count_multiple"], TYPE_INT) if _data.get("count_multiple") != null else null
		var _map_string_properties: Dictionary = _data.get("string_properties", {})
		for _k: Variant in _map_string_properties:
			_message.string_properties[_k] = _map_string_properties[_k]
		var _map_numeric_properties: Dictionary = _data.get("numeric_properties", {})
		for _k: Variant in _map_numeric_properties:
			_message.numeric_properties[_k] = {"NaN": NAN, "Infinity": INF, "-Infinity": -INF}.get(_map_numeric_properties[_k], type_convert(_map_numeric_properties[_k], TYPE_FLOAT))
		return _message


	func _init(p_party_id: String = "", p_min_count: int = 0, p_max_count: int = 0,
			p_query: String = "", p_string_properties: Dictionary = {},
			p_numeric_properties: Dictionary = {}, p_count_multiple: Variant = null) -> void:
		party_id = p_party_id
		min_count = p_min_count
		max_count = p_max_count
		query = p_query
		string_properties = p_string_properties
		numeric_properties = p_numeric_properties
		count_multiple = p_count_multiple


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not party_id.is_empty():
			_fields.append('"party_id":' + JSON.stringify(party_id))
		if min_count != 0:
			_fields.append('"min_count":' + JSON.stringify(min_count))
		if max_count != 0:
			_fields.append('"max_count":' + JSON.stringify(max_count))
		if not query.is_empty():
			_fields.append('"query":' + JSON.stringify(query))
		if count_multiple != null:
			_fields.append('"count_multiple":' + JSON.stringify(count_multiple))
		var _map_string_properties := PackedStringArray()
		for _k: Variant in string_properties:
			var _v: String = str(string_properties[_k])
			_map_string_properties.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"string_properties":{%s}' % ",".join(_map_string_properties))
		var _map_numeric_properties := PackedStringArray()
		for _k: Variant in numeric_properties:
			var _v: float = numeric_properties[_k]
			_map_numeric_properties.append(JSON.stringify(str(_k)) + ":" + (JSON.stringify(_v) if is_finite(_v) else '"NaN"' if is_nan(_v) else '"Infinity"' if _v > 0 else '"-Infinity"'))
		_fields.append('"numeric_properties":{%s}' % ",".join(_map_numeric_properties))
		return "{%s}" % ",".join(_fields)


## Cancel a party matchmaking process using a ticket.
class PartyMatchmakerRemove:
	extends RefCounted
	var party_id: String
	var ticket: String


	static func from_json(_json: Variant) -> PartyMatchmakerRemove:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := PartyMatchmakerRemove.new()
		_message.party_id = _data.get("party_id", "")
		_message.ticket = _data.get("ticket", "")
		return _message


	func _init(p_party_id: String = "", p_ticket: String = "") -> void:
		party_id = p_party_id
		ticket = p_ticket


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not party_id.is_empty():
			_fields.append('"party_id":' + JSON.stringify(party_id))
		if not ticket.is_empty():
			_fields.append('"ticket":' + JSON.stringify(ticket))
		return "{%s}" % ",".join(_fields)


## A response from starting a new party matchmaking process.
class PartyMatchmakerTicket:
	extends RefCounted
	var party_id: String
	var ticket: String


	static func from_json(_json: Variant) -> PartyMatchmakerTicket:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := PartyMatchmakerTicket.new()
		_message.party_id = _data.get("party_id", "")
		_message.ticket = _data.get("ticket", "")
		return _message


	func _init(p_party_id: String = "", p_ticket: String = "") -> void:
		party_id = p_party_id
		ticket = p_ticket


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not party_id.is_empty():
			_fields.append('"party_id":' + JSON.stringify(party_id))
		if not ticket.is_empty():
			_fields.append('"ticket":' + JSON.stringify(ticket))
		return "{%s}" % ",".join(_fields)


## Incoming party data delivered from the server.
class PartyData:
	extends RefCounted
	var party_id: String
	var presence: UserPresence
	var op_code: int
	var data: PackedByteArray


	static func from_json(_json: Variant) -> PartyData:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := PartyData.new()
		_message.party_id = _data.get("party_id", "")
		_message.presence = UserPresence.from_json(_data["presence"]) if _data.get("presence") != null else null
		_message.op_code = type_convert(_data.get("op_code", 0), TYPE_INT)
		_message.data = Marshalls.base64_to_raw(str(_data.get("data", "")))
		return _message


	func _init(p_party_id: String = "", p_presence: UserPresence = null, p_op_code: int = 0,
			p_data: PackedByteArray = PackedByteArray()) -> void:
		party_id = p_party_id
		presence = p_presence
		op_code = p_op_code
		data = p_data


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not party_id.is_empty():
			_fields.append('"party_id":' + JSON.stringify(party_id))
		if presence != null:
			_fields.append('"presence":' + presence.to_json())
		if op_code != 0:
			_fields.append('"op_code":' + JSON.stringify(op_code))
		if not data.is_empty():
			var _data: PackedByteArray = data
			_fields.append('"data":' + JSON.stringify(Marshalls.raw_to_base64(_data)))
		return "{%s}" % ",".join(_fields)


## Send data to a party.
class PartyDataSend:
	extends RefCounted
	var party_id: String
	var op_code: int
	var data: PackedByteArray


	static func from_json(_json: Variant) -> PartyDataSend:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := PartyDataSend.new()
		_message.party_id = _data.get("party_id", "")
		_message.op_code = type_convert(_data.get("op_code", 0), TYPE_INT)
		_message.data = Marshalls.base64_to_raw(str(_data.get("data", "")))
		return _message


	func _init(p_party_id: String = "", p_op_code: int = 0,
			p_data: PackedByteArray = PackedByteArray()) -> void:
		party_id = p_party_id
		op_code = p_op_code
		data = p_data


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not party_id.is_empty():
			_fields.append('"party_id":' + JSON.stringify(party_id))
		if op_code != 0:
			_fields.append('"op_code":' + JSON.stringify(op_code))
		if not data.is_empty():
			var _data: PackedByteArray = data
			_fields.append('"data":' + JSON.stringify(Marshalls.raw_to_base64(_data)))
		return "{%s}" % ",".join(_fields)


## Presence update for a particular party.
class PartyPresenceEvent:
	extends RefCounted
	var party_id: String
	var joins: Array = []
	var leaves: Array = []


	static func from_json(_json: Variant) -> PartyPresenceEvent:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := PartyPresenceEvent.new()
		_message.party_id = _data.get("party_id", "")
		var _list_joins: Array = _data.get("joins", [])
		_message.joins = _list_joins.map(func(_v: Variant) -> UserPresence: return UserPresence.from_json(_v))
		var _list_leaves: Array = _data.get("leaves", [])
		_message.leaves = _list_leaves.map(func(_v: Variant) -> UserPresence: return UserPresence.from_json(_v))
		return _message


	func _init(p_party_id: String = "", p_joins: Array = [], p_leaves: Array = []) -> void:
		party_id = p_party_id
		joins = p_joins
		leaves = p_leaves


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not party_id.is_empty():
			_fields.append('"party_id":' + JSON.stringify(party_id))
		_fields.append('"joins":[%s]' % ",".join(PackedStringArray(joins.map(func(_v: UserPresence) -> String: return _v.to_json()))))
		_fields.append('"leaves":[%s]' % ",".join(PackedStringArray(leaves.map(func(_v: UserPresence) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Update a party label.
class PartyUpdate:
	extends RefCounted
	var party_id: String
	var label: String
	var open: bool
	var hidden: bool


	static func from_json(_json: Variant) -> PartyUpdate:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := PartyUpdate.new()
		_message.party_id = _data.get("party_id", "")
		_message.label = _data.get("label", "")
		_message.open = _data.get("open", false)
		_message.hidden = _data.get("hidden", false)
		return _message


	func _init(p_party_id: String = "", p_label: String = "", p_open: bool = false,
			p_hidden: bool = false) -> void:
		party_id = p_party_id
		label = p_label
		open = p_open
		hidden = p_hidden


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not party_id.is_empty():
			_fields.append('"party_id":' + JSON.stringify(party_id))
		if not label.is_empty():
			_fields.append('"label":' + JSON.stringify(label))
		if open:
			_fields.append('"open":' + JSON.stringify(open))
		if hidden:
			_fields.append('"hidden":' + JSON.stringify(hidden))
		return "{%s}" % ",".join(_fields)


## An envelope for a realtime message.
class Envelope:
	extends RefCounted
	var cid: String
	var channel: Channel
	var channel_join: ChannelJoin
	var channel_leave: ChannelLeave
	var channel_message: NakamaTypes.ChannelMessage
	var channel_message_ack: ChannelMessageAck
	var channel_message_send: ChannelMessageSend
	var channel_message_update: ChannelMessageUpdate
	var channel_message_remove: ChannelMessageRemove
	var channel_presence_event: ChannelPresenceEvent
	var error: Error_
	var match_: Match
	var match_create: MatchCreate
	var match_data: MatchData
	var match_data_send: MatchDataSend
	var match_join: MatchJoin
	var match_leave: MatchLeave
	var match_presence_event: MatchPresenceEvent
	var matchmaker_add: MatchmakerAdd
	var matchmaker_matched: MatchmakerMatched
	var matchmaker_remove: MatchmakerRemove
	var matchmaker_ticket: MatchmakerTicket
	var notifications: Notifications
	var rpc: NakamaTypes.Rpc
	var status: Status
	var status_follow: StatusFollow
	var status_presence_event: StatusPresenceEvent
	var status_unfollow: StatusUnfollow
	var status_update: StatusUpdate
	var stream_data: StreamData
	var stream_presence_event: StreamPresenceEvent
	var ping: Ping
	var pong: Pong
	var party: Party
	var party_create: PartyCreate
	var party_join: PartyJoin
	var party_leave: PartyLeave
	var party_promote: PartyPromote
	var party_leader: PartyLeader
	var party_accept: PartyAccept
	var party_remove: PartyRemove
	var party_close: PartyClose
	var party_join_request_list: PartyJoinRequestList
	var party_join_request: PartyJoinRequest
	var party_matchmaker_add: PartyMatchmakerAdd
	var party_matchmaker_remove: PartyMatchmakerRemove
	var party_matchmaker_ticket: PartyMatchmakerTicket
	var party_data: PartyData
	var party_data_send: PartyDataSend
	var party_presence_event: PartyPresenceEvent
	var party_update: PartyUpdate


	static func from_json(_json: Variant) -> Envelope:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Envelope.new()
		_message.cid = _data.get("cid", "")
		_message.channel = Channel.from_json(_data["channel"]) if _data.get("channel") != null else null
		_message.channel_join = ChannelJoin.from_json(_data["channel_join"]) if _data.get("channel_join") != null else null
		_message.channel_leave = ChannelLeave.from_json(_data["channel_leave"]) if _data.get("channel_leave") != null else null
		_message.channel_message = NakamaTypes.ChannelMessage.from_json(_data["channel_message"]) if _data.get("channel_message") != null else null
		_message.channel_message_ack = ChannelMessageAck.from_json(_data["channel_message_ack"]) if _data.get("channel_message_ack") != null else null
		_message.channel_message_send = ChannelMessageSend.from_json(_data["channel_message_send"]) if _data.get("channel_message_send") != null else null
		_message.channel_message_update = ChannelMessageUpdate.from_json(_data["channel_message_update"]) if _data.get("channel_message_update") != null else null
		_message.channel_message_remove = ChannelMessageRemove.from_json(_data["channel_message_remove"]) if _data.get("channel_message_remove") != null else null
		_message.channel_presence_event = ChannelPresenceEvent.from_json(_data["channel_presence_event"]) if _data.get("channel_presence_event") != null else null
		_message.error = Error_.from_json(_data["error"]) if _data.get("error") != null else null
		_message.match_ = Match.from_json(_data["match"]) if _data.get("match") != null else null
		_message.match_create = MatchCreate.from_json(_data["match_create"]) if _data.get("match_create") != null else null
		_message.match_data = MatchData.from_json(_data["match_data"]) if _data.get("match_data") != null else null
		_message.match_data_send = MatchDataSend.from_json(_data["match_data_send"]) if _data.get("match_data_send") != null else null
		_message.match_join = MatchJoin.from_json(_data["match_join"]) if _data.get("match_join") != null else null
		_message.match_leave = MatchLeave.from_json(_data["match_leave"]) if _data.get("match_leave") != null else null
		_message.match_presence_event = MatchPresenceEvent.from_json(_data["match_presence_event"]) if _data.get("match_presence_event") != null else null
		_message.matchmaker_add = MatchmakerAdd.from_json(_data["matchmaker_add"]) if _data.get("matchmaker_add") != null else null
		_message.matchmaker_matched = MatchmakerMatched.from_json(_data["matchmaker_matched"]) if _data.get("matchmaker_matched") != null else null
		_message.matchmaker_remove = MatchmakerRemove.from_json(_data["matchmaker_remove"]) if _data.get("matchmaker_remove") != null else null
		_message.matchmaker_ticket = MatchmakerTicket.from_json(_data["matchmaker_ticket"]) if _data.get("matchmaker_ticket") != null else null
		_message.notifications = Notifications.from_json(_data["notifications"]) if _data.get("notifications") != null else null
		_message.rpc = NakamaTypes.Rpc.from_json(_data["rpc"]) if _data.get("rpc") != null else null
		_message.status = Status.from_json(_data["status"]) if _data.get("status") != null else null
		_message.status_follow = StatusFollow.from_json(_data["status_follow"]) if _data.get("status_follow") != null else null
		_message.status_presence_event = StatusPresenceEvent.from_json(_data["status_presence_event"]) if _data.get("status_presence_event") != null else null
		_message.status_unfollow = StatusUnfollow.from_json(_data["status_unfollow"]) if _data.get("status_unfollow") != null else null
		_message.status_update = StatusUpdate.from_json(_data["status_update"]) if _data.get("status_update") != null else null
		_message.stream_data = StreamData.from_json(_data["stream_data"]) if _data.get("stream_data") != null else null
		_message.stream_presence_event = StreamPresenceEvent.from_json(_data["stream_presence_event"]) if _data.get("stream_presence_event") != null else null
		_message.ping = Ping.from_json(_data["ping"]) if _data.get("ping") != null else null
		_message.pong = Pong.from_json(_data["pong"]) if _data.get("pong") != null else null
		_message.party = Party.from_json(_data["party"]) if _data.get("party") != null else null
		_message.party_create = PartyCreate.from_json(_data["party_create"]) if _data.get("party_create") != null else null
		_message.party_join = PartyJoin.from_json(_data["party_join"]) if _data.get("party_join") != null else null
		_message.party_leave = PartyLeave.from_json(_data["party_leave"]) if _data.get("party_leave") != null else null
		_message.party_promote = PartyPromote.from_json(_data["party_promote"]) if _data.get("party_promote") != null else null
		_message.party_leader = PartyLeader.from_json(_data["party_leader"]) if _data.get("party_leader") != null else null
		_message.party_accept = PartyAccept.from_json(_data["party_accept"]) if _data.get("party_accept") != null else null
		_message.party_remove = PartyRemove.from_json(_data["party_remove"]) if _data.get("party_remove") != null else null
		_message.party_close = PartyClose.from_json(_data["party_close"]) if _data.get("party_close") != null else null
		_message.party_join_request_list = PartyJoinRequestList.from_json(_data["party_join_request_list"]) if _data.get("party_join_request_list") != null else null
		_message.party_join_request = PartyJoinRequest.from_json(_data["party_join_request"]) if _data.get("party_join_request") != null else null
		_message.party_matchmaker_add = PartyMatchmakerAdd.from_json(_data["party_matchmaker_add"]) if _data.get("party_matchmaker_add") != null else null
		_message.party_matchmaker_remove = PartyMatchmakerRemove.from_json(_data["party_matchmaker_remove"]) if _data.get("party_matchmaker_remove") != null else null
		_message.party_matchmaker_ticket = PartyMatchmakerTicket.from_json(_data["party_matchmaker_ticket"]) if _data.get("party_matchmaker_ticket") != null else null
		_message.party_data = PartyData.from_json(_data["party_data"]) if _data.get("party_data") != null else null
		_message.party_data_send = PartyDataSend.from_json(_data["party_data_send"]) if _data.get("party_data_send") != null else null
		_message.party_presence_event = PartyPresenceEvent.from_json(_data["party_presence_event"]) if _data.get("party_presence_event") != null else null
		_message.party_update = PartyUpdate.from_json(_data["party_update"]) if _data.get("party_update") != null else null
		return _message


	func _init(p_cid: String = "", p_channel: Channel = null, p_channel_join: ChannelJoin = null,
			p_channel_leave: ChannelLeave = null,
			p_channel_message: NakamaTypes.ChannelMessage = null,
			p_channel_message_ack: ChannelMessageAck = null,
			p_channel_message_send: ChannelMessageSend = null,
			p_channel_message_update: ChannelMessageUpdate = null,
			p_channel_message_remove: ChannelMessageRemove = null,
			p_channel_presence_event: ChannelPresenceEvent = null, p_error: Error_ = null,
			p_match_: Match = null, p_match_create: MatchCreate = null,
			p_match_data: MatchData = null, p_match_data_send: MatchDataSend = null,
			p_match_join: MatchJoin = null, p_match_leave: MatchLeave = null,
			p_match_presence_event: MatchPresenceEvent = null,
			p_matchmaker_add: MatchmakerAdd = null, p_matchmaker_matched: MatchmakerMatched = null,
			p_matchmaker_remove: MatchmakerRemove = null,
			p_matchmaker_ticket: MatchmakerTicket = null, p_notifications: Notifications = null,
			p_rpc: NakamaTypes.Rpc = null, p_status: Status = null,
			p_status_follow: StatusFollow = null,
			p_status_presence_event: StatusPresenceEvent = null,
			p_status_unfollow: StatusUnfollow = null, p_status_update: StatusUpdate = null,
			p_stream_data: StreamData = null, p_stream_presence_event: StreamPresenceEvent = null,
			p_ping: Ping = null, p_pong: Pong = null, p_party: Party = null,
			p_party_create: PartyCreate = null, p_party_join: PartyJoin = null,
			p_party_leave: PartyLeave = null, p_party_promote: PartyPromote = null,
			p_party_leader: PartyLeader = null, p_party_accept: PartyAccept = null,
			p_party_remove: PartyRemove = null, p_party_close: PartyClose = null,
			p_party_join_request_list: PartyJoinRequestList = null,
			p_party_join_request: PartyJoinRequest = null,
			p_party_matchmaker_add: PartyMatchmakerAdd = null,
			p_party_matchmaker_remove: PartyMatchmakerRemove = null,
			p_party_matchmaker_ticket: PartyMatchmakerTicket = null, p_party_data: PartyData = null,
			p_party_data_send: PartyDataSend = null,
			p_party_presence_event: PartyPresenceEvent = null,
			p_party_update: PartyUpdate = null) -> void:
		cid = p_cid
		channel = p_channel
		channel_join = p_channel_join
		channel_leave = p_channel_leave
		channel_message = p_channel_message
		channel_message_ack = p_channel_message_ack
		channel_message_send = p_channel_message_send
		channel_message_update = p_channel_message_update
		channel_message_remove = p_channel_message_remove
		channel_presence_event = p_channel_presence_event
		error = p_error
		match_ = p_match_
		match_create = p_match_create
		match_data = p_match_data
		match_data_send = p_match_data_send
		match_join = p_match_join
		match_leave = p_match_leave
		match_presence_event = p_match_presence_event
		matchmaker_add = p_matchmaker_add
		matchmaker_matched = p_matchmaker_matched
		matchmaker_remove = p_matchmaker_remove
		matchmaker_ticket = p_matchmaker_ticket
		notifications = p_notifications
		rpc = p_rpc
		status = p_status
		status_follow = p_status_follow
		status_presence_event = p_status_presence_event
		status_unfollow = p_status_unfollow
		status_update = p_status_update
		stream_data = p_stream_data
		stream_presence_event = p_stream_presence_event
		ping = p_ping
		pong = p_pong
		party = p_party
		party_create = p_party_create
		party_join = p_party_join
		party_leave = p_party_leave
		party_promote = p_party_promote
		party_leader = p_party_leader
		party_accept = p_party_accept
		party_remove = p_party_remove
		party_close = p_party_close
		party_join_request_list = p_party_join_request_list
		party_join_request = p_party_join_request
		party_matchmaker_add = p_party_matchmaker_add
		party_matchmaker_remove = p_party_matchmaker_remove
		party_matchmaker_ticket = p_party_matchmaker_ticket
		party_data = p_party_data
		party_data_send = p_party_data_send
		party_presence_event = p_party_presence_event
		party_update = p_party_update


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not cid.is_empty():
			_fields.append('"cid":' + JSON.stringify(cid))
		if channel != null:
			_fields.append('"channel":' + channel.to_json())
		if channel_join != null:
			_fields.append('"channel_join":' + channel_join.to_json())
		if channel_leave != null:
			_fields.append('"channel_leave":' + channel_leave.to_json())
		if channel_message != null:
			_fields.append('"channel_message":' + channel_message.to_json())
		if channel_message_ack != null:
			_fields.append('"channel_message_ack":' + channel_message_ack.to_json())
		if channel_message_send != null:
			_fields.append('"channel_message_send":' + channel_message_send.to_json())
		if channel_message_update != null:
			_fields.append('"channel_message_update":' + channel_message_update.to_json())
		if channel_message_remove != null:
			_fields.append('"channel_message_remove":' + channel_message_remove.to_json())
		if channel_presence_event != null:
			_fields.append('"channel_presence_event":' + channel_presence_event.to_json())
		if error != null:
			_fields.append('"error":' + error.to_json())
		if match_ != null:
			_fields.append('"match":' + match_.to_json())
		if match_create != null:
			_fields.append('"match_create":' + match_create.to_json())
		if match_data != null:
			_fields.append('"match_data":' + match_data.to_json())
		if match_data_send != null:
			_fields.append('"match_data_send":' + match_data_send.to_json())
		if match_join != null:
			_fields.append('"match_join":' + match_join.to_json())
		if match_leave != null:
			_fields.append('"match_leave":' + match_leave.to_json())
		if match_presence_event != null:
			_fields.append('"match_presence_event":' + match_presence_event.to_json())
		if matchmaker_add != null:
			_fields.append('"matchmaker_add":' + matchmaker_add.to_json())
		if matchmaker_matched != null:
			_fields.append('"matchmaker_matched":' + matchmaker_matched.to_json())
		if matchmaker_remove != null:
			_fields.append('"matchmaker_remove":' + matchmaker_remove.to_json())
		if matchmaker_ticket != null:
			_fields.append('"matchmaker_ticket":' + matchmaker_ticket.to_json())
		if notifications != null:
			_fields.append('"notifications":' + notifications.to_json())
		if rpc != null:
			_fields.append('"rpc":' + rpc.to_json())
		if status != null:
			_fields.append('"status":' + status.to_json())
		if status_follow != null:
			_fields.append('"status_follow":' + status_follow.to_json())
		if status_presence_event != null:
			_fields.append('"status_presence_event":' + status_presence_event.to_json())
		if status_unfollow != null:
			_fields.append('"status_unfollow":' + status_unfollow.to_json())
		if status_update != null:
			_fields.append('"status_update":' + status_update.to_json())
		if stream_data != null:
			_fields.append('"stream_data":' + stream_data.to_json())
		if stream_presence_event != null:
			_fields.append('"stream_presence_event":' + stream_presence_event.to_json())
		if ping != null:
			_fields.append('"ping":' + ping.to_json())
		if pong != null:
			_fields.append('"pong":' + pong.to_json())
		if party != null:
			_fields.append('"party":' + party.to_json())
		if party_create != null:
			_fields.append('"party_create":' + party_create.to_json())
		if party_join != null:
			_fields.append('"party_join":' + party_join.to_json())
		if party_leave != null:
			_fields.append('"party_leave":' + party_leave.to_json())
		if party_promote != null:
			_fields.append('"party_promote":' + party_promote.to_json())
		if party_leader != null:
			_fields.append('"party_leader":' + party_leader.to_json())
		if party_accept != null:
			_fields.append('"party_accept":' + party_accept.to_json())
		if party_remove != null:
			_fields.append('"party_remove":' + party_remove.to_json())
		if party_close != null:
			_fields.append('"party_close":' + party_close.to_json())
		if party_join_request_list != null:
			_fields.append('"party_join_request_list":' + party_join_request_list.to_json())
		if party_join_request != null:
			_fields.append('"party_join_request":' + party_join_request.to_json())
		if party_matchmaker_add != null:
			_fields.append('"party_matchmaker_add":' + party_matchmaker_add.to_json())
		if party_matchmaker_remove != null:
			_fields.append('"party_matchmaker_remove":' + party_matchmaker_remove.to_json())
		if party_matchmaker_ticket != null:
			_fields.append('"party_matchmaker_ticket":' + party_matchmaker_ticket.to_json())
		if party_data != null:
			_fields.append('"party_data":' + party_data.to_json())
		if party_data_send != null:
			_fields.append('"party_data_send":' + party_data_send.to_json())
		if party_presence_event != null:
			_fields.append('"party_presence_event":' + party_presence_event.to_json())
		if party_update != null:
			_fields.append('"party_update":' + party_update.to_json())
		return "{%s}" % ",".join(_fields)

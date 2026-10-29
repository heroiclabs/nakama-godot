# Copyright 2026 The Satori Authors
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

# Code generated from the Satori protos. DO NOT EDIT.
class_name SatoriTypes
extends RefCounted

enum FlagValueChangeReasonType {
	UNKNOWN = 0,
	FLAG_VARIANT = 1,
	LIVE_EVENT = 2,
	EXPERIMENT = 3,
}

enum FlagOverrideType {
	FLAG = 0,
	FLAG_VARIANT = 1,
	LIVE_EVENT_FLAG = 2,
	LIVE_EVENT_FLAG_VARIANT = 3,
	EXPERIMENT_PHASE_VARIANT_FLAG = 4,
}

## The status variants of a live event.
enum LiveEventStatus {
	UNKNOWN = 0,
	ACTIVE = 1,
	UPCOMING = 2,
	TERMINATED = 3,
}


## Log out a session, invalidate a refresh token, or log out all sessions/refresh tokens for an identity.
class AuthenticateLogoutRequest:
	extends RefCounted
	var token: String
	var refresh_token: String


	static func from_json(_json: Variant) -> AuthenticateLogoutRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AuthenticateLogoutRequest.new()
		_message.token = _data.get("token", "")
		_message.refresh_token = _data.get("refresh_token", "")
		return _message


	func _init(p_token: String = "", p_refresh_token: String = "") -> void:
		token = p_token
		refresh_token = p_refresh_token


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not token.is_empty():
			_fields.append('"token":' + JSON.stringify(token))
		if not refresh_token.is_empty():
			_fields.append('"refresh_token":' + JSON.stringify(refresh_token))
		return "{%s}" % ",".join(_fields)


## Authenticate against the server with a refresh token.
class AuthenticateRefreshRequest:
	extends RefCounted
	var refresh_token: String


	static func from_json(_json: Variant) -> AuthenticateRefreshRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AuthenticateRefreshRequest.new()
		_message.refresh_token = _data.get("refresh_token", "")
		return _message


	func _init(p_refresh_token: String = "") -> void:
		refresh_token = p_refresh_token


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not refresh_token.is_empty():
			_fields.append('"refresh_token":' + JSON.stringify(refresh_token))
		return "{%s}" % ",".join(_fields)


## Authentication request.
class AuthenticateRequest:
	extends RefCounted
	var id: String
	var no_session: bool
	var default: Dictionary = {}
	var custom: Dictionary = {}


	static func from_json(_json: Variant) -> AuthenticateRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AuthenticateRequest.new()
		_message.id = _data.get("id", "")
		_message.no_session = _data.get("no_session", false)
		var _map_default: Dictionary = _data.get("default", {})
		for _k: Variant in _map_default:
			_message.default[_k] = _map_default[_k]
		var _map_custom: Dictionary = _data.get("custom", {})
		for _k: Variant in _map_custom:
			_message.custom[_k] = _map_custom[_k]
		return _message


	func _init(p_id: String = "", p_default: Dictionary = {}, p_custom: Dictionary = {},
			p_no_session: bool = false) -> void:
		id = p_id
		default = p_default
		custom = p_custom
		no_session = p_no_session


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not id.is_empty():
			_fields.append('"id":' + JSON.stringify(id))
		if no_session:
			_fields.append('"no_session":' + JSON.stringify(no_session))
		var _map_default := PackedStringArray()
		for _k: Variant in default:
			var _v: String = str(default[_k])
			_map_default.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"default":{%s}' % ",".join(_map_default))
		var _map_custom := PackedStringArray()
		for _k: Variant in custom:
			var _v: String = str(custom[_k])
			_map_custom.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"custom":{%s}' % ",".join(_map_custom))
		return "{%s}" % ",".join(_fields)


## A single event. Usually, but not necessarily, part of a batch.
class Event:
	extends RefCounted
	var name: String
	var id: String
	var value: String
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var timestamp: Variant
	var identity_id: String
	var session_id: String
	var session_issued_at: int
	var session_expires_at: int
	var metadata: Dictionary = {}


	static func from_json(_json: Variant) -> Event:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Event.new()
		_message.name = _data.get("name", "")
		_message.id = _data.get("id", "")
		_message.value = _data.get("value", "")
		_message.timestamp = _data.get("timestamp")
		_message.identity_id = _data.get("identity_id", "")
		_message.session_id = _data.get("session_id", "")
		_message.session_issued_at = type_convert(_data.get("session_issued_at", 0), TYPE_INT)
		_message.session_expires_at = type_convert(_data.get("session_expires_at", 0), TYPE_INT)
		var _map_metadata: Dictionary = _data.get("metadata", {})
		for _k: Variant in _map_metadata:
			_message.metadata[_k] = _map_metadata[_k]
		return _message


	func _init(p_name: String = "", p_id: String = "", p_metadata: Dictionary = {},
			p_value: String = "", p_timestamp: Variant = null, p_identity_id: String = "",
			p_session_id: String = "", p_session_issued_at: int = 0,
			p_session_expires_at: int = 0) -> void:
		name = p_name
		id = p_id
		metadata = p_metadata
		value = p_value
		timestamp = p_timestamp if p_timestamp else Satori.timestamp()
		identity_id = p_identity_id
		session_id = p_session_id
		session_issued_at = p_session_issued_at
		session_expires_at = p_session_expires_at


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not name.is_empty():
			_fields.append('"name":' + JSON.stringify(name))
		if not id.is_empty():
			_fields.append('"id":' + JSON.stringify(id))
		if not value.is_empty():
			_fields.append('"value":' + JSON.stringify(value))
		if timestamp != null:
			_fields.append('"timestamp":' + JSON.stringify(timestamp))
		if not identity_id.is_empty():
			_fields.append('"identity_id":' + JSON.stringify(identity_id))
		if not session_id.is_empty():
			_fields.append('"session_id":' + JSON.stringify(session_id))
		if session_issued_at != 0:
			_fields.append('"session_issued_at":' + JSON.stringify(session_issued_at))
		if session_expires_at != 0:
			_fields.append('"session_expires_at":' + JSON.stringify(session_expires_at))
		var _map_metadata := PackedStringArray()
		for _k: Variant in metadata:
			var _v: String = str(metadata[_k])
			_map_metadata.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"metadata":{%s}' % ",".join(_map_metadata))
		return "{%s}" % ",".join(_fields)


## Publish an event to the server.
class EventRequest:
	extends RefCounted
	var events: Array = []


	static func from_json(_json: Variant) -> EventRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := EventRequest.new()
		var _list_events: Array = _data.get("events", [])
		_message.events = _list_events.map(func(_v: Variant) -> Event: return Event.from_json(_v))
		return _message


	func _init(p_events: Array = []) -> void:
		events = p_events


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"events":[%s]' % ",".join(PackedStringArray(events.map(func(_v: Event) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## An experiment that this identity is participating in.
class Experiment:
	extends RefCounted
	var name: String
	var value: String
	var phase_name: String
	var phase_variant_name: String
	var labels: Array = []
	var flag_names: Array = []


	static func from_json(_json: Variant) -> Experiment:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Experiment.new()
		_message.name = _data.get("name", "")
		_message.value = _data.get("value", "")
		_message.phase_name = _data.get("phase_name", "")
		_message.phase_variant_name = _data.get("phase_variant_name", "")
		_message.labels = _data.get("labels", [])
		_message.flag_names = _data.get("flag_names", [])
		return _message


	func _init(p_name: String = "", p_value: String = "", p_labels: Array = [],
			p_phase_name: String = "", p_phase_variant_name: String = "",
			p_flag_names: Array = []) -> void:
		name = p_name
		value = p_value
		labels = p_labels
		phase_name = p_phase_name
		phase_variant_name = p_phase_variant_name
		flag_names = p_flag_names


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not name.is_empty():
			_fields.append('"name":' + JSON.stringify(name))
		if not value.is_empty():
			_fields.append('"value":' + JSON.stringify(value))
		if not phase_name.is_empty():
			_fields.append('"phase_name":' + JSON.stringify(phase_name))
		if not phase_variant_name.is_empty():
			_fields.append('"phase_variant_name":' + JSON.stringify(phase_variant_name))
		_fields.append('"labels":[%s]' % ",".join(PackedStringArray(labels.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		_fields.append('"flag_names":[%s]' % ",".join(PackedStringArray(flag_names.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## All experiments that this identity is involved with.
class ExperimentList:
	extends RefCounted
	var experiments: Array = []


	static func from_json(_json: Variant) -> ExperimentList:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ExperimentList.new()
		var _list_experiments: Array = _data.get("experiments", [])
		_message.experiments = _list_experiments.map(func(_v: Variant) -> Experiment: return Experiment.from_json(_v))
		return _message


	func _init(p_experiments: Array = []) -> void:
		experiments = p_experiments


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"experiments":[%s]' % ",".join(PackedStringArray(experiments.map(func(_v: Experiment) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


class FlagValueChangeReason:
	extends RefCounted
	var type: FlagValueChangeReasonType
	var name: String
	var variant_name: String


	static func from_json(_json: Variant) -> FlagValueChangeReason:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := FlagValueChangeReason.new()
		_message.type = type_convert(_data.get("type", 0), TYPE_INT)
		_message.name = _data.get("name", "")
		_message.variant_name = _data.get("variant_name", "")
		return _message


	func _init(p_type: FlagValueChangeReasonType = FlagValueChangeReasonType.UNKNOWN,
			p_name: String = "", p_variant_name: String = "") -> void:
		type = p_type
		name = p_name
		variant_name = p_variant_name


	func to_json() -> String:
		var _fields := PackedStringArray()
		if type != 0:
			_fields.append('"type":' + JSON.stringify(type))
		if not name.is_empty():
			_fields.append('"name":' + JSON.stringify(name))
		if not variant_name.is_empty():
			_fields.append('"variant_name":' + JSON.stringify(variant_name))
		return "{%s}" % ",".join(_fields)


## Feature flag available to the identity.
class Flag:
	extends RefCounted
	var name: String
	var value: String
	var condition_changed: bool
	var change_reason: FlagValueChangeReason
	var labels: Array = []


	static func from_json(_json: Variant) -> Flag:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Flag.new()
		_message.name = _data.get("name", "")
		_message.value = _data.get("value", "")
		_message.condition_changed = _data.get("condition_changed", false)
		_message.change_reason = FlagValueChangeReason.from_json(_data["change_reason"]) if _data.get("change_reason") != null else null
		_message.labels = _data.get("labels", [])
		return _message


	func _init(p_name: String = "", p_value: String = "", p_condition_changed: bool = false,
			p_change_reason: FlagValueChangeReason = null, p_labels: Array = []) -> void:
		name = p_name
		value = p_value
		condition_changed = p_condition_changed
		change_reason = p_change_reason
		labels = p_labels


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not name.is_empty():
			_fields.append('"name":' + JSON.stringify(name))
		if not value.is_empty():
			_fields.append('"value":' + JSON.stringify(value))
		if condition_changed:
			_fields.append('"condition_changed":' + JSON.stringify(condition_changed))
		if change_reason != null:
			_fields.append('"change_reason":' + change_reason.to_json())
		_fields.append('"labels":[%s]' % ",".join(PackedStringArray(labels.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## All flags available to the identity.
class FlagList:
	extends RefCounted
	var flags: Array = []


	static func from_json(_json: Variant) -> FlagList:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := FlagList.new()
		var _list_flags: Array = _data.get("flags", [])
		_message.flags = _list_flags.map(func(_v: Variant) -> Flag: return Flag.from_json(_v))
		return _message


	func _init(p_flags: Array = []) -> void:
		flags = p_flags


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"flags":[%s]' % ",".join(PackedStringArray(flags.map(func(_v: Flag) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## The details of a flag value override.
class FlagOverrideValue:
	extends RefCounted
	var type: FlagOverrideType
	var name: String
	var variant_name: String
	var value: String
	var create_time_sec: int


	static func from_json(_json: Variant) -> FlagOverrideValue:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := FlagOverrideValue.new()
		_message.type = type_convert(_data.get("type", 0), TYPE_INT)
		_message.name = _data.get("name", "")
		_message.variant_name = _data.get("variant_name", "")
		_message.value = _data.get("value", "")
		_message.create_time_sec = type_convert(_data.get("create_time_sec", 0), TYPE_INT)
		return _message


	func _init(p_type: FlagOverrideType = FlagOverrideType.FLAG, p_name: String = "",
			p_variant_name: String = "", p_value: String = "", p_create_time_sec: int = 0) -> void:
		type = p_type
		name = p_name
		variant_name = p_variant_name
		value = p_value
		create_time_sec = p_create_time_sec


	func to_json() -> String:
		var _fields := PackedStringArray()
		if type != 0:
			_fields.append('"type":' + JSON.stringify(type))
		if not name.is_empty():
			_fields.append('"name":' + JSON.stringify(name))
		if not variant_name.is_empty():
			_fields.append('"variant_name":' + JSON.stringify(variant_name))
		if not value.is_empty():
			_fields.append('"value":' + JSON.stringify(value))
		if create_time_sec != 0:
			_fields.append('"create_time_sec":' + JSON.stringify(create_time_sec))
		return "{%s}" % ",".join(_fields)


## A feature flag and its value overrides available to the identity.
class FlagOverride:
	extends RefCounted
	var flag_name: String
	var overrides: Array = []
	var labels: Array = []


	static func from_json(_json: Variant) -> FlagOverride:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := FlagOverride.new()
		_message.flag_name = _data.get("flag_name", "")
		var _list_overrides: Array = _data.get("overrides", [])
		_message.overrides = _list_overrides.map(func(_v: Variant) -> FlagOverrideValue: return FlagOverrideValue.from_json(_v))
		_message.labels = _data.get("labels", [])
		return _message


	func _init(p_flag_name: String = "", p_overrides: Array = [], p_labels: Array = []) -> void:
		flag_name = p_flag_name
		overrides = p_overrides
		labels = p_labels


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not flag_name.is_empty():
			_fields.append('"flag_name":' + JSON.stringify(flag_name))
		_fields.append('"overrides":[%s]' % ",".join(PackedStringArray(overrides.map(func(_v: FlagOverrideValue) -> String: return _v.to_json()))))
		_fields.append('"labels":[%s]' % ",".join(PackedStringArray(labels.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## All flags available to the identity and their value overrides.
class FlagOverrideList:
	extends RefCounted
	var flags: Array = []


	static func from_json(_json: Variant) -> FlagOverrideList:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := FlagOverrideList.new()
		var _list_flags: Array = _data.get("flags", [])
		_message.flags = _list_flags.map(func(_v: Variant) -> FlagOverride: return FlagOverride.from_json(_v))
		return _message


	func _init(p_flags: Array = []) -> void:
		flags = p_flags


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"flags":[%s]' % ",".join(PackedStringArray(flags.map(func(_v: FlagOverride) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Request to get all experiment data.
class GetExperimentsRequest:
	extends RefCounted
	var names: Array = []
	var labels: Array = []


	static func from_json(_json: Variant) -> GetExperimentsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := GetExperimentsRequest.new()
		_message.names = _data.get("names", [])
		_message.labels = _data.get("labels", [])
		return _message


	func _init(p_names: Array = [], p_labels: Array = []) -> void:
		names = p_names
		labels = p_labels


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"names":[%s]' % ",".join(PackedStringArray(names.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		_fields.append('"labels":[%s]' % ",".join(PackedStringArray(labels.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## Request to get all flags data.
class GetFlagsRequest:
	extends RefCounted
	var names: Array = []
	var labels: Array = []


	static func from_json(_json: Variant) -> GetFlagsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := GetFlagsRequest.new()
		_message.names = _data.get("names", [])
		_message.labels = _data.get("labels", [])
		return _message


	func _init(p_names: Array = [], p_labels: Array = []) -> void:
		names = p_names
		labels = p_labels


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"names":[%s]' % ",".join(PackedStringArray(names.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		_fields.append('"labels":[%s]' % ",".join(PackedStringArray(labels.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## Request to get all live events.
class GetLiveEventsRequest:
	extends RefCounted
	var past_run_count: int
	var future_run_count: int
	var start_time_sec: int
	var end_time_sec: int
	var names: Array = []
	var labels: Array = []


	static func from_json(_json: Variant) -> GetLiveEventsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := GetLiveEventsRequest.new()
		_message.past_run_count = type_convert(_data.get("past_run_count", 0), TYPE_INT)
		_message.future_run_count = type_convert(_data.get("future_run_count", 0), TYPE_INT)
		_message.start_time_sec = type_convert(_data.get("start_time_sec", 0), TYPE_INT)
		_message.end_time_sec = type_convert(_data.get("end_time_sec", 0), TYPE_INT)
		_message.names = _data.get("names", [])
		_message.labels = _data.get("labels", [])
		return _message


	func _init(p_names: Array = [], p_labels: Array = [], p_past_run_count: int = 0,
			p_future_run_count: int = 0, p_start_time_sec: int = 0,
			p_end_time_sec: int = 0) -> void:
		names = p_names
		labels = p_labels
		past_run_count = p_past_run_count
		future_run_count = p_future_run_count
		start_time_sec = p_start_time_sec
		end_time_sec = p_end_time_sec


	func to_json() -> String:
		var _fields := PackedStringArray()
		if past_run_count != 0:
			_fields.append('"past_run_count":' + JSON.stringify(past_run_count))
		if future_run_count != 0:
			_fields.append('"future_run_count":' + JSON.stringify(future_run_count))
		if start_time_sec != 0:
			_fields.append('"start_time_sec":' + JSON.stringify(start_time_sec))
		if end_time_sec != 0:
			_fields.append('"end_time_sec":' + JSON.stringify(end_time_sec))
		_fields.append('"names":[%s]' % ",".join(PackedStringArray(names.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		_fields.append('"labels":[%s]' % ",".join(PackedStringArray(labels.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## Request to join an 'explicit join' live event.
class JoinLiveEventRequest:
	extends RefCounted
	var id: String


	static func from_json(_json: Variant) -> JoinLiveEventRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := JoinLiveEventRequest.new()
		_message.id = _data.get("id", "")
		return _message


	func _init(p_id: String = "") -> void:
		id = p_id


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not id.is_empty():
			_fields.append('"id":' + JSON.stringify(id))
		return "{%s}" % ",".join(_fields)


## Enrich/replace the current session with a new ID.
class IdentifyRequest:
	extends RefCounted
	var id: String
	var default: Dictionary = {}
	var custom: Dictionary = {}


	static func from_json(_json: Variant) -> IdentifyRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := IdentifyRequest.new()
		_message.id = _data.get("id", "")
		var _map_default: Dictionary = _data.get("default", {})
		for _k: Variant in _map_default:
			_message.default[_k] = _map_default[_k]
		var _map_custom: Dictionary = _data.get("custom", {})
		for _k: Variant in _map_custom:
			_message.custom[_k] = _map_custom[_k]
		return _message


	func _init(p_id: String = "", p_default: Dictionary = {}, p_custom: Dictionary = {}) -> void:
		id = p_id
		default = p_default
		custom = p_custom


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not id.is_empty():
			_fields.append('"id":' + JSON.stringify(id))
		var _map_default := PackedStringArray()
		for _k: Variant in default:
			var _v: String = str(default[_k])
			_map_default.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"default":{%s}' % ",".join(_map_default))
		var _map_custom := PackedStringArray()
		for _k: Variant in custom:
			var _v: String = str(custom[_k])
			_map_custom.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"custom":{%s}' % ",".join(_map_custom))
		return "{%s}" % ",".join(_fields)


## A single live event.
class LiveEvent:
	extends RefCounted
	var name: String
	var description: String
	var value: String
	var active_start_time_sec: int
	var active_end_time_sec: int
	var id: String
	var start_time_sec: int
	var end_time_sec: int
	var duration_sec: int
	var reset_cron: String
	var status: LiveEventStatus
	var active_participation_end_time_sec: int
	var labels: Array = []
	var flag_names: Array = []


	static func from_json(_json: Variant) -> LiveEvent:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := LiveEvent.new()
		_message.name = _data.get("name", "")
		_message.description = _data.get("description", "")
		_message.value = _data.get("value", "")
		_message.active_start_time_sec = type_convert(_data.get("active_start_time_sec", 0), TYPE_INT)
		_message.active_end_time_sec = type_convert(_data.get("active_end_time_sec", 0), TYPE_INT)
		_message.id = _data.get("id", "")
		_message.start_time_sec = type_convert(_data.get("start_time_sec", 0), TYPE_INT)
		_message.end_time_sec = type_convert(_data.get("end_time_sec", 0), TYPE_INT)
		_message.duration_sec = type_convert(_data.get("duration_sec", 0), TYPE_INT)
		_message.reset_cron = _data.get("reset_cron", "")
		_message.status = type_convert(_data.get("status", 0), TYPE_INT)
		_message.active_participation_end_time_sec = type_convert(_data.get("active_participation_end_time_sec", 0), TYPE_INT)
		_message.labels = _data.get("labels", [])
		_message.flag_names = _data.get("flag_names", [])
		return _message


	func _init(p_name: String = "", p_description: String = "", p_value: String = "",
			p_active_start_time_sec: int = 0, p_active_end_time_sec: int = 0, p_id: String = "",
			p_start_time_sec: int = 0, p_end_time_sec: int = 0, p_duration_sec: int = 0,
			p_reset_cron: String = "", p_status: LiveEventStatus = LiveEventStatus.UNKNOWN,
			p_labels: Array = [], p_flag_names: Array = [],
			p_active_participation_end_time_sec: int = 0) -> void:
		name = p_name
		description = p_description
		value = p_value
		active_start_time_sec = p_active_start_time_sec
		active_end_time_sec = p_active_end_time_sec
		id = p_id
		start_time_sec = p_start_time_sec
		end_time_sec = p_end_time_sec
		duration_sec = p_duration_sec
		reset_cron = p_reset_cron
		status = p_status
		labels = p_labels
		flag_names = p_flag_names
		active_participation_end_time_sec = p_active_participation_end_time_sec


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not name.is_empty():
			_fields.append('"name":' + JSON.stringify(name))
		if not description.is_empty():
			_fields.append('"description":' + JSON.stringify(description))
		if not value.is_empty():
			_fields.append('"value":' + JSON.stringify(value))
		if active_start_time_sec != 0:
			_fields.append('"active_start_time_sec":' + JSON.stringify(active_start_time_sec))
		if active_end_time_sec != 0:
			_fields.append('"active_end_time_sec":' + JSON.stringify(active_end_time_sec))
		if not id.is_empty():
			_fields.append('"id":' + JSON.stringify(id))
		if start_time_sec != 0:
			_fields.append('"start_time_sec":' + JSON.stringify(start_time_sec))
		if end_time_sec != 0:
			_fields.append('"end_time_sec":' + JSON.stringify(end_time_sec))
		if duration_sec != 0:
			_fields.append('"duration_sec":' + JSON.stringify(duration_sec))
		if not reset_cron.is_empty():
			_fields.append('"reset_cron":' + JSON.stringify(reset_cron))
		if status != 0:
			_fields.append('"status":' + JSON.stringify(status))
		if active_participation_end_time_sec != 0:
			_fields.append('"active_participation_end_time_sec":' + JSON.stringify(active_participation_end_time_sec))
		_fields.append('"labels":[%s]' % ",".join(PackedStringArray(labels.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		_fields.append('"flag_names":[%s]' % ",".join(PackedStringArray(flag_names.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## List of live events.
class LiveEventList:
	extends RefCounted
	var live_events: Array = []
	var explicit_join_live_events: Array = []


	static func from_json(_json: Variant) -> LiveEventList:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := LiveEventList.new()
		var _list_live_events: Array = _data.get("live_events", [])
		_message.live_events = _list_live_events.map(func(_v: Variant) -> LiveEvent: return LiveEvent.from_json(_v))
		var _list_explicit_join_live_events: Array = _data.get("explicit_join_live_events", [])
		_message.explicit_join_live_events = _list_explicit_join_live_events.map(func(_v: Variant) -> LiveEvent: return LiveEvent.from_json(_v))
		return _message


	func _init(p_live_events: Array = [], p_explicit_join_live_events: Array = []) -> void:
		live_events = p_live_events
		explicit_join_live_events = p_explicit_join_live_events


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"live_events":[%s]' % ",".join(PackedStringArray(live_events.map(func(_v: LiveEvent) -> String: return _v.to_json()))))
		_fields.append('"explicit_join_live_events":[%s]' % ",".join(PackedStringArray(explicit_join_live_events.map(func(_v: LiveEvent) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Properties associated with an identity.
class Properties:
	extends RefCounted
	var default: Dictionary = {}
	var computed: Dictionary = {}
	var custom: Dictionary = {}


	static func from_json(_json: Variant) -> Properties:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Properties.new()
		var _map_default: Dictionary = _data.get("default", {})
		for _k: Variant in _map_default:
			_message.default[_k] = _map_default[_k]
		var _map_computed: Dictionary = _data.get("computed", {})
		for _k: Variant in _map_computed:
			_message.computed[_k] = _map_computed[_k]
		var _map_custom: Dictionary = _data.get("custom", {})
		for _k: Variant in _map_custom:
			_message.custom[_k] = _map_custom[_k]
		return _message


	func _init(p_default: Dictionary = {}, p_computed: Dictionary = {},
			p_custom: Dictionary = {}) -> void:
		default = p_default
		computed = p_computed
		custom = p_custom


	func to_json() -> String:
		var _fields := PackedStringArray()
		var _map_default := PackedStringArray()
		for _k: Variant in default:
			var _v: String = str(default[_k])
			_map_default.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"default":{%s}' % ",".join(_map_default))
		var _map_computed := PackedStringArray()
		for _k: Variant in computed:
			var _v: String = str(computed[_k])
			_map_computed.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"computed":{%s}' % ",".join(_map_computed))
		var _map_custom := PackedStringArray()
		for _k: Variant in custom:
			var _v: String = str(custom[_k])
			_map_custom.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"custom":{%s}' % ",".join(_map_custom))
		return "{%s}" % ",".join(_fields)


## Update properties associated with this identity.
class UpdatePropertiesRequest:
	extends RefCounted
	## bool, or null when unset.
	var recompute: Variant
	var default: Dictionary = {}
	var custom: Dictionary = {}


	static func from_json(_json: Variant) -> UpdatePropertiesRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := UpdatePropertiesRequest.new()
		_message.recompute = _data["recompute"] if _data.get("recompute") != null else null
		var _map_default: Dictionary = _data.get("default", {})
		for _k: Variant in _map_default:
			_message.default[_k] = _map_default[_k]
		var _map_custom: Dictionary = _data.get("custom", {})
		for _k: Variant in _map_custom:
			_message.custom[_k] = _map_custom[_k]
		return _message


	func _init(p_default: Dictionary = {}, p_custom: Dictionary = {},
			p_recompute: Variant = null) -> void:
		default = p_default
		custom = p_custom
		recompute = p_recompute


	func to_json() -> String:
		var _fields := PackedStringArray()
		if recompute != null:
			_fields.append('"recompute":' + JSON.stringify(recompute))
		var _map_default := PackedStringArray()
		for _k: Variant in default:
			var _v: String = str(default[_k])
			_map_default.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"default":{%s}' % ",".join(_map_default))
		var _map_custom := PackedStringArray()
		for _k: Variant in custom:
			var _v: String = str(custom[_k])
			_map_custom.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"custom":{%s}' % ",".join(_map_custom))
		return "{%s}" % ",".join(_fields)


class GetMessageListRequest:
	extends RefCounted
	var limit: int
	var forward: bool
	var cursor: String
	var message_ids: Array = []


	static func from_json(_json: Variant) -> GetMessageListRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := GetMessageListRequest.new()
		_message.limit = type_convert(_data.get("limit", 0), TYPE_INT)
		_message.forward = _data.get("forward", false)
		_message.cursor = _data.get("cursor", "")
		_message.message_ids = _data.get("message_ids", [])
		return _message


	func _init(p_limit: int = 0, p_forward: bool = false, p_cursor: String = "",
			p_message_ids: Array = []) -> void:
		limit = p_limit
		forward = p_forward
		cursor = p_cursor
		message_ids = p_message_ids


	func to_json() -> String:
		var _fields := PackedStringArray()
		if limit != 0:
			_fields.append('"limit":' + JSON.stringify(limit))
		if forward:
			_fields.append('"forward":' + JSON.stringify(forward))
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		_fields.append('"message_ids":[%s]' % ",".join(PackedStringArray(message_ids.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## A scheduled message.
class Message:
	extends RefCounted
	var schedule_id: String
	var send_time: int
	var create_time: int
	var update_time: int
	var read_time: int
	var consume_time: int
	var text: String
	var id: String
	var title: String
	var image_url: String
	var metadata: Dictionary = {}


	static func from_json(_json: Variant) -> Message:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Message.new()
		_message.schedule_id = _data.get("schedule_id", "")
		_message.send_time = type_convert(_data.get("send_time", 0), TYPE_INT)
		_message.create_time = type_convert(_data.get("create_time", 0), TYPE_INT)
		_message.update_time = type_convert(_data.get("update_time", 0), TYPE_INT)
		_message.read_time = type_convert(_data.get("read_time", 0), TYPE_INT)
		_message.consume_time = type_convert(_data.get("consume_time", 0), TYPE_INT)
		_message.text = _data.get("text", "")
		_message.id = _data.get("id", "")
		_message.title = _data.get("title", "")
		_message.image_url = _data.get("image_url", "")
		var _map_metadata: Dictionary = _data.get("metadata", {})
		for _k: Variant in _map_metadata:
			_message.metadata[_k] = _map_metadata[_k]
		return _message


	func _init(p_schedule_id: String = "", p_send_time: int = 0, p_metadata: Dictionary = {},
			p_create_time: int = 0, p_update_time: int = 0, p_read_time: int = 0,
			p_consume_time: int = 0, p_text: String = "", p_id: String = "", p_title: String = "",
			p_image_url: String = "") -> void:
		schedule_id = p_schedule_id
		send_time = p_send_time
		metadata = p_metadata
		create_time = p_create_time
		update_time = p_update_time
		read_time = p_read_time
		consume_time = p_consume_time
		text = p_text
		id = p_id
		title = p_title
		image_url = p_image_url


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not schedule_id.is_empty():
			_fields.append('"schedule_id":' + JSON.stringify(schedule_id))
		if send_time != 0:
			_fields.append('"send_time":' + JSON.stringify(send_time))
		if create_time != 0:
			_fields.append('"create_time":' + JSON.stringify(create_time))
		if update_time != 0:
			_fields.append('"update_time":' + JSON.stringify(update_time))
		if read_time != 0:
			_fields.append('"read_time":' + JSON.stringify(read_time))
		if consume_time != 0:
			_fields.append('"consume_time":' + JSON.stringify(consume_time))
		if not text.is_empty():
			_fields.append('"text":' + JSON.stringify(text))
		if not id.is_empty():
			_fields.append('"id":' + JSON.stringify(id))
		if not title.is_empty():
			_fields.append('"title":' + JSON.stringify(title))
		if not image_url.is_empty():
			_fields.append('"image_url":' + JSON.stringify(image_url))
		var _map_metadata := PackedStringArray()
		for _k: Variant in metadata:
			var _v: String = str(metadata[_k])
			_map_metadata.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"metadata":{%s}' % ",".join(_map_metadata))
		return "{%s}" % ",".join(_fields)


## A response containing all the messages for an identity.
class GetMessageListResponse:
	extends RefCounted
	var next_cursor: String
	var prev_cursor: String
	var cacheable_cursor: String
	var messages: Array = []


	static func from_json(_json: Variant) -> GetMessageListResponse:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := GetMessageListResponse.new()
		_message.next_cursor = _data.get("next_cursor", "")
		_message.prev_cursor = _data.get("prev_cursor", "")
		_message.cacheable_cursor = _data.get("cacheable_cursor", "")
		var _list_messages: Array = _data.get("messages", [])
		_message.messages = _list_messages.map(func(_v: Variant) -> Message: return Message.from_json(_v))
		return _message


	func _init(p_messages: Array = [], p_next_cursor: String = "", p_prev_cursor: String = "",
			p_cacheable_cursor: String = "") -> void:
		messages = p_messages
		next_cursor = p_next_cursor
		prev_cursor = p_prev_cursor
		cacheable_cursor = p_cacheable_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not next_cursor.is_empty():
			_fields.append('"next_cursor":' + JSON.stringify(next_cursor))
		if not prev_cursor.is_empty():
			_fields.append('"prev_cursor":' + JSON.stringify(prev_cursor))
		if not cacheable_cursor.is_empty():
			_fields.append('"cacheable_cursor":' + JSON.stringify(cacheable_cursor))
		_fields.append('"messages":[%s]' % ",".join(PackedStringArray(messages.map(func(_v: Message) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## The request to update the status of a message.
class UpdateMessageRequest:
	extends RefCounted
	var id: String
	var read_time: int
	var consume_time: int


	static func from_json(_json: Variant) -> UpdateMessageRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := UpdateMessageRequest.new()
		_message.id = _data.get("id", "")
		_message.read_time = type_convert(_data.get("read_time", 0), TYPE_INT)
		_message.consume_time = type_convert(_data.get("consume_time", 0), TYPE_INT)
		return _message


	func _init(p_id: String = "", p_read_time: int = 0, p_consume_time: int = 0) -> void:
		id = p_id
		read_time = p_read_time
		consume_time = p_consume_time


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not id.is_empty():
			_fields.append('"id":' + JSON.stringify(id))
		if read_time != 0:
			_fields.append('"read_time":' + JSON.stringify(read_time))
		if consume_time != 0:
			_fields.append('"consume_time":' + JSON.stringify(consume_time))
		return "{%s}" % ",".join(_fields)


## The request to delete a scheduled message.
class DeleteMessageRequest:
	extends RefCounted
	var id: String


	static func from_json(_json: Variant) -> DeleteMessageRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := DeleteMessageRequest.new()
		_message.id = _data.get("id", "")
		return _message


	func _init(p_id: String = "") -> void:
		id = p_id


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not id.is_empty():
			_fields.append('"id":' + JSON.stringify(id))
		return "{%s}" % ",".join(_fields)

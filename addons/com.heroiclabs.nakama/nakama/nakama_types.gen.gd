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
class_name NakamaTypes
extends RefCounted

## The friendship status.
enum FriendState {
	FRIEND = 0,
	INVITE_SENT = 1,
	INVITE_RECEIVED = 2,
	BLOCKED = 3,
}

## The group role status.
enum GroupUserListGroupUserState {
	SUPERADMIN = 0,
	ADMIN = 1,
	MEMBER = 2,
	JOIN_REQUEST = 3,
}

## The group role status.
enum UserGroupListUserGroupState {
	SUPERADMIN = 0,
	ADMIN = 1,
	MEMBER = 2,
	JOIN_REQUEST = 3,
}

## Validation provider.
enum StoreProvider {
	APPLE_APP_STORE = 0,
	GOOGLE_PLAY_STORE = 1,
	HUAWEI_APP_GALLERY = 2,
	FACEBOOK_INSTANT_STORE = 3,
	SAMSUNG_GALAXY_STORE = 4,
}

## Environment where a purchase/subscription took place.
enum StoreEnvironment {
	UNKNOWN = 0,
	SANDBOX = 1,
	PRODUCTION = 2,
}

## Operator that can be used to override the one set in the leaderboard.
enum Operator {
	NO_OVERRIDE = 0,
	BEST = 1,
	SET = 2,
	INCREMENT = 3,
	DECREMENT = 4,
}


## A user on the server.
class User:
	extends RefCounted
	var id: String
	var username: String
	var display_name: String
	var avatar_url: String
	var lang_tag: String
	var location: String
	var timezone: String
	var metadata: String
	var facebook_id: String
	var google_id: String
	var gamecenter_id: String
	var steam_id: String
	var online: bool
	var edge_count: int
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var create_time: Variant
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var update_time: Variant
	var facebook_instant_game_id: String
	var apple_id: String


	static func from_json(_json: Variant) -> User:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := User.new()
		_message.id = _data.get("id", "")
		_message.username = _data.get("username", "")
		_message.display_name = _data.get("display_name", "")
		_message.avatar_url = _data.get("avatar_url", "")
		_message.lang_tag = _data.get("lang_tag", "")
		_message.location = _data.get("location", "")
		_message.timezone = _data.get("timezone", "")
		_message.metadata = _data.get("metadata", "")
		_message.facebook_id = _data.get("facebook_id", "")
		_message.google_id = _data.get("google_id", "")
		_message.gamecenter_id = _data.get("gamecenter_id", "")
		_message.steam_id = _data.get("steam_id", "")
		_message.online = _data.get("online", false)
		_message.edge_count = type_convert(_data.get("edge_count", 0), TYPE_INT)
		_message.create_time = _data.get("create_time")
		_message.update_time = _data.get("update_time")
		_message.facebook_instant_game_id = _data.get("facebook_instant_game_id", "")
		_message.apple_id = _data.get("apple_id", "")
		return _message


	func _init(p_id: String = "", p_username: String = "", p_display_name: String = "",
			p_avatar_url: String = "", p_lang_tag: String = "", p_location: String = "",
			p_timezone: String = "", p_metadata: String = "", p_facebook_id: String = "",
			p_google_id: String = "", p_gamecenter_id: String = "", p_steam_id: String = "",
			p_online: bool = false, p_edge_count: int = 0, p_create_time: Variant = null,
			p_update_time: Variant = null, p_facebook_instant_game_id: String = "",
			p_apple_id: String = "") -> void:
		id = p_id
		username = p_username
		display_name = p_display_name
		avatar_url = p_avatar_url
		lang_tag = p_lang_tag
		location = p_location
		timezone = p_timezone
		metadata = p_metadata
		facebook_id = p_facebook_id
		google_id = p_google_id
		gamecenter_id = p_gamecenter_id
		steam_id = p_steam_id
		online = p_online
		edge_count = p_edge_count
		create_time = p_create_time
		update_time = p_update_time
		facebook_instant_game_id = p_facebook_instant_game_id
		apple_id = p_apple_id


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not id.is_empty():
			_fields.append('"id":' + JSON.stringify(id))
		if not username.is_empty():
			_fields.append('"username":' + JSON.stringify(username))
		if not display_name.is_empty():
			_fields.append('"display_name":' + JSON.stringify(display_name))
		if not avatar_url.is_empty():
			_fields.append('"avatar_url":' + JSON.stringify(avatar_url))
		if not lang_tag.is_empty():
			_fields.append('"lang_tag":' + JSON.stringify(lang_tag))
		if not location.is_empty():
			_fields.append('"location":' + JSON.stringify(location))
		if not timezone.is_empty():
			_fields.append('"timezone":' + JSON.stringify(timezone))
		if not metadata.is_empty():
			_fields.append('"metadata":' + JSON.stringify(metadata))
		if not facebook_id.is_empty():
			_fields.append('"facebook_id":' + JSON.stringify(facebook_id))
		if not google_id.is_empty():
			_fields.append('"google_id":' + JSON.stringify(google_id))
		if not gamecenter_id.is_empty():
			_fields.append('"gamecenter_id":' + JSON.stringify(gamecenter_id))
		if not steam_id.is_empty():
			_fields.append('"steam_id":' + JSON.stringify(steam_id))
		if online:
			_fields.append('"online":' + JSON.stringify(online))
		if edge_count != 0:
			_fields.append('"edge_count":' + JSON.stringify(edge_count))
		if create_time != null:
			_fields.append('"create_time":' + JSON.stringify(create_time))
		if update_time != null:
			_fields.append('"update_time":' + JSON.stringify(update_time))
		if not facebook_instant_game_id.is_empty():
			_fields.append('"facebook_instant_game_id":' + JSON.stringify(facebook_instant_game_id))
		if not apple_id.is_empty():
			_fields.append('"apple_id":' + JSON.stringify(apple_id))
		return "{%s}" % ",".join(_fields)


## Send a device to the server. Used with authenticate/link/unlink and user.
class AccountDevice:
	extends RefCounted
	var id: String
	var vars: Dictionary = {}


	static func from_json(_json: Variant) -> AccountDevice:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AccountDevice.new()
		_message.id = _data.get("id", "")
		var _map_vars: Dictionary = _data.get("vars", {})
		for _k: Variant in _map_vars:
			_message.vars[_k] = _map_vars[_k]
		return _message


	func _init(p_id: String = "", p_vars: Dictionary = {}) -> void:
		id = p_id
		vars = p_vars


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not id.is_empty():
			_fields.append('"id":' + JSON.stringify(id))
		var _map_vars := PackedStringArray()
		for _k: Variant in vars:
			var _v: String = str(vars[_k])
			_map_vars.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"vars":{%s}' % ",".join(_map_vars))
		return "{%s}" % ",".join(_fields)


## A provider identity linked to a user's account.
class AccountProviderIdentity:
	extends RefCounted
	var provider: String
	var provider_user_id: String


	static func from_json(_json: Variant) -> AccountProviderIdentity:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AccountProviderIdentity.new()
		_message.provider = _data.get("provider", "")
		_message.provider_user_id = _data.get("provider_user_id", "")
		return _message


	func _init(p_provider: String = "", p_provider_user_id: String = "") -> void:
		provider = p_provider
		provider_user_id = p_provider_user_id


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not provider.is_empty():
			_fields.append('"provider":' + JSON.stringify(provider))
		if not provider_user_id.is_empty():
			_fields.append('"provider_user_id":' + JSON.stringify(provider_user_id))
		return "{%s}" % ",".join(_fields)


## A user with additional account details. Always the current user.
class Account:
	extends RefCounted
	var user: User
	var wallet: String
	var email: String
	var custom_id: String
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var verify_time: Variant
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var disable_time: Variant
	var devices: Array = []
	var providers: Array = []


	static func from_json(_json: Variant) -> Account:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Account.new()
		_message.user = User.from_json(_data["user"]) if _data.get("user") != null else null
		_message.wallet = _data.get("wallet", "")
		_message.email = _data.get("email", "")
		_message.custom_id = _data.get("custom_id", "")
		_message.verify_time = _data.get("verify_time")
		_message.disable_time = _data.get("disable_time")
		var _list_devices: Array = _data.get("devices", [])
		_message.devices = _list_devices.map(func(_v: Variant) -> AccountDevice: return AccountDevice.from_json(_v))
		var _list_providers: Array = _data.get("providers", [])
		_message.providers = _list_providers.map(func(_v: Variant) -> AccountProviderIdentity: return AccountProviderIdentity.from_json(_v))
		return _message


	func _init(p_user: User = null, p_wallet: String = "", p_email: String = "",
			p_devices: Array = [], p_custom_id: String = "", p_verify_time: Variant = null,
			p_disable_time: Variant = null, p_providers: Array = []) -> void:
		user = p_user
		wallet = p_wallet
		email = p_email
		devices = p_devices
		custom_id = p_custom_id
		verify_time = p_verify_time
		disable_time = p_disable_time
		providers = p_providers


	func to_json() -> String:
		var _fields := PackedStringArray()
		if user != null:
			_fields.append('"user":' + user.to_json())
		if not wallet.is_empty():
			_fields.append('"wallet":' + JSON.stringify(wallet))
		if not email.is_empty():
			_fields.append('"email":' + JSON.stringify(email))
		if not custom_id.is_empty():
			_fields.append('"custom_id":' + JSON.stringify(custom_id))
		if verify_time != null:
			_fields.append('"verify_time":' + JSON.stringify(verify_time))
		if disable_time != null:
			_fields.append('"disable_time":' + JSON.stringify(disable_time))
		_fields.append('"devices":[%s]' % ",".join(PackedStringArray(devices.map(func(_v: AccountDevice) -> String: return _v.to_json()))))
		_fields.append('"providers":[%s]' % ",".join(PackedStringArray(providers.map(func(_v: AccountProviderIdentity) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Obtain a new authentication token using a refresh token.
class AccountRefresh:
	extends RefCounted
	var token: String
	var vars: Dictionary = {}


	static func from_json(_json: Variant) -> AccountRefresh:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AccountRefresh.new()
		_message.token = _data.get("token", "")
		var _map_vars: Dictionary = _data.get("vars", {})
		for _k: Variant in _map_vars:
			_message.vars[_k] = _map_vars[_k]
		return _message


	func _init(p_token: String = "", p_vars: Dictionary = {}) -> void:
		token = p_token
		vars = p_vars


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not token.is_empty():
			_fields.append('"token":' + JSON.stringify(token))
		var _map_vars := PackedStringArray()
		for _k: Variant in vars:
			var _v: String = str(vars[_k])
			_map_vars.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"vars":{%s}' % ",".join(_map_vars))
		return "{%s}" % ",".join(_fields)


## Send an Apple Sign In token to the server. Used with authenticate/link/unlink.
class AccountApple:
	extends RefCounted
	var token: String
	var vars: Dictionary = {}


	static func from_json(_json: Variant) -> AccountApple:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AccountApple.new()
		_message.token = _data.get("token", "")
		var _map_vars: Dictionary = _data.get("vars", {})
		for _k: Variant in _map_vars:
			_message.vars[_k] = _map_vars[_k]
		return _message


	func _init(p_token: String = "", p_vars: Dictionary = {}) -> void:
		token = p_token
		vars = p_vars


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not token.is_empty():
			_fields.append('"token":' + JSON.stringify(token))
		var _map_vars := PackedStringArray()
		for _k: Variant in vars:
			var _v: String = str(vars[_k])
			_map_vars.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"vars":{%s}' % ",".join(_map_vars))
		return "{%s}" % ",".join(_fields)


## Send a custom ID to the server. Used with authenticate/link/unlink.
class AccountCustom:
	extends RefCounted
	var id: String
	var vars: Dictionary = {}


	static func from_json(_json: Variant) -> AccountCustom:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AccountCustom.new()
		_message.id = _data.get("id", "")
		var _map_vars: Dictionary = _data.get("vars", {})
		for _k: Variant in _map_vars:
			_message.vars[_k] = _map_vars[_k]
		return _message


	func _init(p_id: String = "", p_vars: Dictionary = {}) -> void:
		id = p_id
		vars = p_vars


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not id.is_empty():
			_fields.append('"id":' + JSON.stringify(id))
		var _map_vars := PackedStringArray()
		for _k: Variant in vars:
			var _v: String = str(vars[_k])
			_map_vars.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"vars":{%s}' % ",".join(_map_vars))
		return "{%s}" % ",".join(_fields)


## Send an email with password to the server. Used with authenticate/link/unlink.
class AccountEmail:
	extends RefCounted
	var email: String
	var password: String
	var vars: Dictionary = {}


	static func from_json(_json: Variant) -> AccountEmail:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AccountEmail.new()
		_message.email = _data.get("email", "")
		_message.password = _data.get("password", "")
		var _map_vars: Dictionary = _data.get("vars", {})
		for _k: Variant in _map_vars:
			_message.vars[_k] = _map_vars[_k]
		return _message


	func _init(p_email: String = "", p_password: String = "", p_vars: Dictionary = {}) -> void:
		email = p_email
		password = p_password
		vars = p_vars


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not email.is_empty():
			_fields.append('"email":' + JSON.stringify(email))
		if not password.is_empty():
			_fields.append('"password":' + JSON.stringify(password))
		var _map_vars := PackedStringArray()
		for _k: Variant in vars:
			var _v: String = str(vars[_k])
			_map_vars.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"vars":{%s}' % ",".join(_map_vars))
		return "{%s}" % ",".join(_fields)


## Send a Facebook token to the server. Used with authenticate/link/unlink.
class AccountFacebook:
	extends RefCounted
	var token: String
	var vars: Dictionary = {}


	static func from_json(_json: Variant) -> AccountFacebook:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AccountFacebook.new()
		_message.token = _data.get("token", "")
		var _map_vars: Dictionary = _data.get("vars", {})
		for _k: Variant in _map_vars:
			_message.vars[_k] = _map_vars[_k]
		return _message


	func _init(p_token: String = "", p_vars: Dictionary = {}) -> void:
		token = p_token
		vars = p_vars


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not token.is_empty():
			_fields.append('"token":' + JSON.stringify(token))
		var _map_vars := PackedStringArray()
		for _k: Variant in vars:
			var _v: String = str(vars[_k])
			_map_vars.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"vars":{%s}' % ",".join(_map_vars))
		return "{%s}" % ",".join(_fields)


## Send a Facebook Instant Game token to the server. Used with authenticate/link/unlink.
class AccountFacebookInstantGame:
	extends RefCounted
	var signed_player_info: String
	var vars: Dictionary = {}


	static func from_json(_json: Variant) -> AccountFacebookInstantGame:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AccountFacebookInstantGame.new()
		_message.signed_player_info = _data.get("signed_player_info", "")
		var _map_vars: Dictionary = _data.get("vars", {})
		for _k: Variant in _map_vars:
			_message.vars[_k] = _map_vars[_k]
		return _message


	func _init(p_signed_player_info: String = "", p_vars: Dictionary = {}) -> void:
		signed_player_info = p_signed_player_info
		vars = p_vars


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not signed_player_info.is_empty():
			_fields.append('"signed_player_info":' + JSON.stringify(signed_player_info))
		var _map_vars := PackedStringArray()
		for _k: Variant in vars:
			var _v: String = str(vars[_k])
			_map_vars.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"vars":{%s}' % ",".join(_map_vars))
		return "{%s}" % ",".join(_fields)


## Send Apple's Game Center account credentials to the server. Used with authenticate/link/unlink.
class AccountGameCenter:
	extends RefCounted
	var player_id: String
	var bundle_id: String
	var timestamp_seconds: int
	var salt: String
	var signature: String
	var public_key_url: String
	var vars: Dictionary = {}


	static func from_json(_json: Variant) -> AccountGameCenter:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AccountGameCenter.new()
		_message.player_id = _data.get("player_id", "")
		_message.bundle_id = _data.get("bundle_id", "")
		_message.timestamp_seconds = type_convert(_data.get("timestamp_seconds", 0), TYPE_INT)
		_message.salt = _data.get("salt", "")
		_message.signature = _data.get("signature", "")
		_message.public_key_url = _data.get("public_key_url", "")
		var _map_vars: Dictionary = _data.get("vars", {})
		for _k: Variant in _map_vars:
			_message.vars[_k] = _map_vars[_k]
		return _message


	func _init(p_player_id: String = "", p_bundle_id: String = "", p_timestamp_seconds: int = 0,
			p_salt: String = "", p_signature: String = "", p_public_key_url: String = "",
			p_vars: Dictionary = {}) -> void:
		player_id = p_player_id
		bundle_id = p_bundle_id
		timestamp_seconds = p_timestamp_seconds
		salt = p_salt
		signature = p_signature
		public_key_url = p_public_key_url
		vars = p_vars


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not player_id.is_empty():
			_fields.append('"player_id":' + JSON.stringify(player_id))
		if not bundle_id.is_empty():
			_fields.append('"bundle_id":' + JSON.stringify(bundle_id))
		if timestamp_seconds != 0:
			_fields.append('"timestamp_seconds":' + JSON.stringify(timestamp_seconds))
		if not salt.is_empty():
			_fields.append('"salt":' + JSON.stringify(salt))
		if not signature.is_empty():
			_fields.append('"signature":' + JSON.stringify(signature))
		if not public_key_url.is_empty():
			_fields.append('"public_key_url":' + JSON.stringify(public_key_url))
		var _map_vars := PackedStringArray()
		for _k: Variant in vars:
			var _v: String = str(vars[_k])
			_map_vars.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"vars":{%s}' % ",".join(_map_vars))
		return "{%s}" % ",".join(_fields)


## Send a Google token to the server. Used with authenticate/link/unlink.
class AccountGoogle:
	extends RefCounted
	var token: String
	var vars: Dictionary = {}


	static func from_json(_json: Variant) -> AccountGoogle:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AccountGoogle.new()
		_message.token = _data.get("token", "")
		var _map_vars: Dictionary = _data.get("vars", {})
		for _k: Variant in _map_vars:
			_message.vars[_k] = _map_vars[_k]
		return _message


	func _init(p_token: String = "", p_vars: Dictionary = {}) -> void:
		token = p_token
		vars = p_vars


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not token.is_empty():
			_fields.append('"token":' + JSON.stringify(token))
		var _map_vars := PackedStringArray()
		for _k: Variant in vars:
			var _v: String = str(vars[_k])
			_map_vars.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"vars":{%s}' % ",".join(_map_vars))
		return "{%s}" % ",".join(_fields)


## Send credentials for a runtime-registered authentication provider. Used with authenticate/link/unlink.
class AccountProvider:
	extends RefCounted
	var provider: String
	## Dictionary, or null when unset.
	var payload: Variant
	var vars: Dictionary = {}


	static func from_json(_json: Variant) -> AccountProvider:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AccountProvider.new()
		_message.provider = _data.get("provider", "")
		_message.payload = _data.get("payload")
		var _map_vars: Dictionary = _data.get("vars", {})
		for _k: Variant in _map_vars:
			_message.vars[_k] = _map_vars[_k]
		return _message


	func _init(p_provider: String = "", p_payload: Variant = null, p_vars: Dictionary = {}) -> void:
		provider = p_provider
		payload = p_payload
		vars = p_vars


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not provider.is_empty():
			_fields.append('"provider":' + JSON.stringify(provider))
		if payload != null:
			_fields.append('"payload":' + JSON.stringify(payload))
		var _map_vars := PackedStringArray()
		for _k: Variant in vars:
			var _v: String = str(vars[_k])
			_map_vars.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"vars":{%s}' % ",".join(_map_vars))
		return "{%s}" % ",".join(_fields)


## Send a Steam token to the server. Used with authenticate/link/unlink.
class AccountSteam:
	extends RefCounted
	var token: String
	var vars: Dictionary = {}


	static func from_json(_json: Variant) -> AccountSteam:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AccountSteam.new()
		_message.token = _data.get("token", "")
		var _map_vars: Dictionary = _data.get("vars", {})
		for _k: Variant in _map_vars:
			_message.vars[_k] = _map_vars[_k]
		return _message


	func _init(p_token: String = "", p_vars: Dictionary = {}) -> void:
		token = p_token
		vars = p_vars


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not token.is_empty():
			_fields.append('"token":' + JSON.stringify(token))
		var _map_vars := PackedStringArray()
		for _k: Variant in vars:
			var _v: String = str(vars[_k])
			_map_vars.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"vars":{%s}' % ",".join(_map_vars))
		return "{%s}" % ",".join(_fields)


## Add one or more friends to the current user.
class AddFriendsRequest:
	extends RefCounted
	var metadata: String
	var ids: Array = []
	var usernames: Array = []


	static func from_json(_json: Variant) -> AddFriendsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AddFriendsRequest.new()
		_message.metadata = _data.get("metadata", "")
		_message.ids = _data.get("ids", [])
		_message.usernames = _data.get("usernames", [])
		return _message


	func _init(p_ids: Array = [], p_usernames: Array = [], p_metadata: String = "") -> void:
		ids = p_ids
		usernames = p_usernames
		metadata = p_metadata


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not metadata.is_empty():
			_fields.append('"metadata":' + JSON.stringify(metadata))
		_fields.append('"ids":[%s]' % ",".join(PackedStringArray(ids.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		_fields.append('"usernames":[%s]' % ",".join(PackedStringArray(usernames.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## Add users to a group.
class AddGroupUsersRequest:
	extends RefCounted
	var group_id: String
	var user_ids: Array = []


	static func from_json(_json: Variant) -> AddGroupUsersRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AddGroupUsersRequest.new()
		_message.group_id = _data.get("group_id", "")
		_message.user_ids = _data.get("user_ids", [])
		return _message


	func _init(p_group_id: String = "", p_user_ids: Array = []) -> void:
		group_id = p_group_id
		user_ids = p_user_ids


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not group_id.is_empty():
			_fields.append('"group_id":' + JSON.stringify(group_id))
		_fields.append('"user_ids":[%s]' % ",".join(PackedStringArray(user_ids.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## Authenticate against the server with a refresh token.
class SessionRefreshRequest:
	extends RefCounted
	var token: String
	var vars: Dictionary = {}


	static func from_json(_json: Variant) -> SessionRefreshRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := SessionRefreshRequest.new()
		_message.token = _data.get("token", "")
		var _map_vars: Dictionary = _data.get("vars", {})
		for _k: Variant in _map_vars:
			_message.vars[_k] = _map_vars[_k]
		return _message


	func _init(p_token: String = "", p_vars: Dictionary = {}) -> void:
		token = p_token
		vars = p_vars


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not token.is_empty():
			_fields.append('"token":' + JSON.stringify(token))
		var _map_vars := PackedStringArray()
		for _k: Variant in vars:
			var _v: String = str(vars[_k])
			_map_vars.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"vars":{%s}' % ",".join(_map_vars))
		return "{%s}" % ",".join(_fields)


## Log out a session, invalidate a refresh token, or log out all sessions/refresh tokens for a user.
class SessionLogoutRequest:
	extends RefCounted
	var token: String
	var refresh_token: String


	static func from_json(_json: Variant) -> SessionLogoutRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := SessionLogoutRequest.new()
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


## Authenticate against the server with Apple Sign In.
class AuthenticateAppleRequest:
	extends RefCounted
	var account: AccountApple
	## bool, or null when unset.
	var create: Variant
	var username: String


	static func from_json(_json: Variant) -> AuthenticateAppleRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AuthenticateAppleRequest.new()
		_message.account = AccountApple.from_json(_data["account"]) if _data.get("account") != null else null
		_message.create = _data["create"] if _data.get("create") != null else null
		_message.username = _data.get("username", "")
		return _message


	func _init(p_account: AccountApple = null, p_create: Variant = null,
			p_username: String = "") -> void:
		account = p_account
		create = p_create
		username = p_username


	func to_json() -> String:
		var _fields := PackedStringArray()
		if account != null:
			_fields.append('"account":' + account.to_json())
		if create != null:
			_fields.append('"create":' + JSON.stringify(create))
		if not username.is_empty():
			_fields.append('"username":' + JSON.stringify(username))
		return "{%s}" % ",".join(_fields)


## Authenticate against the server with a custom ID.
class AuthenticateCustomRequest:
	extends RefCounted
	var account: AccountCustom
	## bool, or null when unset.
	var create: Variant
	var username: String


	static func from_json(_json: Variant) -> AuthenticateCustomRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AuthenticateCustomRequest.new()
		_message.account = AccountCustom.from_json(_data["account"]) if _data.get("account") != null else null
		_message.create = _data["create"] if _data.get("create") != null else null
		_message.username = _data.get("username", "")
		return _message


	func _init(p_account: AccountCustom = null, p_create: Variant = null,
			p_username: String = "") -> void:
		account = p_account
		create = p_create
		username = p_username


	func to_json() -> String:
		var _fields := PackedStringArray()
		if account != null:
			_fields.append('"account":' + account.to_json())
		if create != null:
			_fields.append('"create":' + JSON.stringify(create))
		if not username.is_empty():
			_fields.append('"username":' + JSON.stringify(username))
		return "{%s}" % ",".join(_fields)


## Authenticate against the server with a device ID.
class AuthenticateDeviceRequest:
	extends RefCounted
	var account: AccountDevice
	## bool, or null when unset.
	var create: Variant
	var username: String


	static func from_json(_json: Variant) -> AuthenticateDeviceRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AuthenticateDeviceRequest.new()
		_message.account = AccountDevice.from_json(_data["account"]) if _data.get("account") != null else null
		_message.create = _data["create"] if _data.get("create") != null else null
		_message.username = _data.get("username", "")
		return _message


	func _init(p_account: AccountDevice = null, p_create: Variant = null,
			p_username: String = "") -> void:
		account = p_account
		create = p_create
		username = p_username


	func to_json() -> String:
		var _fields := PackedStringArray()
		if account != null:
			_fields.append('"account":' + account.to_json())
		if create != null:
			_fields.append('"create":' + JSON.stringify(create))
		if not username.is_empty():
			_fields.append('"username":' + JSON.stringify(username))
		return "{%s}" % ",".join(_fields)


## Authenticate against the server with email+password.
class AuthenticateEmailRequest:
	extends RefCounted
	var account: AccountEmail
	## bool, or null when unset.
	var create: Variant
	var username: String


	static func from_json(_json: Variant) -> AuthenticateEmailRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AuthenticateEmailRequest.new()
		_message.account = AccountEmail.from_json(_data["account"]) if _data.get("account") != null else null
		_message.create = _data["create"] if _data.get("create") != null else null
		_message.username = _data.get("username", "")
		return _message


	func _init(p_account: AccountEmail = null, p_create: Variant = null,
			p_username: String = "") -> void:
		account = p_account
		create = p_create
		username = p_username


	func to_json() -> String:
		var _fields := PackedStringArray()
		if account != null:
			_fields.append('"account":' + account.to_json())
		if create != null:
			_fields.append('"create":' + JSON.stringify(create))
		if not username.is_empty():
			_fields.append('"username":' + JSON.stringify(username))
		return "{%s}" % ",".join(_fields)


## Authenticate against the server with Facebook.
class AuthenticateFacebookRequest:
	extends RefCounted
	var account: AccountFacebook
	## bool, or null when unset.
	var create: Variant
	var username: String
	## bool, or null when unset.
	var sync: Variant


	static func from_json(_json: Variant) -> AuthenticateFacebookRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AuthenticateFacebookRequest.new()
		_message.account = AccountFacebook.from_json(_data["account"]) if _data.get("account") != null else null
		_message.create = _data["create"] if _data.get("create") != null else null
		_message.username = _data.get("username", "")
		_message.sync = _data["sync"] if _data.get("sync") != null else null
		return _message


	func _init(p_account: AccountFacebook = null, p_create: Variant = null, p_username: String = "",
			p_sync: Variant = null) -> void:
		account = p_account
		create = p_create
		username = p_username
		sync = p_sync


	func to_json() -> String:
		var _fields := PackedStringArray()
		if account != null:
			_fields.append('"account":' + account.to_json())
		if create != null:
			_fields.append('"create":' + JSON.stringify(create))
		if not username.is_empty():
			_fields.append('"username":' + JSON.stringify(username))
		if sync != null:
			_fields.append('"sync":' + JSON.stringify(sync))
		return "{%s}" % ",".join(_fields)


## Authenticate against the server with a Facebook Instant Game token.
class AuthenticateFacebookInstantGameRequest:
	extends RefCounted
	var account: AccountFacebookInstantGame
	## bool, or null when unset.
	var create: Variant
	var username: String


	static func from_json(_json: Variant) -> AuthenticateFacebookInstantGameRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AuthenticateFacebookInstantGameRequest.new()
		_message.account = AccountFacebookInstantGame.from_json(_data["account"]) if _data.get("account") != null else null
		_message.create = _data["create"] if _data.get("create") != null else null
		_message.username = _data.get("username", "")
		return _message


	func _init(p_account: AccountFacebookInstantGame = null, p_create: Variant = null,
			p_username: String = "") -> void:
		account = p_account
		create = p_create
		username = p_username


	func to_json() -> String:
		var _fields := PackedStringArray()
		if account != null:
			_fields.append('"account":' + account.to_json())
		if create != null:
			_fields.append('"create":' + JSON.stringify(create))
		if not username.is_empty():
			_fields.append('"username":' + JSON.stringify(username))
		return "{%s}" % ",".join(_fields)


## Authenticate against the server with Apple's Game Center.
class AuthenticateGameCenterRequest:
	extends RefCounted
	var account: AccountGameCenter
	## bool, or null when unset.
	var create: Variant
	var username: String


	static func from_json(_json: Variant) -> AuthenticateGameCenterRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AuthenticateGameCenterRequest.new()
		_message.account = AccountGameCenter.from_json(_data["account"]) if _data.get("account") != null else null
		_message.create = _data["create"] if _data.get("create") != null else null
		_message.username = _data.get("username", "")
		return _message


	func _init(p_account: AccountGameCenter = null, p_create: Variant = null,
			p_username: String = "") -> void:
		account = p_account
		create = p_create
		username = p_username


	func to_json() -> String:
		var _fields := PackedStringArray()
		if account != null:
			_fields.append('"account":' + account.to_json())
		if create != null:
			_fields.append('"create":' + JSON.stringify(create))
		if not username.is_empty():
			_fields.append('"username":' + JSON.stringify(username))
		return "{%s}" % ",".join(_fields)


## Authenticate against the server with Google.
class AuthenticateGoogleRequest:
	extends RefCounted
	var account: AccountGoogle
	## bool, or null when unset.
	var create: Variant
	var username: String


	static func from_json(_json: Variant) -> AuthenticateGoogleRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AuthenticateGoogleRequest.new()
		_message.account = AccountGoogle.from_json(_data["account"]) if _data.get("account") != null else null
		_message.create = _data["create"] if _data.get("create") != null else null
		_message.username = _data.get("username", "")
		return _message


	func _init(p_account: AccountGoogle = null, p_create: Variant = null,
			p_username: String = "") -> void:
		account = p_account
		create = p_create
		username = p_username


	func to_json() -> String:
		var _fields := PackedStringArray()
		if account != null:
			_fields.append('"account":' + account.to_json())
		if create != null:
			_fields.append('"create":' + JSON.stringify(create))
		if not username.is_empty():
			_fields.append('"username":' + JSON.stringify(username))
		return "{%s}" % ",".join(_fields)


## Authenticate against the server with a runtime-registered provider.
class AuthenticateRequest:
	extends RefCounted
	var account: AccountProvider
	## bool, or null when unset.
	var create: Variant
	var username: String


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
		_message.account = AccountProvider.from_json(_data["account"]) if _data.get("account") != null else null
		_message.create = _data["create"] if _data.get("create") != null else null
		_message.username = _data.get("username", "")
		return _message


	func _init(p_account: AccountProvider = null, p_create: Variant = null,
			p_username: String = "") -> void:
		account = p_account
		create = p_create
		username = p_username


	func to_json() -> String:
		var _fields := PackedStringArray()
		if account != null:
			_fields.append('"account":' + account.to_json())
		if create != null:
			_fields.append('"create":' + JSON.stringify(create))
		if not username.is_empty():
			_fields.append('"username":' + JSON.stringify(username))
		return "{%s}" % ",".join(_fields)


## Authenticate against the server with Steam.
class AuthenticateSteamRequest:
	extends RefCounted
	var account: AccountSteam
	## bool, or null when unset.
	var create: Variant
	var username: String
	## bool, or null when unset.
	var sync: Variant


	static func from_json(_json: Variant) -> AuthenticateSteamRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := AuthenticateSteamRequest.new()
		_message.account = AccountSteam.from_json(_data["account"]) if _data.get("account") != null else null
		_message.create = _data["create"] if _data.get("create") != null else null
		_message.username = _data.get("username", "")
		_message.sync = _data["sync"] if _data.get("sync") != null else null
		return _message


	func _init(p_account: AccountSteam = null, p_create: Variant = null, p_username: String = "",
			p_sync: Variant = null) -> void:
		account = p_account
		create = p_create
		username = p_username
		sync = p_sync


	func to_json() -> String:
		var _fields := PackedStringArray()
		if account != null:
			_fields.append('"account":' + account.to_json())
		if create != null:
			_fields.append('"create":' + JSON.stringify(create))
		if not username.is_empty():
			_fields.append('"username":' + JSON.stringify(username))
		if sync != null:
			_fields.append('"sync":' + JSON.stringify(sync))
		return "{%s}" % ",".join(_fields)


## Ban users from a group.
class BanGroupUsersRequest:
	extends RefCounted
	var group_id: String
	var user_ids: Array = []


	static func from_json(_json: Variant) -> BanGroupUsersRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := BanGroupUsersRequest.new()
		_message.group_id = _data.get("group_id", "")
		_message.user_ids = _data.get("user_ids", [])
		return _message


	func _init(p_group_id: String = "", p_user_ids: Array = []) -> void:
		group_id = p_group_id
		user_ids = p_user_ids


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not group_id.is_empty():
			_fields.append('"group_id":' + JSON.stringify(group_id))
		_fields.append('"user_ids":[%s]' % ",".join(PackedStringArray(user_ids.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## Block one or more friends for the current user.
class BlockFriendsRequest:
	extends RefCounted
	var ids: Array = []
	var usernames: Array = []


	static func from_json(_json: Variant) -> BlockFriendsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := BlockFriendsRequest.new()
		_message.ids = _data.get("ids", [])
		_message.usernames = _data.get("usernames", [])
		return _message


	func _init(p_ids: Array = [], p_usernames: Array = []) -> void:
		ids = p_ids
		usernames = p_usernames


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"ids":[%s]' % ",".join(PackedStringArray(ids.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		_fields.append('"usernames":[%s]' % ",".join(PackedStringArray(usernames.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## A message sent on a channel.
class ChannelMessage:
	extends RefCounted
	var channel_id: String
	var message_id: String
	## int, or null when unset.
	var code: Variant
	var sender_id: String
	var username: String
	var content: String
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


	static func from_json(_json: Variant) -> ChannelMessage:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ChannelMessage.new()
		_message.channel_id = _data.get("channel_id", "")
		_message.message_id = _data.get("message_id", "")
		_message.code = type_convert(_data["code"], TYPE_INT) if _data.get("code") != null else null
		_message.sender_id = _data.get("sender_id", "")
		_message.username = _data.get("username", "")
		_message.content = _data.get("content", "")
		_message.create_time = _data.get("create_time")
		_message.update_time = _data.get("update_time")
		_message.persistent = _data["persistent"] if _data.get("persistent") != null else null
		_message.room_name = _data.get("room_name", "")
		_message.group_id = _data.get("group_id", "")
		_message.user_id_one = _data.get("user_id_one", "")
		_message.user_id_two = _data.get("user_id_two", "")
		return _message


	func _init(p_channel_id: String = "", p_message_id: String = "", p_code: Variant = null,
			p_sender_id: String = "", p_username: String = "", p_content: String = "",
			p_create_time: Variant = null, p_update_time: Variant = null,
			p_persistent: Variant = null, p_room_name: String = "", p_group_id: String = "",
			p_user_id_one: String = "", p_user_id_two: String = "") -> void:
		channel_id = p_channel_id
		message_id = p_message_id
		code = p_code
		sender_id = p_sender_id
		username = p_username
		content = p_content
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
		if not sender_id.is_empty():
			_fields.append('"sender_id":' + JSON.stringify(sender_id))
		if not username.is_empty():
			_fields.append('"username":' + JSON.stringify(username))
		if not content.is_empty():
			_fields.append('"content":' + JSON.stringify(content))
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


## A list of channel messages, usually a result of a list operation.
class ChannelMessageList:
	extends RefCounted
	var next_cursor: String
	var prev_cursor: String
	var cacheable_cursor: String
	var messages: Array = []


	static func from_json(_json: Variant) -> ChannelMessageList:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ChannelMessageList.new()
		_message.next_cursor = _data.get("next_cursor", "")
		_message.prev_cursor = _data.get("prev_cursor", "")
		_message.cacheable_cursor = _data.get("cacheable_cursor", "")
		var _list_messages: Array = _data.get("messages", [])
		_message.messages = _list_messages.map(func(_v: Variant) -> ChannelMessage: return ChannelMessage.from_json(_v))
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
		_fields.append('"messages":[%s]' % ",".join(PackedStringArray(messages.map(func(_v: ChannelMessage) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Create a group with the current user as owner.
class CreateGroupRequest:
	extends RefCounted
	var name: String
	var description: String
	var lang_tag: String
	var avatar_url: String
	var open: bool
	var max_count: int


	static func from_json(_json: Variant) -> CreateGroupRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := CreateGroupRequest.new()
		_message.name = _data.get("name", "")
		_message.description = _data.get("description", "")
		_message.lang_tag = _data.get("lang_tag", "")
		_message.avatar_url = _data.get("avatar_url", "")
		_message.open = _data.get("open", false)
		_message.max_count = type_convert(_data.get("max_count", 0), TYPE_INT)
		return _message


	func _init(p_name: String = "", p_description: String = "", p_lang_tag: String = "",
			p_avatar_url: String = "", p_open: bool = false, p_max_count: int = 0) -> void:
		name = p_name
		description = p_description
		lang_tag = p_lang_tag
		avatar_url = p_avatar_url
		open = p_open
		max_count = p_max_count


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not name.is_empty():
			_fields.append('"name":' + JSON.stringify(name))
		if not description.is_empty():
			_fields.append('"description":' + JSON.stringify(description))
		if not lang_tag.is_empty():
			_fields.append('"lang_tag":' + JSON.stringify(lang_tag))
		if not avatar_url.is_empty():
			_fields.append('"avatar_url":' + JSON.stringify(avatar_url))
		if open:
			_fields.append('"open":' + JSON.stringify(open))
		if max_count != 0:
			_fields.append('"max_count":' + JSON.stringify(max_count))
		return "{%s}" % ",".join(_fields)


## Delete one or more friends for the current user.
class DeleteFriendsRequest:
	extends RefCounted
	var ids: Array = []
	var usernames: Array = []


	static func from_json(_json: Variant) -> DeleteFriendsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := DeleteFriendsRequest.new()
		_message.ids = _data.get("ids", [])
		_message.usernames = _data.get("usernames", [])
		return _message


	func _init(p_ids: Array = [], p_usernames: Array = []) -> void:
		ids = p_ids
		usernames = p_usernames


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"ids":[%s]' % ",".join(PackedStringArray(ids.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		_fields.append('"usernames":[%s]' % ",".join(PackedStringArray(usernames.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## Delete a group the user has access to.
class DeleteGroupRequest:
	extends RefCounted
	var group_id: String


	static func from_json(_json: Variant) -> DeleteGroupRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := DeleteGroupRequest.new()
		_message.group_id = _data.get("group_id", "")
		return _message


	func _init(p_group_id: String = "") -> void:
		group_id = p_group_id


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not group_id.is_empty():
			_fields.append('"group_id":' + JSON.stringify(group_id))
		return "{%s}" % ",".join(_fields)


## Delete a leaderboard record.
class DeleteLeaderboardRecordRequest:
	extends RefCounted
	var leaderboard_id: String


	static func from_json(_json: Variant) -> DeleteLeaderboardRecordRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := DeleteLeaderboardRecordRequest.new()
		_message.leaderboard_id = _data.get("leaderboard_id", "")
		return _message


	func _init(p_leaderboard_id: String = "") -> void:
		leaderboard_id = p_leaderboard_id


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not leaderboard_id.is_empty():
			_fields.append('"leaderboard_id":' + JSON.stringify(leaderboard_id))
		return "{%s}" % ",".join(_fields)


## Delete one or more notifications for the current user.
class DeleteNotificationsRequest:
	extends RefCounted
	var ids: Array = []


	static func from_json(_json: Variant) -> DeleteNotificationsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := DeleteNotificationsRequest.new()
		_message.ids = _data.get("ids", [])
		return _message


	func _init(p_ids: Array = []) -> void:
		ids = p_ids


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"ids":[%s]' % ",".join(PackedStringArray(ids.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## Delete a leaderboard record.
class DeleteTournamentRecordRequest:
	extends RefCounted
	var tournament_id: String


	static func from_json(_json: Variant) -> DeleteTournamentRecordRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := DeleteTournamentRecordRequest.new()
		_message.tournament_id = _data.get("tournament_id", "")
		return _message


	func _init(p_tournament_id: String = "") -> void:
		tournament_id = p_tournament_id


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not tournament_id.is_empty():
			_fields.append('"tournament_id":' + JSON.stringify(tournament_id))
		return "{%s}" % ",".join(_fields)


## Storage objects to delete.
class DeleteStorageObjectId:
	extends RefCounted
	var collection: String
	var key: String
	var version: String


	static func from_json(_json: Variant) -> DeleteStorageObjectId:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := DeleteStorageObjectId.new()
		_message.collection = _data.get("collection", "")
		_message.key = _data.get("key", "")
		_message.version = _data.get("version", "")
		return _message


	func _init(p_collection: String = "", p_key: String = "", p_version: String = "") -> void:
		collection = p_collection
		key = p_key
		version = p_version


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not collection.is_empty():
			_fields.append('"collection":' + JSON.stringify(collection))
		if not key.is_empty():
			_fields.append('"key":' + JSON.stringify(key))
		if not version.is_empty():
			_fields.append('"version":' + JSON.stringify(version))
		return "{%s}" % ",".join(_fields)


## Batch delete storage objects.
class DeleteStorageObjectsRequest:
	extends RefCounted
	var object_ids: Array = []


	static func from_json(_json: Variant) -> DeleteStorageObjectsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := DeleteStorageObjectsRequest.new()
		var _list_object_ids: Array = _data.get("object_ids", [])
		_message.object_ids = _list_object_ids.map(func(_v: Variant) -> DeleteStorageObjectId: return DeleteStorageObjectId.from_json(_v))
		return _message


	func _init(p_object_ids: Array = []) -> void:
		object_ids = p_object_ids


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"object_ids":[%s]' % ",".join(PackedStringArray(object_ids.map(func(_v: DeleteStorageObjectId) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Represents an event to be passed through the server to registered event handlers.
class Event:
	extends RefCounted
	var name: String
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var timestamp: Variant
	var external: bool
	var properties: Dictionary = {}


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
		_message.timestamp = _data.get("timestamp")
		_message.external = _data.get("external", false)
		var _map_properties: Dictionary = _data.get("properties", {})
		for _k: Variant in _map_properties:
			_message.properties[_k] = _map_properties[_k]
		return _message


	func _init(p_name: String = "", p_properties: Dictionary = {}, p_timestamp: Variant = null,
			p_external: bool = false) -> void:
		name = p_name
		properties = p_properties
		timestamp = p_timestamp if p_timestamp else Nakama.timestamp()
		external = p_external


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not name.is_empty():
			_fields.append('"name":' + JSON.stringify(name))
		if timestamp != null:
			_fields.append('"timestamp":' + JSON.stringify(timestamp))
		if external:
			_fields.append('"external":' + JSON.stringify(external))
		var _map_properties := PackedStringArray()
		for _k: Variant in properties:
			var _v: String = str(properties[_k])
			_map_properties.append(JSON.stringify(str(_k)) + ":" + JSON.stringify(_v))
		_fields.append('"properties":{%s}' % ",".join(_map_properties))
		return "{%s}" % ",".join(_fields)


## A friend of a user.
class Friend:
	extends RefCounted
	var user: User
	## int, or null when unset.
	var state: Variant
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var update_time: Variant
	var metadata: String


	static func from_json(_json: Variant) -> Friend:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Friend.new()
		_message.user = User.from_json(_data["user"]) if _data.get("user") != null else null
		_message.state = type_convert(_data["state"], TYPE_INT) if _data.get("state") != null else null
		_message.update_time = _data.get("update_time")
		_message.metadata = _data.get("metadata", "")
		return _message


	func _init(p_user: User = null, p_state: Variant = null, p_update_time: Variant = null,
			p_metadata: String = "") -> void:
		user = p_user
		state = p_state
		update_time = p_update_time
		metadata = p_metadata


	func to_json() -> String:
		var _fields := PackedStringArray()
		if user != null:
			_fields.append('"user":' + user.to_json())
		if state != null:
			_fields.append('"state":' + JSON.stringify(state))
		if update_time != null:
			_fields.append('"update_time":' + JSON.stringify(update_time))
		if not metadata.is_empty():
			_fields.append('"metadata":' + JSON.stringify(metadata))
		return "{%s}" % ",".join(_fields)


## A collection of zero or more friends of the user.
class FriendList:
	extends RefCounted
	var cursor: String
	var friends: Array = []


	static func from_json(_json: Variant) -> FriendList:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := FriendList.new()
		_message.cursor = _data.get("cursor", "")
		var _list_friends: Array = _data.get("friends", [])
		_message.friends = _list_friends.map(func(_v: Variant) -> Friend: return Friend.from_json(_v))
		return _message


	func _init(p_friends: Array = [], p_cursor: String = "") -> void:
		friends = p_friends
		cursor = p_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		_fields.append('"friends":[%s]' % ",".join(PackedStringArray(friends.map(func(_v: Friend) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## A friend of a friend.
class FriendsOfFriendsListFriendOfFriend:
	extends RefCounted
	var referrer: String
	var user: User


	static func from_json(_json: Variant) -> FriendsOfFriendsListFriendOfFriend:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := FriendsOfFriendsListFriendOfFriend.new()
		_message.referrer = _data.get("referrer", "")
		_message.user = User.from_json(_data["user"]) if _data.get("user") != null else null
		return _message


	func _init(p_referrer: String = "", p_user: User = null) -> void:
		referrer = p_referrer
		user = p_user


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not referrer.is_empty():
			_fields.append('"referrer":' + JSON.stringify(referrer))
		if user != null:
			_fields.append('"user":' + user.to_json())
		return "{%s}" % ",".join(_fields)


## A list of friends of friends.
class FriendsOfFriendsList:
	extends RefCounted
	var cursor: String
	var friends_of_friends: Array = []


	static func from_json(_json: Variant) -> FriendsOfFriendsList:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := FriendsOfFriendsList.new()
		_message.cursor = _data.get("cursor", "")
		var _list_friends_of_friends: Array = _data.get("friends_of_friends", [])
		_message.friends_of_friends = _list_friends_of_friends.map(func(_v: Variant) -> FriendsOfFriendsListFriendOfFriend: return FriendsOfFriendsListFriendOfFriend.from_json(_v))
		return _message


	func _init(p_friends_of_friends: Array = [], p_cursor: String = "") -> void:
		friends_of_friends = p_friends_of_friends
		cursor = p_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		_fields.append('"friends_of_friends":[%s]' % ",".join(PackedStringArray(friends_of_friends.map(func(_v: FriendsOfFriendsListFriendOfFriend) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Fetch a batch of zero or more users from the server.
class GetUsersRequest:
	extends RefCounted
	var ids: Array = []
	var usernames: Array = []
	var facebook_ids: Array = []


	static func from_json(_json: Variant) -> GetUsersRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := GetUsersRequest.new()
		_message.ids = _data.get("ids", [])
		_message.usernames = _data.get("usernames", [])
		_message.facebook_ids = _data.get("facebook_ids", [])
		return _message


	func _init(p_ids: Array = [], p_usernames: Array = [], p_facebook_ids: Array = []) -> void:
		ids = p_ids
		usernames = p_usernames
		facebook_ids = p_facebook_ids


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"ids":[%s]' % ",".join(PackedStringArray(ids.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		_fields.append('"usernames":[%s]' % ",".join(PackedStringArray(usernames.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		_fields.append('"facebook_ids":[%s]' % ",".join(PackedStringArray(facebook_ids.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## Fetch a subscription by product ID.
class GetSubscriptionRequest:
	extends RefCounted
	var product_id: String


	static func from_json(_json: Variant) -> GetSubscriptionRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := GetSubscriptionRequest.new()
		_message.product_id = _data.get("product_id", "")
		return _message


	func _init(p_product_id: String = "") -> void:
		product_id = p_product_id


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not product_id.is_empty():
			_fields.append('"product_id":' + JSON.stringify(product_id))
		return "{%s}" % ",".join(_fields)


## A group on the server.
class Group:
	extends RefCounted
	var id: String
	var creator_id: String
	var name: String
	var description: String
	var lang_tag: String
	var metadata: String
	var avatar_url: String
	## bool, or null when unset.
	var open: Variant
	var edge_count: int
	var max_count: int
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var create_time: Variant
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var update_time: Variant


	static func from_json(_json: Variant) -> Group:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Group.new()
		_message.id = _data.get("id", "")
		_message.creator_id = _data.get("creator_id", "")
		_message.name = _data.get("name", "")
		_message.description = _data.get("description", "")
		_message.lang_tag = _data.get("lang_tag", "")
		_message.metadata = _data.get("metadata", "")
		_message.avatar_url = _data.get("avatar_url", "")
		_message.open = _data["open"] if _data.get("open") != null else null
		_message.edge_count = type_convert(_data.get("edge_count", 0), TYPE_INT)
		_message.max_count = type_convert(_data.get("max_count", 0), TYPE_INT)
		_message.create_time = _data.get("create_time")
		_message.update_time = _data.get("update_time")
		return _message


	func _init(p_id: String = "", p_creator_id: String = "", p_name: String = "",
			p_description: String = "", p_lang_tag: String = "", p_metadata: String = "",
			p_avatar_url: String = "", p_open: Variant = null, p_edge_count: int = 0,
			p_max_count: int = 0, p_create_time: Variant = null,
			p_update_time: Variant = null) -> void:
		id = p_id
		creator_id = p_creator_id
		name = p_name
		description = p_description
		lang_tag = p_lang_tag
		metadata = p_metadata
		avatar_url = p_avatar_url
		open = p_open
		edge_count = p_edge_count
		max_count = p_max_count
		create_time = p_create_time
		update_time = p_update_time


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not id.is_empty():
			_fields.append('"id":' + JSON.stringify(id))
		if not creator_id.is_empty():
			_fields.append('"creator_id":' + JSON.stringify(creator_id))
		if not name.is_empty():
			_fields.append('"name":' + JSON.stringify(name))
		if not description.is_empty():
			_fields.append('"description":' + JSON.stringify(description))
		if not lang_tag.is_empty():
			_fields.append('"lang_tag":' + JSON.stringify(lang_tag))
		if not metadata.is_empty():
			_fields.append('"metadata":' + JSON.stringify(metadata))
		if not avatar_url.is_empty():
			_fields.append('"avatar_url":' + JSON.stringify(avatar_url))
		if open != null:
			_fields.append('"open":' + JSON.stringify(open))
		if edge_count != 0:
			_fields.append('"edge_count":' + JSON.stringify(edge_count))
		if max_count != 0:
			_fields.append('"max_count":' + JSON.stringify(max_count))
		if create_time != null:
			_fields.append('"create_time":' + JSON.stringify(create_time))
		if update_time != null:
			_fields.append('"update_time":' + JSON.stringify(update_time))
		return "{%s}" % ",".join(_fields)


## One or more groups returned from a listing operation.
class GroupList:
	extends RefCounted
	var cursor: String
	var groups: Array = []


	static func from_json(_json: Variant) -> GroupList:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := GroupList.new()
		_message.cursor = _data.get("cursor", "")
		var _list_groups: Array = _data.get("groups", [])
		_message.groups = _list_groups.map(func(_v: Variant) -> Group: return Group.from_json(_v))
		return _message


	func _init(p_groups: Array = [], p_cursor: String = "") -> void:
		groups = p_groups
		cursor = p_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		_fields.append('"groups":[%s]' % ",".join(PackedStringArray(groups.map(func(_v: Group) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## A single user-role pair.
class GroupUserListGroupUser:
	extends RefCounted
	var user: User
	## int, or null when unset.
	var state: Variant


	static func from_json(_json: Variant) -> GroupUserListGroupUser:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := GroupUserListGroupUser.new()
		_message.user = User.from_json(_data["user"]) if _data.get("user") != null else null
		_message.state = type_convert(_data["state"], TYPE_INT) if _data.get("state") != null else null
		return _message


	func _init(p_user: User = null, p_state: Variant = null) -> void:
		user = p_user
		state = p_state


	func to_json() -> String:
		var _fields := PackedStringArray()
		if user != null:
			_fields.append('"user":' + user.to_json())
		if state != null:
			_fields.append('"state":' + JSON.stringify(state))
		return "{%s}" % ",".join(_fields)


## A list of users belonging to a group, along with their role.
class GroupUserList:
	extends RefCounted
	var cursor: String
	var group_users: Array = []


	static func from_json(_json: Variant) -> GroupUserList:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := GroupUserList.new()
		_message.cursor = _data.get("cursor", "")
		var _list_group_users: Array = _data.get("group_users", [])
		_message.group_users = _list_group_users.map(func(_v: Variant) -> GroupUserListGroupUser: return GroupUserListGroupUser.from_json(_v))
		return _message


	func _init(p_group_users: Array = [], p_cursor: String = "") -> void:
		group_users = p_group_users
		cursor = p_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		_fields.append('"group_users":[%s]' % ",".join(PackedStringArray(group_users.map(func(_v: GroupUserListGroupUser) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Import Facebook friends into the current user's account.
class ImportFacebookFriendsRequest:
	extends RefCounted
	var account: AccountFacebook
	## bool, or null when unset.
	var reset: Variant


	static func from_json(_json: Variant) -> ImportFacebookFriendsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ImportFacebookFriendsRequest.new()
		_message.account = AccountFacebook.from_json(_data["account"]) if _data.get("account") != null else null
		_message.reset = _data["reset"] if _data.get("reset") != null else null
		return _message


	func _init(p_account: AccountFacebook = null, p_reset: Variant = null) -> void:
		account = p_account
		reset = p_reset


	func to_json() -> String:
		var _fields := PackedStringArray()
		if account != null:
			_fields.append('"account":' + account.to_json())
		if reset != null:
			_fields.append('"reset":' + JSON.stringify(reset))
		return "{%s}" % ",".join(_fields)


## Import Facebook friends into the current user's account.
class ImportSteamFriendsRequest:
	extends RefCounted
	var account: AccountSteam
	## bool, or null when unset.
	var reset: Variant


	static func from_json(_json: Variant) -> ImportSteamFriendsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ImportSteamFriendsRequest.new()
		_message.account = AccountSteam.from_json(_data["account"]) if _data.get("account") != null else null
		_message.reset = _data["reset"] if _data.get("reset") != null else null
		return _message


	func _init(p_account: AccountSteam = null, p_reset: Variant = null) -> void:
		account = p_account
		reset = p_reset


	func to_json() -> String:
		var _fields := PackedStringArray()
		if account != null:
			_fields.append('"account":' + account.to_json())
		if reset != null:
			_fields.append('"reset":' + JSON.stringify(reset))
		return "{%s}" % ",".join(_fields)


## Immediately join an open group, or request to join a closed one.
class JoinGroupRequest:
	extends RefCounted
	var group_id: String


	static func from_json(_json: Variant) -> JoinGroupRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := JoinGroupRequest.new()
		_message.group_id = _data.get("group_id", "")
		return _message


	func _init(p_group_id: String = "") -> void:
		group_id = p_group_id


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not group_id.is_empty():
			_fields.append('"group_id":' + JSON.stringify(group_id))
		return "{%s}" % ",".join(_fields)


## The request to join a tournament.
class JoinTournamentRequest:
	extends RefCounted
	var tournament_id: String


	static func from_json(_json: Variant) -> JoinTournamentRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := JoinTournamentRequest.new()
		_message.tournament_id = _data.get("tournament_id", "")
		return _message


	func _init(p_tournament_id: String = "") -> void:
		tournament_id = p_tournament_id


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not tournament_id.is_empty():
			_fields.append('"tournament_id":' + JSON.stringify(tournament_id))
		return "{%s}" % ",".join(_fields)


## Kick a set of users from a group.
class KickGroupUsersRequest:
	extends RefCounted
	var group_id: String
	var user_ids: Array = []


	static func from_json(_json: Variant) -> KickGroupUsersRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := KickGroupUsersRequest.new()
		_message.group_id = _data.get("group_id", "")
		_message.user_ids = _data.get("user_ids", [])
		return _message


	func _init(p_group_id: String = "", p_user_ids: Array = []) -> void:
		group_id = p_group_id
		user_ids = p_user_ids


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not group_id.is_empty():
			_fields.append('"group_id":' + JSON.stringify(group_id))
		_fields.append('"user_ids":[%s]' % ",".join(PackedStringArray(user_ids.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## A leaderboard on the server.
class Leaderboard:
	extends RefCounted
	var id: String
	var sort_order: int
	var operator: Operator
	var prev_reset: int
	var next_reset: int
	var metadata: String
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var create_time: Variant
	var authoritative: bool


	static func from_json(_json: Variant) -> Leaderboard:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Leaderboard.new()
		_message.id = _data.get("id", "")
		_message.sort_order = type_convert(_data.get("sort_order", 0), TYPE_INT)
		_message.operator = type_convert(_data.get("operator", 0), TYPE_INT)
		_message.prev_reset = type_convert(_data.get("prev_reset", 0), TYPE_INT)
		_message.next_reset = type_convert(_data.get("next_reset", 0), TYPE_INT)
		_message.metadata = _data.get("metadata", "")
		_message.create_time = _data.get("create_time")
		_message.authoritative = _data.get("authoritative", false)
		return _message


	func _init(p_id: String = "", p_sort_order: int = 0,
			p_operator: Operator = Operator.NO_OVERRIDE, p_prev_reset: int = 0,
			p_next_reset: int = 0, p_metadata: String = "", p_create_time: Variant = null,
			p_authoritative: bool = false) -> void:
		id = p_id
		sort_order = p_sort_order
		operator = p_operator
		prev_reset = p_prev_reset
		next_reset = p_next_reset
		metadata = p_metadata
		create_time = p_create_time
		authoritative = p_authoritative


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not id.is_empty():
			_fields.append('"id":' + JSON.stringify(id))
		if sort_order != 0:
			_fields.append('"sort_order":' + JSON.stringify(sort_order))
		if operator != 0:
			_fields.append('"operator":' + JSON.stringify(operator))
		if prev_reset != 0:
			_fields.append('"prev_reset":' + JSON.stringify(prev_reset))
		if next_reset != 0:
			_fields.append('"next_reset":' + JSON.stringify(next_reset))
		if not metadata.is_empty():
			_fields.append('"metadata":' + JSON.stringify(metadata))
		if create_time != null:
			_fields.append('"create_time":' + JSON.stringify(create_time))
		if authoritative:
			_fields.append('"authoritative":' + JSON.stringify(authoritative))
		return "{%s}" % ",".join(_fields)


## A list of leaderboards.
class LeaderboardList:
	extends RefCounted
	var cursor: String
	var leaderboards: Array = []


	static func from_json(_json: Variant) -> LeaderboardList:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := LeaderboardList.new()
		_message.cursor = _data.get("cursor", "")
		var _list_leaderboards: Array = _data.get("leaderboards", [])
		_message.leaderboards = _list_leaderboards.map(func(_v: Variant) -> Leaderboard: return Leaderboard.from_json(_v))
		return _message


	func _init(p_leaderboards: Array = [], p_cursor: String = "") -> void:
		leaderboards = p_leaderboards
		cursor = p_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		_fields.append('"leaderboards":[%s]' % ",".join(PackedStringArray(leaderboards.map(func(_v: Leaderboard) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Represents a complete leaderboard record with all scores and associated metadata.
class LeaderboardRecord:
	extends RefCounted
	var leaderboard_id: String
	var owner_id: String
	## String, or null when unset.
	var username: Variant
	var score: int
	var subscore: int
	var num_score: int
	var metadata: String
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var create_time: Variant
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var update_time: Variant
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var expiry_time: Variant
	var rank: int
	var max_num_score: int


	static func from_json(_json: Variant) -> LeaderboardRecord:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := LeaderboardRecord.new()
		_message.leaderboard_id = _data.get("leaderboard_id", "")
		_message.owner_id = _data.get("owner_id", "")
		_message.username = _data["username"] if _data.get("username") != null else null
		_message.score = type_convert(_data.get("score", 0), TYPE_INT)
		_message.subscore = type_convert(_data.get("subscore", 0), TYPE_INT)
		_message.num_score = type_convert(_data.get("num_score", 0), TYPE_INT)
		_message.metadata = _data.get("metadata", "")
		_message.create_time = _data.get("create_time")
		_message.update_time = _data.get("update_time")
		_message.expiry_time = _data.get("expiry_time")
		_message.rank = type_convert(_data.get("rank", 0), TYPE_INT)
		_message.max_num_score = type_convert(_data.get("max_num_score", 0), TYPE_INT)
		return _message


	func _init(p_leaderboard_id: String = "", p_owner_id: String = "", p_username: Variant = null,
			p_score: int = 0, p_subscore: int = 0, p_num_score: int = 0, p_metadata: String = "",
			p_create_time: Variant = null, p_update_time: Variant = null,
			p_expiry_time: Variant = null, p_rank: int = 0, p_max_num_score: int = 0) -> void:
		leaderboard_id = p_leaderboard_id
		owner_id = p_owner_id
		username = p_username
		score = p_score
		subscore = p_subscore
		num_score = p_num_score
		metadata = p_metadata
		create_time = p_create_time
		update_time = p_update_time
		expiry_time = p_expiry_time
		rank = p_rank
		max_num_score = p_max_num_score


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not leaderboard_id.is_empty():
			_fields.append('"leaderboard_id":' + JSON.stringify(leaderboard_id))
		if not owner_id.is_empty():
			_fields.append('"owner_id":' + JSON.stringify(owner_id))
		if username != null:
			_fields.append('"username":' + JSON.stringify(username))
		if score != 0:
			_fields.append('"score":' + JSON.stringify(score))
		if subscore != 0:
			_fields.append('"subscore":' + JSON.stringify(subscore))
		if num_score != 0:
			_fields.append('"num_score":' + JSON.stringify(num_score))
		if not metadata.is_empty():
			_fields.append('"metadata":' + JSON.stringify(metadata))
		if create_time != null:
			_fields.append('"create_time":' + JSON.stringify(create_time))
		if update_time != null:
			_fields.append('"update_time":' + JSON.stringify(update_time))
		if expiry_time != null:
			_fields.append('"expiry_time":' + JSON.stringify(expiry_time))
		if rank != 0:
			_fields.append('"rank":' + JSON.stringify(rank))
		if max_num_score != 0:
			_fields.append('"max_num_score":' + JSON.stringify(max_num_score))
		return "{%s}" % ",".join(_fields)


## A set of leaderboard records which may be part of a leaderboard records page or a batch of individual records.
class LeaderboardRecordList:
	extends RefCounted
	var next_cursor: String
	var prev_cursor: String
	var rank_count: int
	var records: Array = []
	var owner_records: Array = []


	static func from_json(_json: Variant) -> LeaderboardRecordList:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := LeaderboardRecordList.new()
		_message.next_cursor = _data.get("next_cursor", "")
		_message.prev_cursor = _data.get("prev_cursor", "")
		_message.rank_count = type_convert(_data.get("rank_count", 0), TYPE_INT)
		var _list_records: Array = _data.get("records", [])
		_message.records = _list_records.map(func(_v: Variant) -> LeaderboardRecord: return LeaderboardRecord.from_json(_v))
		var _list_owner_records: Array = _data.get("owner_records", [])
		_message.owner_records = _list_owner_records.map(func(_v: Variant) -> LeaderboardRecord: return LeaderboardRecord.from_json(_v))
		return _message


	func _init(p_records: Array = [], p_owner_records: Array = [], p_next_cursor: String = "",
			p_prev_cursor: String = "", p_rank_count: int = 0) -> void:
		records = p_records
		owner_records = p_owner_records
		next_cursor = p_next_cursor
		prev_cursor = p_prev_cursor
		rank_count = p_rank_count


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not next_cursor.is_empty():
			_fields.append('"next_cursor":' + JSON.stringify(next_cursor))
		if not prev_cursor.is_empty():
			_fields.append('"prev_cursor":' + JSON.stringify(prev_cursor))
		if rank_count != 0:
			_fields.append('"rank_count":' + JSON.stringify(rank_count))
		_fields.append('"records":[%s]' % ",".join(PackedStringArray(records.map(func(_v: LeaderboardRecord) -> String: return _v.to_json()))))
		_fields.append('"owner_records":[%s]' % ",".join(PackedStringArray(owner_records.map(func(_v: LeaderboardRecord) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Leave a group.
class LeaveGroupRequest:
	extends RefCounted
	var group_id: String


	static func from_json(_json: Variant) -> LeaveGroupRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := LeaveGroupRequest.new()
		_message.group_id = _data.get("group_id", "")
		return _message


	func _init(p_group_id: String = "") -> void:
		group_id = p_group_id


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not group_id.is_empty():
			_fields.append('"group_id":' + JSON.stringify(group_id))
		return "{%s}" % ",".join(_fields)


## Link Facebook to the current user's account.
class LinkFacebookRequest:
	extends RefCounted
	var account: AccountFacebook
	## bool, or null when unset.
	var sync: Variant


	static func from_json(_json: Variant) -> LinkFacebookRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := LinkFacebookRequest.new()
		_message.account = AccountFacebook.from_json(_data["account"]) if _data.get("account") != null else null
		_message.sync = _data["sync"] if _data.get("sync") != null else null
		return _message


	func _init(p_account: AccountFacebook = null, p_sync: Variant = null) -> void:
		account = p_account
		sync = p_sync


	func to_json() -> String:
		var _fields := PackedStringArray()
		if account != null:
			_fields.append('"account":' + account.to_json())
		if sync != null:
			_fields.append('"sync":' + JSON.stringify(sync))
		return "{%s}" % ",".join(_fields)


## Link Steam to the current user's account.
class LinkSteamRequest:
	extends RefCounted
	var account: AccountSteam
	## bool, or null when unset.
	var sync: Variant


	static func from_json(_json: Variant) -> LinkSteamRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := LinkSteamRequest.new()
		_message.account = AccountSteam.from_json(_data["account"]) if _data.get("account") != null else null
		_message.sync = _data["sync"] if _data.get("sync") != null else null
		return _message


	func _init(p_account: AccountSteam = null, p_sync: Variant = null) -> void:
		account = p_account
		sync = p_sync


	func to_json() -> String:
		var _fields := PackedStringArray()
		if account != null:
			_fields.append('"account":' + account.to_json())
		if sync != null:
			_fields.append('"sync":' + JSON.stringify(sync))
		return "{%s}" % ",".join(_fields)


## List a channel's message history.
class ListChannelMessagesRequest:
	extends RefCounted
	var channel_id: String
	## int, or null when unset.
	var limit: Variant
	## bool, or null when unset.
	var forward: Variant
	var cursor: String


	static func from_json(_json: Variant) -> ListChannelMessagesRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ListChannelMessagesRequest.new()
		_message.channel_id = _data.get("channel_id", "")
		_message.limit = type_convert(_data["limit"], TYPE_INT) if _data.get("limit") != null else null
		_message.forward = _data["forward"] if _data.get("forward") != null else null
		_message.cursor = _data.get("cursor", "")
		return _message


	func _init(p_channel_id: String = "", p_limit: Variant = null, p_forward: Variant = null,
			p_cursor: String = "") -> void:
		channel_id = p_channel_id
		limit = p_limit
		forward = p_forward
		cursor = p_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not channel_id.is_empty():
			_fields.append('"channel_id":' + JSON.stringify(channel_id))
		if limit != null:
			_fields.append('"limit":' + JSON.stringify(limit))
		if forward != null:
			_fields.append('"forward":' + JSON.stringify(forward))
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		return "{%s}" % ",".join(_fields)


## List friends for a user.
class ListFriendsRequest:
	extends RefCounted
	## int, or null when unset.
	var limit: Variant
	## int, or null when unset.
	var state: Variant
	var cursor: String


	static func from_json(_json: Variant) -> ListFriendsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ListFriendsRequest.new()
		_message.limit = type_convert(_data["limit"], TYPE_INT) if _data.get("limit") != null else null
		_message.state = type_convert(_data["state"], TYPE_INT) if _data.get("state") != null else null
		_message.cursor = _data.get("cursor", "")
		return _message


	func _init(p_limit: Variant = null, p_state: Variant = null, p_cursor: String = "") -> void:
		limit = p_limit
		state = p_state
		cursor = p_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if limit != null:
			_fields.append('"limit":' + JSON.stringify(limit))
		if state != null:
			_fields.append('"state":' + JSON.stringify(state))
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		return "{%s}" % ",".join(_fields)


class ListFriendsOfFriendsRequest:
	extends RefCounted
	## int, or null when unset.
	var limit: Variant
	var cursor: String


	static func from_json(_json: Variant) -> ListFriendsOfFriendsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ListFriendsOfFriendsRequest.new()
		_message.limit = type_convert(_data["limit"], TYPE_INT) if _data.get("limit") != null else null
		_message.cursor = _data.get("cursor", "")
		return _message


	func _init(p_limit: Variant = null, p_cursor: String = "") -> void:
		limit = p_limit
		cursor = p_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if limit != null:
			_fields.append('"limit":' + JSON.stringify(limit))
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		return "{%s}" % ",".join(_fields)


## List groups based on given filters.
class ListGroupsRequest:
	extends RefCounted
	var name: String
	var cursor: String
	## int, or null when unset.
	var limit: Variant
	var lang_tag: String
	## int, or null when unset.
	var members: Variant
	## bool, or null when unset.
	var open: Variant


	static func from_json(_json: Variant) -> ListGroupsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ListGroupsRequest.new()
		_message.name = _data.get("name", "")
		_message.cursor = _data.get("cursor", "")
		_message.limit = type_convert(_data["limit"], TYPE_INT) if _data.get("limit") != null else null
		_message.lang_tag = _data.get("lang_tag", "")
		_message.members = type_convert(_data["members"], TYPE_INT) if _data.get("members") != null else null
		_message.open = _data["open"] if _data.get("open") != null else null
		return _message


	func _init(p_name: String = "", p_cursor: String = "", p_limit: Variant = null,
			p_lang_tag: String = "", p_members: Variant = null, p_open: Variant = null) -> void:
		name = p_name
		cursor = p_cursor
		limit = p_limit
		lang_tag = p_lang_tag
		members = p_members
		open = p_open


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not name.is_empty():
			_fields.append('"name":' + JSON.stringify(name))
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		if limit != null:
			_fields.append('"limit":' + JSON.stringify(limit))
		if not lang_tag.is_empty():
			_fields.append('"lang_tag":' + JSON.stringify(lang_tag))
		if members != null:
			_fields.append('"members":' + JSON.stringify(members))
		if open != null:
			_fields.append('"open":' + JSON.stringify(open))
		return "{%s}" % ",".join(_fields)


## List all users that are part of a group.
class ListGroupUsersRequest:
	extends RefCounted
	var group_id: String
	## int, or null when unset.
	var limit: Variant
	## int, or null when unset.
	var state: Variant
	var cursor: String


	static func from_json(_json: Variant) -> ListGroupUsersRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ListGroupUsersRequest.new()
		_message.group_id = _data.get("group_id", "")
		_message.limit = type_convert(_data["limit"], TYPE_INT) if _data.get("limit") != null else null
		_message.state = type_convert(_data["state"], TYPE_INT) if _data.get("state") != null else null
		_message.cursor = _data.get("cursor", "")
		return _message


	func _init(p_group_id: String = "", p_limit: Variant = null, p_state: Variant = null,
			p_cursor: String = "") -> void:
		group_id = p_group_id
		limit = p_limit
		state = p_state
		cursor = p_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not group_id.is_empty():
			_fields.append('"group_id":' + JSON.stringify(group_id))
		if limit != null:
			_fields.append('"limit":' + JSON.stringify(limit))
		if state != null:
			_fields.append('"state":' + JSON.stringify(state))
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		return "{%s}" % ",".join(_fields)


## List leaderboard records from a given leaderboard around the owner.
class ListLeaderboardRecordsAroundOwnerRequest:
	extends RefCounted
	var leaderboard_id: String
	## int, or null when unset.
	var limit: Variant
	var owner_id: String
	## int, or null when unset.
	var expiry: Variant
	var cursor: String


	static func from_json(_json: Variant) -> ListLeaderboardRecordsAroundOwnerRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ListLeaderboardRecordsAroundOwnerRequest.new()
		_message.leaderboard_id = _data.get("leaderboard_id", "")
		_message.limit = type_convert(_data["limit"], TYPE_INT) if _data.get("limit") != null else null
		_message.owner_id = _data.get("owner_id", "")
		_message.expiry = type_convert(_data["expiry"], TYPE_INT) if _data.get("expiry") != null else null
		_message.cursor = _data.get("cursor", "")
		return _message


	func _init(p_leaderboard_id: String = "", p_limit: Variant = null, p_owner_id: String = "",
			p_expiry: Variant = null, p_cursor: String = "") -> void:
		leaderboard_id = p_leaderboard_id
		limit = p_limit
		owner_id = p_owner_id
		expiry = p_expiry
		cursor = p_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not leaderboard_id.is_empty():
			_fields.append('"leaderboard_id":' + JSON.stringify(leaderboard_id))
		if limit != null:
			_fields.append('"limit":' + JSON.stringify(limit))
		if not owner_id.is_empty():
			_fields.append('"owner_id":' + JSON.stringify(owner_id))
		if expiry != null:
			_fields.append('"expiry":' + JSON.stringify(expiry))
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		return "{%s}" % ",".join(_fields)


## List leaderboard records from a given leaderboard.
class ListLeaderboardRecordsRequest:
	extends RefCounted
	var leaderboard_id: String
	## int, or null when unset.
	var limit: Variant
	var cursor: String
	## int, or null when unset.
	var expiry: Variant
	var owner_ids: Array = []


	static func from_json(_json: Variant) -> ListLeaderboardRecordsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ListLeaderboardRecordsRequest.new()
		_message.leaderboard_id = _data.get("leaderboard_id", "")
		_message.limit = type_convert(_data["limit"], TYPE_INT) if _data.get("limit") != null else null
		_message.cursor = _data.get("cursor", "")
		_message.expiry = type_convert(_data["expiry"], TYPE_INT) if _data.get("expiry") != null else null
		_message.owner_ids = _data.get("owner_ids", [])
		return _message


	func _init(p_leaderboard_id: String = "", p_owner_ids: Array = [], p_limit: Variant = null,
			p_cursor: String = "", p_expiry: Variant = null) -> void:
		leaderboard_id = p_leaderboard_id
		owner_ids = p_owner_ids
		limit = p_limit
		cursor = p_cursor
		expiry = p_expiry


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not leaderboard_id.is_empty():
			_fields.append('"leaderboard_id":' + JSON.stringify(leaderboard_id))
		if limit != null:
			_fields.append('"limit":' + JSON.stringify(limit))
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		if expiry != null:
			_fields.append('"expiry":' + JSON.stringify(expiry))
		_fields.append('"owner_ids":[%s]' % ",".join(PackedStringArray(owner_ids.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## List realtime matches.
class ListMatchesRequest:
	extends RefCounted
	## int, or null when unset.
	var limit: Variant
	## bool, or null when unset.
	var authoritative: Variant
	## String, or null when unset.
	var label: Variant
	## int, or null when unset.
	var min_size: Variant
	## int, or null when unset.
	var max_size: Variant
	## String, or null when unset.
	var query: Variant


	static func from_json(_json: Variant) -> ListMatchesRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ListMatchesRequest.new()
		_message.limit = type_convert(_data["limit"], TYPE_INT) if _data.get("limit") != null else null
		_message.authoritative = _data["authoritative"] if _data.get("authoritative") != null else null
		_message.label = _data["label"] if _data.get("label") != null else null
		_message.min_size = type_convert(_data["min_size"], TYPE_INT) if _data.get("min_size") != null else null
		_message.max_size = type_convert(_data["max_size"], TYPE_INT) if _data.get("max_size") != null else null
		_message.query = _data["query"] if _data.get("query") != null else null
		return _message


	func _init(p_limit: Variant = null, p_authoritative: Variant = null, p_label: Variant = null,
			p_min_size: Variant = null, p_max_size: Variant = null,
			p_query: Variant = null) -> void:
		limit = p_limit
		authoritative = p_authoritative
		label = p_label
		min_size = p_min_size
		max_size = p_max_size
		query = p_query


	func to_json() -> String:
		var _fields := PackedStringArray()
		if limit != null:
			_fields.append('"limit":' + JSON.stringify(limit))
		if authoritative != null:
			_fields.append('"authoritative":' + JSON.stringify(authoritative))
		if label != null:
			_fields.append('"label":' + JSON.stringify(label))
		if min_size != null:
			_fields.append('"min_size":' + JSON.stringify(min_size))
		if max_size != null:
			_fields.append('"max_size":' + JSON.stringify(max_size))
		if query != null:
			_fields.append('"query":' + JSON.stringify(query))
		return "{%s}" % ",".join(_fields)


## Get a list of unexpired notifications.
class ListNotificationsRequest:
	extends RefCounted
	## int, or null when unset.
	var limit: Variant
	var cacheable_cursor: String


	static func from_json(_json: Variant) -> ListNotificationsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ListNotificationsRequest.new()
		_message.limit = type_convert(_data["limit"], TYPE_INT) if _data.get("limit") != null else null
		_message.cacheable_cursor = _data.get("cacheable_cursor", "")
		return _message


	func _init(p_limit: Variant = null, p_cacheable_cursor: String = "") -> void:
		limit = p_limit
		cacheable_cursor = p_cacheable_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if limit != null:
			_fields.append('"limit":' + JSON.stringify(limit))
		if not cacheable_cursor.is_empty():
			_fields.append('"cacheable_cursor":' + JSON.stringify(cacheable_cursor))
		return "{%s}" % ",".join(_fields)


## List publicly readable storage objects in a given collection.
class ListStorageObjectsRequest:
	extends RefCounted
	var user_id: String
	var collection: String
	## int, or null when unset.
	var limit: Variant
	var cursor: String


	static func from_json(_json: Variant) -> ListStorageObjectsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ListStorageObjectsRequest.new()
		_message.user_id = _data.get("user_id", "")
		_message.collection = _data.get("collection", "")
		_message.limit = type_convert(_data["limit"], TYPE_INT) if _data.get("limit") != null else null
		_message.cursor = _data.get("cursor", "")
		return _message


	func _init(p_user_id: String = "", p_collection: String = "", p_limit: Variant = null,
			p_cursor: String = "") -> void:
		user_id = p_user_id
		collection = p_collection
		limit = p_limit
		cursor = p_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not user_id.is_empty():
			_fields.append('"user_id":' + JSON.stringify(user_id))
		if not collection.is_empty():
			_fields.append('"collection":' + JSON.stringify(collection))
		if limit != null:
			_fields.append('"limit":' + JSON.stringify(limit))
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		return "{%s}" % ",".join(_fields)


## List user subscriptions.
class ListSubscriptionsRequest:
	extends RefCounted
	## int, or null when unset.
	var limit: Variant
	var cursor: String


	static func from_json(_json: Variant) -> ListSubscriptionsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ListSubscriptionsRequest.new()
		_message.limit = type_convert(_data["limit"], TYPE_INT) if _data.get("limit") != null else null
		_message.cursor = _data.get("cursor", "")
		return _message


	func _init(p_limit: Variant = null, p_cursor: String = "") -> void:
		limit = p_limit
		cursor = p_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if limit != null:
			_fields.append('"limit":' + JSON.stringify(limit))
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		return "{%s}" % ",".join(_fields)


## List tournament records from a given tournament around the owner.
class ListTournamentRecordsAroundOwnerRequest:
	extends RefCounted
	var tournament_id: String
	## int, or null when unset.
	var limit: Variant
	var owner_id: String
	## int, or null when unset.
	var expiry: Variant
	var cursor: String


	static func from_json(_json: Variant) -> ListTournamentRecordsAroundOwnerRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ListTournamentRecordsAroundOwnerRequest.new()
		_message.tournament_id = _data.get("tournament_id", "")
		_message.limit = type_convert(_data["limit"], TYPE_INT) if _data.get("limit") != null else null
		_message.owner_id = _data.get("owner_id", "")
		_message.expiry = type_convert(_data["expiry"], TYPE_INT) if _data.get("expiry") != null else null
		_message.cursor = _data.get("cursor", "")
		return _message


	func _init(p_tournament_id: String = "", p_limit: Variant = null, p_owner_id: String = "",
			p_expiry: Variant = null, p_cursor: String = "") -> void:
		tournament_id = p_tournament_id
		limit = p_limit
		owner_id = p_owner_id
		expiry = p_expiry
		cursor = p_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not tournament_id.is_empty():
			_fields.append('"tournament_id":' + JSON.stringify(tournament_id))
		if limit != null:
			_fields.append('"limit":' + JSON.stringify(limit))
		if not owner_id.is_empty():
			_fields.append('"owner_id":' + JSON.stringify(owner_id))
		if expiry != null:
			_fields.append('"expiry":' + JSON.stringify(expiry))
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		return "{%s}" % ",".join(_fields)


## List tournament records from a given tournament.
class ListTournamentRecordsRequest:
	extends RefCounted
	var tournament_id: String
	## int, or null when unset.
	var limit: Variant
	var cursor: String
	## int, or null when unset.
	var expiry: Variant
	var owner_ids: Array = []


	static func from_json(_json: Variant) -> ListTournamentRecordsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ListTournamentRecordsRequest.new()
		_message.tournament_id = _data.get("tournament_id", "")
		_message.limit = type_convert(_data["limit"], TYPE_INT) if _data.get("limit") != null else null
		_message.cursor = _data.get("cursor", "")
		_message.expiry = type_convert(_data["expiry"], TYPE_INT) if _data.get("expiry") != null else null
		_message.owner_ids = _data.get("owner_ids", [])
		return _message


	func _init(p_tournament_id: String = "", p_owner_ids: Array = [], p_limit: Variant = null,
			p_cursor: String = "", p_expiry: Variant = null) -> void:
		tournament_id = p_tournament_id
		owner_ids = p_owner_ids
		limit = p_limit
		cursor = p_cursor
		expiry = p_expiry


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not tournament_id.is_empty():
			_fields.append('"tournament_id":' + JSON.stringify(tournament_id))
		if limit != null:
			_fields.append('"limit":' + JSON.stringify(limit))
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		if expiry != null:
			_fields.append('"expiry":' + JSON.stringify(expiry))
		_fields.append('"owner_ids":[%s]' % ",".join(PackedStringArray(owner_ids.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## List active/upcoming tournaments based on given filters.
class ListTournamentsRequest:
	extends RefCounted
	## int, or null when unset.
	var category_start: Variant
	## int, or null when unset.
	var category_end: Variant
	## int, or null when unset.
	var start_time: Variant
	## int, or null when unset.
	var end_time: Variant
	## int, or null when unset.
	var limit: Variant
	var cursor: String


	static func from_json(_json: Variant) -> ListTournamentsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ListTournamentsRequest.new()
		_message.category_start = type_convert(_data["category_start"], TYPE_INT) if _data.get("category_start") != null else null
		_message.category_end = type_convert(_data["category_end"], TYPE_INT) if _data.get("category_end") != null else null
		_message.start_time = type_convert(_data["start_time"], TYPE_INT) if _data.get("start_time") != null else null
		_message.end_time = type_convert(_data["end_time"], TYPE_INT) if _data.get("end_time") != null else null
		_message.limit = type_convert(_data["limit"], TYPE_INT) if _data.get("limit") != null else null
		_message.cursor = _data.get("cursor", "")
		return _message


	func _init(p_category_start: Variant = null, p_category_end: Variant = null,
			p_start_time: Variant = null, p_end_time: Variant = null, p_limit: Variant = null,
			p_cursor: String = "") -> void:
		category_start = p_category_start
		category_end = p_category_end
		start_time = p_start_time
		end_time = p_end_time
		limit = p_limit
		cursor = p_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if category_start != null:
			_fields.append('"category_start":' + JSON.stringify(category_start))
		if category_end != null:
			_fields.append('"category_end":' + JSON.stringify(category_end))
		if start_time != null:
			_fields.append('"start_time":' + JSON.stringify(start_time))
		if end_time != null:
			_fields.append('"end_time":' + JSON.stringify(end_time))
		if limit != null:
			_fields.append('"limit":' + JSON.stringify(limit))
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		return "{%s}" % ",".join(_fields)


## List the groups a user is part of, and their relationship to each.
class ListUserGroupsRequest:
	extends RefCounted
	var user_id: String
	## int, or null when unset.
	var limit: Variant
	## int, or null when unset.
	var state: Variant
	var cursor: String


	static func from_json(_json: Variant) -> ListUserGroupsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ListUserGroupsRequest.new()
		_message.user_id = _data.get("user_id", "")
		_message.limit = type_convert(_data["limit"], TYPE_INT) if _data.get("limit") != null else null
		_message.state = type_convert(_data["state"], TYPE_INT) if _data.get("state") != null else null
		_message.cursor = _data.get("cursor", "")
		return _message


	func _init(p_user_id: String = "", p_limit: Variant = null, p_state: Variant = null,
			p_cursor: String = "") -> void:
		user_id = p_user_id
		limit = p_limit
		state = p_state
		cursor = p_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not user_id.is_empty():
			_fields.append('"user_id":' + JSON.stringify(user_id))
		if limit != null:
			_fields.append('"limit":' + JSON.stringify(limit))
		if state != null:
			_fields.append('"state":' + JSON.stringify(state))
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		return "{%s}" % ",".join(_fields)


## Represents a realtime match.
class Match:
	extends RefCounted
	var match_id: String
	var authoritative: bool
	## String, or null when unset.
	var label: Variant
	var size: int
	var tick_rate: int
	var handler_name: String


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
		_message.tick_rate = type_convert(_data.get("tick_rate", 0), TYPE_INT)
		_message.handler_name = _data.get("handler_name", "")
		return _message


	func _init(p_match_id: String = "", p_authoritative: bool = false, p_label: Variant = null,
			p_size: int = 0, p_tick_rate: int = 0, p_handler_name: String = "") -> void:
		match_id = p_match_id
		authoritative = p_authoritative
		label = p_label
		size = p_size
		tick_rate = p_tick_rate
		handler_name = p_handler_name


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
		if tick_rate != 0:
			_fields.append('"tick_rate":' + JSON.stringify(tick_rate))
		if not handler_name.is_empty():
			_fields.append('"handler_name":' + JSON.stringify(handler_name))
		return "{%s}" % ",".join(_fields)


## A list of realtime matches.
class MatchList:
	extends RefCounted
	var matches: Array = []


	static func from_json(_json: Variant) -> MatchList:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := MatchList.new()
		var _list_matches: Array = _data.get("matches", [])
		_message.matches = _list_matches.map(func(_v: Variant) -> Match: return Match.from_json(_v))
		return _message


	func _init(p_matches: Array = []) -> void:
		matches = p_matches


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"matches":[%s]' % ",".join(PackedStringArray(matches.map(func(_v: Match) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Matchmaker ticket completion stats.
class MatchmakerCompletionStats:
	extends RefCounted
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var create_time: Variant
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var complete_time: Variant


	static func from_json(_json: Variant) -> MatchmakerCompletionStats:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := MatchmakerCompletionStats.new()
		_message.create_time = _data.get("create_time")
		_message.complete_time = _data.get("complete_time")
		return _message


	func _init(p_create_time: Variant = null, p_complete_time: Variant = null) -> void:
		create_time = p_create_time
		complete_time = p_complete_time


	func to_json() -> String:
		var _fields := PackedStringArray()
		if create_time != null:
			_fields.append('"create_time":' + JSON.stringify(create_time))
		if complete_time != null:
			_fields.append('"complete_time":' + JSON.stringify(complete_time))
		return "{%s}" % ",".join(_fields)


## Matchmaker stats.
class MatchmakerStats:
	extends RefCounted
	var ticket_count: int
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var oldest_ticket_create_time: Variant
	var completions: Array = []


	static func from_json(_json: Variant) -> MatchmakerStats:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := MatchmakerStats.new()
		_message.ticket_count = type_convert(_data.get("ticket_count", 0), TYPE_INT)
		_message.oldest_ticket_create_time = _data.get("oldest_ticket_create_time")
		var _list_completions: Array = _data.get("completions", [])
		_message.completions = _list_completions.map(func(_v: Variant) -> MatchmakerCompletionStats: return MatchmakerCompletionStats.from_json(_v))
		return _message


	func _init(p_ticket_count: int = 0, p_oldest_ticket_create_time: Variant = null,
			p_completions: Array = []) -> void:
		ticket_count = p_ticket_count
		oldest_ticket_create_time = p_oldest_ticket_create_time
		completions = p_completions


	func to_json() -> String:
		var _fields := PackedStringArray()
		if ticket_count != 0:
			_fields.append('"ticket_count":' + JSON.stringify(ticket_count))
		if oldest_ticket_create_time != null:
			_fields.append('"oldest_ticket_create_time":' + JSON.stringify(oldest_ticket_create_time))
		_fields.append('"completions":[%s]' % ",".join(PackedStringArray(completions.map(func(_v: MatchmakerCompletionStats) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## A notification on the server.
class Notification:
	extends RefCounted
	var id: String
	var subject: String
	var content: String
	var code: int
	var sender_id: String
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var create_time: Variant
	var persistent: bool


	static func from_json(_json: Variant) -> Notification:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Notification.new()
		_message.id = _data.get("id", "")
		_message.subject = _data.get("subject", "")
		_message.content = _data.get("content", "")
		_message.code = type_convert(_data.get("code", 0), TYPE_INT)
		_message.sender_id = _data.get("sender_id", "")
		_message.create_time = _data.get("create_time")
		_message.persistent = _data.get("persistent", false)
		return _message


	func _init(p_id: String = "", p_subject: String = "", p_content: String = "", p_code: int = 0,
			p_sender_id: String = "", p_create_time: Variant = null,
			p_persistent: bool = false) -> void:
		id = p_id
		subject = p_subject
		content = p_content
		code = p_code
		sender_id = p_sender_id
		create_time = p_create_time
		persistent = p_persistent


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not id.is_empty():
			_fields.append('"id":' + JSON.stringify(id))
		if not subject.is_empty():
			_fields.append('"subject":' + JSON.stringify(subject))
		if not content.is_empty():
			_fields.append('"content":' + JSON.stringify(content))
		if code != 0:
			_fields.append('"code":' + JSON.stringify(code))
		if not sender_id.is_empty():
			_fields.append('"sender_id":' + JSON.stringify(sender_id))
		if create_time != null:
			_fields.append('"create_time":' + JSON.stringify(create_time))
		if persistent:
			_fields.append('"persistent":' + JSON.stringify(persistent))
		return "{%s}" % ",".join(_fields)


## A collection of zero or more notifications.
class NotificationList:
	extends RefCounted
	var cacheable_cursor: String
	var notifications: Array = []


	static func from_json(_json: Variant) -> NotificationList:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := NotificationList.new()
		_message.cacheable_cursor = _data.get("cacheable_cursor", "")
		var _list_notifications: Array = _data.get("notifications", [])
		_message.notifications = _list_notifications.map(func(_v: Variant) -> Notification: return Notification.from_json(_v))
		return _message


	func _init(p_notifications: Array = [], p_cacheable_cursor: String = "") -> void:
		notifications = p_notifications
		cacheable_cursor = p_cacheable_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not cacheable_cursor.is_empty():
			_fields.append('"cacheable_cursor":' + JSON.stringify(cacheable_cursor))
		_fields.append('"notifications":[%s]' % ",".join(PackedStringArray(notifications.map(func(_v: Notification) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Promote a set of users in a group to the next role up.
class PromoteGroupUsersRequest:
	extends RefCounted
	var group_id: String
	var user_ids: Array = []


	static func from_json(_json: Variant) -> PromoteGroupUsersRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := PromoteGroupUsersRequest.new()
		_message.group_id = _data.get("group_id", "")
		_message.user_ids = _data.get("user_ids", [])
		return _message


	func _init(p_group_id: String = "", p_user_ids: Array = []) -> void:
		group_id = p_group_id
		user_ids = p_user_ids


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not group_id.is_empty():
			_fields.append('"group_id":' + JSON.stringify(group_id))
		_fields.append('"user_ids":[%s]' % ",".join(PackedStringArray(user_ids.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## Demote a set of users in a group to the next role down.
class DemoteGroupUsersRequest:
	extends RefCounted
	var group_id: String
	var user_ids: Array = []


	static func from_json(_json: Variant) -> DemoteGroupUsersRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := DemoteGroupUsersRequest.new()
		_message.group_id = _data.get("group_id", "")
		_message.user_ids = _data.get("user_ids", [])
		return _message


	func _init(p_group_id: String = "", p_user_ids: Array = []) -> void:
		group_id = p_group_id
		user_ids = p_user_ids


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not group_id.is_empty():
			_fields.append('"group_id":' + JSON.stringify(group_id))
		_fields.append('"user_ids":[%s]' % ",".join(PackedStringArray(user_ids.map(func(_v: String) -> String: return JSON.stringify(_v)))))
		return "{%s}" % ",".join(_fields)


## Storage objects to get.
class ReadStorageObjectId:
	extends RefCounted
	var collection: String
	var key: String
	var user_id: String


	static func from_json(_json: Variant) -> ReadStorageObjectId:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ReadStorageObjectId.new()
		_message.collection = _data.get("collection", "")
		_message.key = _data.get("key", "")
		_message.user_id = _data.get("user_id", "")
		return _message


	func _init(p_collection: String = "", p_key: String = "", p_user_id: String = "") -> void:
		collection = p_collection
		key = p_key
		user_id = p_user_id


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not collection.is_empty():
			_fields.append('"collection":' + JSON.stringify(collection))
		if not key.is_empty():
			_fields.append('"key":' + JSON.stringify(key))
		if not user_id.is_empty():
			_fields.append('"user_id":' + JSON.stringify(user_id))
		return "{%s}" % ",".join(_fields)


## Batch get storage objects.
class ReadStorageObjectsRequest:
	extends RefCounted
	var object_ids: Array = []


	static func from_json(_json: Variant) -> ReadStorageObjectsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ReadStorageObjectsRequest.new()
		var _list_object_ids: Array = _data.get("object_ids", [])
		_message.object_ids = _list_object_ids.map(func(_v: Variant) -> ReadStorageObjectId: return ReadStorageObjectId.from_json(_v))
		return _message


	func _init(p_object_ids: Array = []) -> void:
		object_ids = p_object_ids


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"object_ids":[%s]' % ",".join(PackedStringArray(object_ids.map(func(_v: ReadStorageObjectId) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Execute a Lua function on the server.
class Rpc:
	extends RefCounted
	var id: String
	var payload: String
	var http_key: String


	static func from_json(_json: Variant) -> Rpc:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Rpc.new()
		_message.id = _data.get("id", "")
		_message.payload = _data.get("payload", "")
		_message.http_key = _data.get("http_key", "")
		return _message


	func _init(p_id: String = "", p_payload: String = "", p_http_key: String = "") -> void:
		id = p_id
		payload = p_payload
		http_key = p_http_key


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not id.is_empty():
			_fields.append('"id":' + JSON.stringify(id))
		if not payload.is_empty():
			_fields.append('"payload":' + JSON.stringify(payload))
		if not http_key.is_empty():
			_fields.append('"http_key":' + JSON.stringify(http_key))
		return "{%s}" % ",".join(_fields)


## An object within the storage engine.
class StorageObject:
	extends RefCounted
	var collection: String
	var key: String
	var user_id: String
	var value: String
	var version: String
	var permission_read: int
	var permission_write: int
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var create_time: Variant
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var update_time: Variant


	static func from_json(_json: Variant) -> StorageObject:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := StorageObject.new()
		_message.collection = _data.get("collection", "")
		_message.key = _data.get("key", "")
		_message.user_id = _data.get("user_id", "")
		_message.value = _data.get("value", "")
		_message.version = _data.get("version", "")
		_message.permission_read = type_convert(_data.get("permission_read", 0), TYPE_INT)
		_message.permission_write = type_convert(_data.get("permission_write", 0), TYPE_INT)
		_message.create_time = _data.get("create_time")
		_message.update_time = _data.get("update_time")
		return _message


	func _init(p_collection: String = "", p_key: String = "", p_user_id: String = "",
			p_value: String = "", p_version: String = "", p_permission_read: int = 0,
			p_permission_write: int = 0, p_create_time: Variant = null,
			p_update_time: Variant = null) -> void:
		collection = p_collection
		key = p_key
		user_id = p_user_id
		value = p_value
		version = p_version
		permission_read = p_permission_read
		permission_write = p_permission_write
		create_time = p_create_time
		update_time = p_update_time


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not collection.is_empty():
			_fields.append('"collection":' + JSON.stringify(collection))
		if not key.is_empty():
			_fields.append('"key":' + JSON.stringify(key))
		if not user_id.is_empty():
			_fields.append('"user_id":' + JSON.stringify(user_id))
		if not value.is_empty():
			_fields.append('"value":' + JSON.stringify(value))
		if not version.is_empty():
			_fields.append('"version":' + JSON.stringify(version))
		if permission_read != 0:
			_fields.append('"permission_read":' + JSON.stringify(permission_read))
		if permission_write != 0:
			_fields.append('"permission_write":' + JSON.stringify(permission_write))
		if create_time != null:
			_fields.append('"create_time":' + JSON.stringify(create_time))
		if update_time != null:
			_fields.append('"update_time":' + JSON.stringify(update_time))
		return "{%s}" % ",".join(_fields)


## A storage acknowledgement.
class StorageObjectAck:
	extends RefCounted
	var collection: String
	var key: String
	var version: String
	var user_id: String
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var create_time: Variant
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var update_time: Variant


	static func from_json(_json: Variant) -> StorageObjectAck:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := StorageObjectAck.new()
		_message.collection = _data.get("collection", "")
		_message.key = _data.get("key", "")
		_message.version = _data.get("version", "")
		_message.user_id = _data.get("user_id", "")
		_message.create_time = _data.get("create_time")
		_message.update_time = _data.get("update_time")
		return _message


	func _init(p_collection: String = "", p_key: String = "", p_version: String = "",
			p_user_id: String = "", p_create_time: Variant = null,
			p_update_time: Variant = null) -> void:
		collection = p_collection
		key = p_key
		version = p_version
		user_id = p_user_id
		create_time = p_create_time
		update_time = p_update_time


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not collection.is_empty():
			_fields.append('"collection":' + JSON.stringify(collection))
		if not key.is_empty():
			_fields.append('"key":' + JSON.stringify(key))
		if not version.is_empty():
			_fields.append('"version":' + JSON.stringify(version))
		if not user_id.is_empty():
			_fields.append('"user_id":' + JSON.stringify(user_id))
		if create_time != null:
			_fields.append('"create_time":' + JSON.stringify(create_time))
		if update_time != null:
			_fields.append('"update_time":' + JSON.stringify(update_time))
		return "{%s}" % ",".join(_fields)


## Batch of acknowledgements for the storage object write.
class StorageObjectAcks:
	extends RefCounted
	var acks: Array = []


	static func from_json(_json: Variant) -> StorageObjectAcks:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := StorageObjectAcks.new()
		var _list_acks: Array = _data.get("acks", [])
		_message.acks = _list_acks.map(func(_v: Variant) -> StorageObjectAck: return StorageObjectAck.from_json(_v))
		return _message


	func _init(p_acks: Array = []) -> void:
		acks = p_acks


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"acks":[%s]' % ",".join(PackedStringArray(acks.map(func(_v: StorageObjectAck) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Batch of storage objects.
class StorageObjects:
	extends RefCounted
	var objects: Array = []


	static func from_json(_json: Variant) -> StorageObjects:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := StorageObjects.new()
		var _list_objects: Array = _data.get("objects", [])
		_message.objects = _list_objects.map(func(_v: Variant) -> StorageObject: return StorageObject.from_json(_v))
		return _message


	func _init(p_objects: Array = []) -> void:
		objects = p_objects


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"objects":[%s]' % ",".join(PackedStringArray(objects.map(func(_v: StorageObject) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## List of storage objects.
class StorageObjectList:
	extends RefCounted
	var cursor: String
	var objects: Array = []


	static func from_json(_json: Variant) -> StorageObjectList:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := StorageObjectList.new()
		_message.cursor = _data.get("cursor", "")
		var _list_objects: Array = _data.get("objects", [])
		_message.objects = _list_objects.map(func(_v: Variant) -> StorageObject: return StorageObject.from_json(_v))
		return _message


	func _init(p_objects: Array = [], p_cursor: String = "") -> void:
		objects = p_objects
		cursor = p_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		_fields.append('"objects":[%s]' % ",".join(PackedStringArray(objects.map(func(_v: StorageObject) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## A tournament on the server.
class Tournament:
	extends RefCounted
	var id: String
	var title: String
	var description: String
	var category: int
	var sort_order: int
	var size: int
	var max_size: int
	var max_num_score: int
	var can_enter: bool
	var end_active: int
	var next_reset: int
	var metadata: String
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var create_time: Variant
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var start_time: Variant
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var end_time: Variant
	var duration: int
	var start_active: int
	var prev_reset: int
	var operator: Operator
	var authoritative: bool
	var join_required: bool


	static func from_json(_json: Variant) -> Tournament:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Tournament.new()
		_message.id = _data.get("id", "")
		_message.title = _data.get("title", "")
		_message.description = _data.get("description", "")
		_message.category = type_convert(_data.get("category", 0), TYPE_INT)
		_message.sort_order = type_convert(_data.get("sort_order", 0), TYPE_INT)
		_message.size = type_convert(_data.get("size", 0), TYPE_INT)
		_message.max_size = type_convert(_data.get("max_size", 0), TYPE_INT)
		_message.max_num_score = type_convert(_data.get("max_num_score", 0), TYPE_INT)
		_message.can_enter = _data.get("can_enter", false)
		_message.end_active = type_convert(_data.get("end_active", 0), TYPE_INT)
		_message.next_reset = type_convert(_data.get("next_reset", 0), TYPE_INT)
		_message.metadata = _data.get("metadata", "")
		_message.create_time = _data.get("create_time")
		_message.start_time = _data.get("start_time")
		_message.end_time = _data.get("end_time")
		_message.duration = type_convert(_data.get("duration", 0), TYPE_INT)
		_message.start_active = type_convert(_data.get("start_active", 0), TYPE_INT)
		_message.prev_reset = type_convert(_data.get("prev_reset", 0), TYPE_INT)
		_message.operator = type_convert(_data.get("operator", 0), TYPE_INT)
		_message.authoritative = _data.get("authoritative", false)
		_message.join_required = _data.get("join_required", false)
		return _message


	func _init(p_id: String = "", p_title: String = "", p_description: String = "",
			p_category: int = 0, p_sort_order: int = 0, p_size: int = 0, p_max_size: int = 0,
			p_max_num_score: int = 0, p_can_enter: bool = false, p_end_active: int = 0,
			p_next_reset: int = 0, p_metadata: String = "", p_create_time: Variant = null,
			p_start_time: Variant = null, p_end_time: Variant = null, p_duration: int = 0,
			p_start_active: int = 0, p_prev_reset: int = 0,
			p_operator: Operator = Operator.NO_OVERRIDE, p_authoritative: bool = false,
			p_join_required: bool = false) -> void:
		id = p_id
		title = p_title
		description = p_description
		category = p_category
		sort_order = p_sort_order
		size = p_size
		max_size = p_max_size
		max_num_score = p_max_num_score
		can_enter = p_can_enter
		end_active = p_end_active
		next_reset = p_next_reset
		metadata = p_metadata
		create_time = p_create_time
		start_time = p_start_time
		end_time = p_end_time
		duration = p_duration
		start_active = p_start_active
		prev_reset = p_prev_reset
		operator = p_operator
		authoritative = p_authoritative
		join_required = p_join_required


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not id.is_empty():
			_fields.append('"id":' + JSON.stringify(id))
		if not title.is_empty():
			_fields.append('"title":' + JSON.stringify(title))
		if not description.is_empty():
			_fields.append('"description":' + JSON.stringify(description))
		if category != 0:
			_fields.append('"category":' + JSON.stringify(category))
		if sort_order != 0:
			_fields.append('"sort_order":' + JSON.stringify(sort_order))
		if size != 0:
			_fields.append('"size":' + JSON.stringify(size))
		if max_size != 0:
			_fields.append('"max_size":' + JSON.stringify(max_size))
		if max_num_score != 0:
			_fields.append('"max_num_score":' + JSON.stringify(max_num_score))
		if can_enter:
			_fields.append('"can_enter":' + JSON.stringify(can_enter))
		if end_active != 0:
			_fields.append('"end_active":' + JSON.stringify(end_active))
		if next_reset != 0:
			_fields.append('"next_reset":' + JSON.stringify(next_reset))
		if not metadata.is_empty():
			_fields.append('"metadata":' + JSON.stringify(metadata))
		if create_time != null:
			_fields.append('"create_time":' + JSON.stringify(create_time))
		if start_time != null:
			_fields.append('"start_time":' + JSON.stringify(start_time))
		if end_time != null:
			_fields.append('"end_time":' + JSON.stringify(end_time))
		if duration != 0:
			_fields.append('"duration":' + JSON.stringify(duration))
		if start_active != 0:
			_fields.append('"start_active":' + JSON.stringify(start_active))
		if prev_reset != 0:
			_fields.append('"prev_reset":' + JSON.stringify(prev_reset))
		if operator != 0:
			_fields.append('"operator":' + JSON.stringify(operator))
		if authoritative:
			_fields.append('"authoritative":' + JSON.stringify(authoritative))
		if join_required:
			_fields.append('"join_required":' + JSON.stringify(join_required))
		return "{%s}" % ",".join(_fields)


## A list of tournaments.
class TournamentList:
	extends RefCounted
	var cursor: String
	var tournaments: Array = []


	static func from_json(_json: Variant) -> TournamentList:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := TournamentList.new()
		_message.cursor = _data.get("cursor", "")
		var _list_tournaments: Array = _data.get("tournaments", [])
		_message.tournaments = _list_tournaments.map(func(_v: Variant) -> Tournament: return Tournament.from_json(_v))
		return _message


	func _init(p_tournaments: Array = [], p_cursor: String = "") -> void:
		tournaments = p_tournaments
		cursor = p_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		_fields.append('"tournaments":[%s]' % ",".join(PackedStringArray(tournaments.map(func(_v: Tournament) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## A set of tournament records which may be part of a tournament records page or a batch of individual records.
class TournamentRecordList:
	extends RefCounted
	var next_cursor: String
	var prev_cursor: String
	var rank_count: int
	var records: Array = []
	var owner_records: Array = []


	static func from_json(_json: Variant) -> TournamentRecordList:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := TournamentRecordList.new()
		_message.next_cursor = _data.get("next_cursor", "")
		_message.prev_cursor = _data.get("prev_cursor", "")
		_message.rank_count = type_convert(_data.get("rank_count", 0), TYPE_INT)
		var _list_records: Array = _data.get("records", [])
		_message.records = _list_records.map(func(_v: Variant) -> LeaderboardRecord: return LeaderboardRecord.from_json(_v))
		var _list_owner_records: Array = _data.get("owner_records", [])
		_message.owner_records = _list_owner_records.map(func(_v: Variant) -> LeaderboardRecord: return LeaderboardRecord.from_json(_v))
		return _message


	func _init(p_records: Array = [], p_owner_records: Array = [], p_next_cursor: String = "",
			p_prev_cursor: String = "", p_rank_count: int = 0) -> void:
		records = p_records
		owner_records = p_owner_records
		next_cursor = p_next_cursor
		prev_cursor = p_prev_cursor
		rank_count = p_rank_count


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not next_cursor.is_empty():
			_fields.append('"next_cursor":' + JSON.stringify(next_cursor))
		if not prev_cursor.is_empty():
			_fields.append('"prev_cursor":' + JSON.stringify(prev_cursor))
		if rank_count != 0:
			_fields.append('"rank_count":' + JSON.stringify(rank_count))
		_fields.append('"records":[%s]' % ",".join(PackedStringArray(records.map(func(_v: LeaderboardRecord) -> String: return _v.to_json()))))
		_fields.append('"owner_records":[%s]' % ",".join(PackedStringArray(owner_records.map(func(_v: LeaderboardRecord) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Update a user's account details.
class UpdateAccountRequest:
	extends RefCounted
	## String, or null when unset.
	var username: Variant
	## String, or null when unset.
	var display_name: Variant
	## String, or null when unset.
	var avatar_url: Variant
	## String, or null when unset.
	var lang_tag: Variant
	## String, or null when unset.
	var location: Variant
	## String, or null when unset.
	var timezone: Variant


	static func from_json(_json: Variant) -> UpdateAccountRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := UpdateAccountRequest.new()
		_message.username = _data["username"] if _data.get("username") != null else null
		_message.display_name = _data["display_name"] if _data.get("display_name") != null else null
		_message.avatar_url = _data["avatar_url"] if _data.get("avatar_url") != null else null
		_message.lang_tag = _data["lang_tag"] if _data.get("lang_tag") != null else null
		_message.location = _data["location"] if _data.get("location") != null else null
		_message.timezone = _data["timezone"] if _data.get("timezone") != null else null
		return _message


	func _init(p_username: Variant = null, p_display_name: Variant = null,
			p_avatar_url: Variant = null, p_lang_tag: Variant = null, p_location: Variant = null,
			p_timezone: Variant = null) -> void:
		username = p_username
		display_name = p_display_name
		avatar_url = p_avatar_url
		lang_tag = p_lang_tag
		location = p_location
		timezone = p_timezone


	func to_json() -> String:
		var _fields := PackedStringArray()
		if username != null:
			_fields.append('"username":' + JSON.stringify(username))
		if display_name != null:
			_fields.append('"display_name":' + JSON.stringify(display_name))
		if avatar_url != null:
			_fields.append('"avatar_url":' + JSON.stringify(avatar_url))
		if lang_tag != null:
			_fields.append('"lang_tag":' + JSON.stringify(lang_tag))
		if location != null:
			_fields.append('"location":' + JSON.stringify(location))
		if timezone != null:
			_fields.append('"timezone":' + JSON.stringify(timezone))
		return "{%s}" % ",".join(_fields)


## Update fields in a given group.
class UpdateGroupRequest:
	extends RefCounted
	var group_id: String
	## String, or null when unset.
	var name: Variant
	## String, or null when unset.
	var description: Variant
	## String, or null when unset.
	var lang_tag: Variant
	## String, or null when unset.
	var avatar_url: Variant
	## bool, or null when unset.
	var open: Variant


	static func from_json(_json: Variant) -> UpdateGroupRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := UpdateGroupRequest.new()
		_message.group_id = _data.get("group_id", "")
		_message.name = _data["name"] if _data.get("name") != null else null
		_message.description = _data["description"] if _data.get("description") != null else null
		_message.lang_tag = _data["lang_tag"] if _data.get("lang_tag") != null else null
		_message.avatar_url = _data["avatar_url"] if _data.get("avatar_url") != null else null
		_message.open = _data["open"] if _data.get("open") != null else null
		return _message


	func _init(p_group_id: String = "", p_name: Variant = null, p_description: Variant = null,
			p_lang_tag: Variant = null, p_avatar_url: Variant = null,
			p_open: Variant = null) -> void:
		group_id = p_group_id
		name = p_name
		description = p_description
		lang_tag = p_lang_tag
		avatar_url = p_avatar_url
		open = p_open


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not group_id.is_empty():
			_fields.append('"group_id":' + JSON.stringify(group_id))
		if name != null:
			_fields.append('"name":' + JSON.stringify(name))
		if description != null:
			_fields.append('"description":' + JSON.stringify(description))
		if lang_tag != null:
			_fields.append('"lang_tag":' + JSON.stringify(lang_tag))
		if avatar_url != null:
			_fields.append('"avatar_url":' + JSON.stringify(avatar_url))
		if open != null:
			_fields.append('"open":' + JSON.stringify(open))
		return "{%s}" % ",".join(_fields)


## A single group-role pair.
class UserGroupListUserGroup:
	extends RefCounted
	var group: Group
	## int, or null when unset.
	var state: Variant


	static func from_json(_json: Variant) -> UserGroupListUserGroup:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := UserGroupListUserGroup.new()
		_message.group = Group.from_json(_data["group"]) if _data.get("group") != null else null
		_message.state = type_convert(_data["state"], TYPE_INT) if _data.get("state") != null else null
		return _message


	func _init(p_group: Group = null, p_state: Variant = null) -> void:
		group = p_group
		state = p_state


	func to_json() -> String:
		var _fields := PackedStringArray()
		if group != null:
			_fields.append('"group":' + group.to_json())
		if state != null:
			_fields.append('"state":' + JSON.stringify(state))
		return "{%s}" % ",".join(_fields)


## A list of groups belonging to a user, along with the user's role in each group.
class UserGroupList:
	extends RefCounted
	var cursor: String
	var user_groups: Array = []


	static func from_json(_json: Variant) -> UserGroupList:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := UserGroupList.new()
		_message.cursor = _data.get("cursor", "")
		var _list_user_groups: Array = _data.get("user_groups", [])
		_message.user_groups = _list_user_groups.map(func(_v: Variant) -> UserGroupListUserGroup: return UserGroupListUserGroup.from_json(_v))
		return _message


	func _init(p_user_groups: Array = [], p_cursor: String = "") -> void:
		user_groups = p_user_groups
		cursor = p_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		_fields.append('"user_groups":[%s]' % ",".join(PackedStringArray(user_groups.map(func(_v: UserGroupListUserGroup) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## A collection of zero or more users.
class Users:
	extends RefCounted
	var users: Array = []


	static func from_json(_json: Variant) -> Users:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := Users.new()
		var _list_users: Array = _data.get("users", [])
		_message.users = _list_users.map(func(_v: Variant) -> User: return User.from_json(_v))
		return _message


	func _init(p_users: Array = []) -> void:
		users = p_users


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"users":[%s]' % ",".join(PackedStringArray(users.map(func(_v: User) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Apple IAP purchase validation request.
class ValidatePurchaseAppleRequest:
	extends RefCounted
	var receipt: String
	## bool, or null when unset.
	var persist: Variant


	static func from_json(_json: Variant) -> ValidatePurchaseAppleRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ValidatePurchaseAppleRequest.new()
		_message.receipt = _data.get("receipt", "")
		_message.persist = _data["persist"] if _data.get("persist") != null else null
		return _message


	func _init(p_receipt: String = "", p_persist: Variant = null) -> void:
		receipt = p_receipt
		persist = p_persist


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not receipt.is_empty():
			_fields.append('"receipt":' + JSON.stringify(receipt))
		if persist != null:
			_fields.append('"persist":' + JSON.stringify(persist))
		return "{%s}" % ",".join(_fields)


## Apple subscription validation request.
class ValidateSubscriptionAppleRequest:
	extends RefCounted
	var receipt: String
	## bool, or null when unset.
	var persist: Variant


	static func from_json(_json: Variant) -> ValidateSubscriptionAppleRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ValidateSubscriptionAppleRequest.new()
		_message.receipt = _data.get("receipt", "")
		_message.persist = _data["persist"] if _data.get("persist") != null else null
		return _message


	func _init(p_receipt: String = "", p_persist: Variant = null) -> void:
		receipt = p_receipt
		persist = p_persist


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not receipt.is_empty():
			_fields.append('"receipt":' + JSON.stringify(receipt))
		if persist != null:
			_fields.append('"persist":' + JSON.stringify(persist))
		return "{%s}" % ",".join(_fields)


## Google IAP purchase validation request.
class ValidatePurchaseGoogleRequest:
	extends RefCounted
	var purchase: String
	## bool, or null when unset.
	var persist: Variant


	static func from_json(_json: Variant) -> ValidatePurchaseGoogleRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ValidatePurchaseGoogleRequest.new()
		_message.purchase = _data.get("purchase", "")
		_message.persist = _data["persist"] if _data.get("persist") != null else null
		return _message


	func _init(p_purchase: String = "", p_persist: Variant = null) -> void:
		purchase = p_purchase
		persist = p_persist


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not purchase.is_empty():
			_fields.append('"purchase":' + JSON.stringify(purchase))
		if persist != null:
			_fields.append('"persist":' + JSON.stringify(persist))
		return "{%s}" % ",".join(_fields)


## Google subscription validation request.
class ValidateSubscriptionGoogleRequest:
	extends RefCounted
	var receipt: String
	## bool, or null when unset.
	var persist: Variant


	static func from_json(_json: Variant) -> ValidateSubscriptionGoogleRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ValidateSubscriptionGoogleRequest.new()
		_message.receipt = _data.get("receipt", "")
		_message.persist = _data["persist"] if _data.get("persist") != null else null
		return _message


	func _init(p_receipt: String = "", p_persist: Variant = null) -> void:
		receipt = p_receipt
		persist = p_persist


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not receipt.is_empty():
			_fields.append('"receipt":' + JSON.stringify(receipt))
		if persist != null:
			_fields.append('"persist":' + JSON.stringify(persist))
		return "{%s}" % ",".join(_fields)


## Huawei IAP purchase validation request.
class ValidatePurchaseHuaweiRequest:
	extends RefCounted
	var purchase: String
	var signature: String
	## bool, or null when unset.
	var persist: Variant


	static func from_json(_json: Variant) -> ValidatePurchaseHuaweiRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ValidatePurchaseHuaweiRequest.new()
		_message.purchase = _data.get("purchase", "")
		_message.signature = _data.get("signature", "")
		_message.persist = _data["persist"] if _data.get("persist") != null else null
		return _message


	func _init(p_purchase: String = "", p_signature: String = "",
			p_persist: Variant = null) -> void:
		purchase = p_purchase
		signature = p_signature
		persist = p_persist


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not purchase.is_empty():
			_fields.append('"purchase":' + JSON.stringify(purchase))
		if not signature.is_empty():
			_fields.append('"signature":' + JSON.stringify(signature))
		if persist != null:
			_fields.append('"persist":' + JSON.stringify(persist))
		return "{%s}" % ",".join(_fields)


## Facebook Instant IAP purchase validation request.
class ValidatePurchaseFacebookInstantRequest:
	extends RefCounted
	var signed_request: String
	## bool, or null when unset.
	var persist: Variant


	static func from_json(_json: Variant) -> ValidatePurchaseFacebookInstantRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ValidatePurchaseFacebookInstantRequest.new()
		_message.signed_request = _data.get("signed_request", "")
		_message.persist = _data["persist"] if _data.get("persist") != null else null
		return _message


	func _init(p_signed_request: String = "", p_persist: Variant = null) -> void:
		signed_request = p_signed_request
		persist = p_persist


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not signed_request.is_empty():
			_fields.append('"signed_request":' + JSON.stringify(signed_request))
		if persist != null:
			_fields.append('"persist":' + JSON.stringify(persist))
		return "{%s}" % ",".join(_fields)


## Samsung IAP purchase validation request.
class ValidatePurchaseSamsungRequest:
	extends RefCounted
	var purchase_id: String
	## bool, or null when unset.
	var persist: Variant


	static func from_json(_json: Variant) -> ValidatePurchaseSamsungRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ValidatePurchaseSamsungRequest.new()
		_message.purchase_id = _data.get("purchase_id", "")
		_message.persist = _data["persist"] if _data.get("persist") != null else null
		return _message


	func _init(p_purchase_id: String = "", p_persist: Variant = null) -> void:
		purchase_id = p_purchase_id
		persist = p_persist


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not purchase_id.is_empty():
			_fields.append('"purchase_id":' + JSON.stringify(purchase_id))
		if persist != null:
			_fields.append('"persist":' + JSON.stringify(persist))
		return "{%s}" % ",".join(_fields)


## A validated purchase stored by Nakama.
class ValidatedPurchase:
	extends RefCounted
	var user_id: String
	var product_id: String
	var transaction_id: String
	var store: StoreProvider
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var purchase_time: Variant
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var create_time: Variant
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var update_time: Variant
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var refund_time: Variant
	var provider_response: String
	var environment: StoreEnvironment
	var seen_before: bool


	static func from_json(_json: Variant) -> ValidatedPurchase:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ValidatedPurchase.new()
		_message.user_id = _data.get("user_id", "")
		_message.product_id = _data.get("product_id", "")
		_message.transaction_id = _data.get("transaction_id", "")
		_message.store = type_convert(_data.get("store", 0), TYPE_INT)
		_message.purchase_time = _data.get("purchase_time")
		_message.create_time = _data.get("create_time")
		_message.update_time = _data.get("update_time")
		_message.refund_time = _data.get("refund_time")
		_message.provider_response = _data.get("provider_response", "")
		_message.environment = type_convert(_data.get("environment", 0), TYPE_INT)
		_message.seen_before = _data.get("seen_before", false)
		return _message


	func _init(p_user_id: String = "", p_product_id: String = "", p_transaction_id: String = "",
			p_store: StoreProvider = StoreProvider.APPLE_APP_STORE, p_purchase_time: Variant = null,
			p_create_time: Variant = null, p_update_time: Variant = null,
			p_refund_time: Variant = null, p_provider_response: String = "",
			p_environment: StoreEnvironment = StoreEnvironment.UNKNOWN,
			p_seen_before: bool = false) -> void:
		user_id = p_user_id
		product_id = p_product_id
		transaction_id = p_transaction_id
		store = p_store
		purchase_time = p_purchase_time
		create_time = p_create_time
		update_time = p_update_time
		refund_time = p_refund_time
		provider_response = p_provider_response
		environment = p_environment
		seen_before = p_seen_before


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not user_id.is_empty():
			_fields.append('"user_id":' + JSON.stringify(user_id))
		if not product_id.is_empty():
			_fields.append('"product_id":' + JSON.stringify(product_id))
		if not transaction_id.is_empty():
			_fields.append('"transaction_id":' + JSON.stringify(transaction_id))
		if store != 0:
			_fields.append('"store":' + JSON.stringify(store))
		if purchase_time != null:
			_fields.append('"purchase_time":' + JSON.stringify(purchase_time))
		if create_time != null:
			_fields.append('"create_time":' + JSON.stringify(create_time))
		if update_time != null:
			_fields.append('"update_time":' + JSON.stringify(update_time))
		if refund_time != null:
			_fields.append('"refund_time":' + JSON.stringify(refund_time))
		if not provider_response.is_empty():
			_fields.append('"provider_response":' + JSON.stringify(provider_response))
		if environment != 0:
			_fields.append('"environment":' + JSON.stringify(environment))
		if seen_before:
			_fields.append('"seen_before":' + JSON.stringify(seen_before))
		return "{%s}" % ",".join(_fields)


## Validate IAP response.
class ValidatePurchaseResponse:
	extends RefCounted
	var validated_purchases: Array = []


	static func from_json(_json: Variant) -> ValidatePurchaseResponse:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ValidatePurchaseResponse.new()
		var _list_validated_purchases: Array = _data.get("validated_purchases", [])
		_message.validated_purchases = _list_validated_purchases.map(func(_v: Variant) -> ValidatedPurchase: return ValidatedPurchase.from_json(_v))
		return _message


	func _init(p_validated_purchases: Array = []) -> void:
		validated_purchases = p_validated_purchases


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"validated_purchases":[%s]' % ",".join(PackedStringArray(validated_purchases.map(func(_v: ValidatedPurchase) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


class ValidatedSubscription:
	extends RefCounted
	var user_id: String
	var product_id: String
	var original_transaction_id: String
	var store: StoreProvider
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var purchase_time: Variant
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var create_time: Variant
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var update_time: Variant
	var environment: StoreEnvironment
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var expiry_time: Variant
	## String (RFC 3339 UTC, e.g. 2026-01-02T03:04:05Z), or null when unset.
	var refund_time: Variant
	var provider_response: String
	var provider_notification: String
	var active: bool


	static func from_json(_json: Variant) -> ValidatedSubscription:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ValidatedSubscription.new()
		_message.user_id = _data.get("user_id", "")
		_message.product_id = _data.get("product_id", "")
		_message.original_transaction_id = _data.get("original_transaction_id", "")
		_message.store = type_convert(_data.get("store", 0), TYPE_INT)
		_message.purchase_time = _data.get("purchase_time")
		_message.create_time = _data.get("create_time")
		_message.update_time = _data.get("update_time")
		_message.environment = type_convert(_data.get("environment", 0), TYPE_INT)
		_message.expiry_time = _data.get("expiry_time")
		_message.refund_time = _data.get("refund_time")
		_message.provider_response = _data.get("provider_response", "")
		_message.provider_notification = _data.get("provider_notification", "")
		_message.active = _data.get("active", false)
		return _message


	func _init(p_user_id: String = "", p_product_id: String = "",
			p_original_transaction_id: String = "",
			p_store: StoreProvider = StoreProvider.APPLE_APP_STORE, p_purchase_time: Variant = null,
			p_create_time: Variant = null, p_update_time: Variant = null,
			p_environment: StoreEnvironment = StoreEnvironment.UNKNOWN,
			p_expiry_time: Variant = null, p_refund_time: Variant = null,
			p_provider_response: String = "", p_provider_notification: String = "",
			p_active: bool = false) -> void:
		user_id = p_user_id
		product_id = p_product_id
		original_transaction_id = p_original_transaction_id
		store = p_store
		purchase_time = p_purchase_time
		create_time = p_create_time
		update_time = p_update_time
		environment = p_environment
		expiry_time = p_expiry_time
		refund_time = p_refund_time
		provider_response = p_provider_response
		provider_notification = p_provider_notification
		active = p_active


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not user_id.is_empty():
			_fields.append('"user_id":' + JSON.stringify(user_id))
		if not product_id.is_empty():
			_fields.append('"product_id":' + JSON.stringify(product_id))
		if not original_transaction_id.is_empty():
			_fields.append('"original_transaction_id":' + JSON.stringify(original_transaction_id))
		if store != 0:
			_fields.append('"store":' + JSON.stringify(store))
		if purchase_time != null:
			_fields.append('"purchase_time":' + JSON.stringify(purchase_time))
		if create_time != null:
			_fields.append('"create_time":' + JSON.stringify(create_time))
		if update_time != null:
			_fields.append('"update_time":' + JSON.stringify(update_time))
		if environment != 0:
			_fields.append('"environment":' + JSON.stringify(environment))
		if expiry_time != null:
			_fields.append('"expiry_time":' + JSON.stringify(expiry_time))
		if refund_time != null:
			_fields.append('"refund_time":' + JSON.stringify(refund_time))
		if not provider_response.is_empty():
			_fields.append('"provider_response":' + JSON.stringify(provider_response))
		if not provider_notification.is_empty():
			_fields.append('"provider_notification":' + JSON.stringify(provider_notification))
		if active:
			_fields.append('"active":' + JSON.stringify(active))
		return "{%s}" % ",".join(_fields)


## Validate Subscription response.
class ValidateSubscriptionResponse:
	extends RefCounted
	var validated_subscription: ValidatedSubscription


	static func from_json(_json: Variant) -> ValidateSubscriptionResponse:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ValidateSubscriptionResponse.new()
		_message.validated_subscription = ValidatedSubscription.from_json(_data["validated_subscription"]) if _data.get("validated_subscription") != null else null
		return _message


	func _init(p_validated_subscription: ValidatedSubscription = null) -> void:
		validated_subscription = p_validated_subscription


	func to_json() -> String:
		var _fields := PackedStringArray()
		if validated_subscription != null:
			_fields.append('"validated_subscription":' + validated_subscription.to_json())
		return "{%s}" % ",".join(_fields)


## A list of validated purchases stored by Nakama.
class PurchaseList:
	extends RefCounted
	var cursor: String
	var prev_cursor: String
	var validated_purchases: Array = []


	static func from_json(_json: Variant) -> PurchaseList:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := PurchaseList.new()
		_message.cursor = _data.get("cursor", "")
		_message.prev_cursor = _data.get("prev_cursor", "")
		var _list_validated_purchases: Array = _data.get("validated_purchases", [])
		_message.validated_purchases = _list_validated_purchases.map(func(_v: Variant) -> ValidatedPurchase: return ValidatedPurchase.from_json(_v))
		return _message


	func _init(p_validated_purchases: Array = [], p_cursor: String = "",
			p_prev_cursor: String = "") -> void:
		validated_purchases = p_validated_purchases
		cursor = p_cursor
		prev_cursor = p_prev_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		if not prev_cursor.is_empty():
			_fields.append('"prev_cursor":' + JSON.stringify(prev_cursor))
		_fields.append('"validated_purchases":[%s]' % ",".join(PackedStringArray(validated_purchases.map(func(_v: ValidatedPurchase) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## A list of validated subscriptions stored by Nakama.
class SubscriptionList:
	extends RefCounted
	var cursor: String
	var prev_cursor: String
	var validated_subscriptions: Array = []


	static func from_json(_json: Variant) -> SubscriptionList:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := SubscriptionList.new()
		_message.cursor = _data.get("cursor", "")
		_message.prev_cursor = _data.get("prev_cursor", "")
		var _list_validated_subscriptions: Array = _data.get("validated_subscriptions", [])
		_message.validated_subscriptions = _list_validated_subscriptions.map(func(_v: Variant) -> ValidatedSubscription: return ValidatedSubscription.from_json(_v))
		return _message


	func _init(p_validated_subscriptions: Array = [], p_cursor: String = "",
			p_prev_cursor: String = "") -> void:
		validated_subscriptions = p_validated_subscriptions
		cursor = p_cursor
		prev_cursor = p_prev_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		if not prev_cursor.is_empty():
			_fields.append('"prev_cursor":' + JSON.stringify(prev_cursor))
		_fields.append('"validated_subscriptions":[%s]' % ",".join(PackedStringArray(validated_subscriptions.map(func(_v: ValidatedSubscription) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Record values to write.
class WriteLeaderboardRecordRequestLeaderboardRecordWrite:
	extends RefCounted
	var score: int
	var subscore: int
	var metadata: String
	var operator: Operator


	static func from_json(_json: Variant) -> WriteLeaderboardRecordRequestLeaderboardRecordWrite:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := WriteLeaderboardRecordRequestLeaderboardRecordWrite.new()
		_message.score = type_convert(_data.get("score", 0), TYPE_INT)
		_message.subscore = type_convert(_data.get("subscore", 0), TYPE_INT)
		_message.metadata = _data.get("metadata", "")
		_message.operator = type_convert(_data.get("operator", 0), TYPE_INT)
		return _message


	func _init(p_score: int = 0, p_subscore: int = 0, p_metadata: String = "",
			p_operator: Operator = Operator.NO_OVERRIDE) -> void:
		score = p_score
		subscore = p_subscore
		metadata = p_metadata
		operator = p_operator


	func to_json() -> String:
		var _fields := PackedStringArray()
		if score != 0:
			_fields.append('"score":' + JSON.stringify(score))
		if subscore != 0:
			_fields.append('"subscore":' + JSON.stringify(subscore))
		if not metadata.is_empty():
			_fields.append('"metadata":' + JSON.stringify(metadata))
		if operator != 0:
			_fields.append('"operator":' + JSON.stringify(operator))
		return "{%s}" % ",".join(_fields)


## A request to submit a score to a leaderboard.
class WriteLeaderboardRecordRequest:
	extends RefCounted
	var leaderboard_id: String
	var record: WriteLeaderboardRecordRequestLeaderboardRecordWrite


	static func from_json(_json: Variant) -> WriteLeaderboardRecordRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := WriteLeaderboardRecordRequest.new()
		_message.leaderboard_id = _data.get("leaderboard_id", "")
		_message.record = WriteLeaderboardRecordRequestLeaderboardRecordWrite.from_json(_data["record"]) if _data.get("record") != null else null
		return _message


	func _init(p_leaderboard_id: String = "",
			p_record: WriteLeaderboardRecordRequestLeaderboardRecordWrite = null) -> void:
		leaderboard_id = p_leaderboard_id
		record = p_record


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not leaderboard_id.is_empty():
			_fields.append('"leaderboard_id":' + JSON.stringify(leaderboard_id))
		if record != null:
			_fields.append('"record":' + record.to_json())
		return "{%s}" % ",".join(_fields)


## The object to store.
class WriteStorageObject:
	extends RefCounted
	var collection: String
	var key: String
	var value: String
	var version: String
	## int, or null when unset.
	var permission_read: Variant
	## int, or null when unset.
	var permission_write: Variant


	static func from_json(_json: Variant) -> WriteStorageObject:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := WriteStorageObject.new()
		_message.collection = _data.get("collection", "")
		_message.key = _data.get("key", "")
		_message.value = _data.get("value", "")
		_message.version = _data.get("version", "")
		_message.permission_read = type_convert(_data["permission_read"], TYPE_INT) if _data.get("permission_read") != null else null
		_message.permission_write = type_convert(_data["permission_write"], TYPE_INT) if _data.get("permission_write") != null else null
		return _message


	func _init(p_collection: String = "", p_key: String = "", p_value: Variant = "",
			p_version: String = "", p_permission_read: Variant = null,
			p_permission_write: Variant = null) -> void:
		collection = p_collection
		key = p_key
		value = p_value if p_value is String else JSON.stringify(p_value)
		version = p_version
		permission_read = p_permission_read
		permission_write = p_permission_write


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not collection.is_empty():
			_fields.append('"collection":' + JSON.stringify(collection))
		if not key.is_empty():
			_fields.append('"key":' + JSON.stringify(key))
		if not value.is_empty():
			_fields.append('"value":' + JSON.stringify(value))
		if not version.is_empty():
			_fields.append('"version":' + JSON.stringify(version))
		if permission_read != null:
			_fields.append('"permission_read":' + JSON.stringify(permission_read))
		if permission_write != null:
			_fields.append('"permission_write":' + JSON.stringify(permission_write))
		return "{%s}" % ",".join(_fields)


## Write objects to the storage engine.
class WriteStorageObjectsRequest:
	extends RefCounted
	var objects: Array = []


	static func from_json(_json: Variant) -> WriteStorageObjectsRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := WriteStorageObjectsRequest.new()
		var _list_objects: Array = _data.get("objects", [])
		_message.objects = _list_objects.map(func(_v: Variant) -> WriteStorageObject: return WriteStorageObject.from_json(_v))
		return _message


	func _init(p_objects: Array = []) -> void:
		objects = p_objects


	func to_json() -> String:
		var _fields := PackedStringArray()
		_fields.append('"objects":[%s]' % ",".join(PackedStringArray(objects.map(func(_v: WriteStorageObject) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)


## Record values to write.
class WriteTournamentRecordRequestTournamentRecordWrite:
	extends RefCounted
	var score: int
	var subscore: int
	var metadata: String
	var operator: Operator


	static func from_json(_json: Variant) -> WriteTournamentRecordRequestTournamentRecordWrite:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := WriteTournamentRecordRequestTournamentRecordWrite.new()
		_message.score = type_convert(_data.get("score", 0), TYPE_INT)
		_message.subscore = type_convert(_data.get("subscore", 0), TYPE_INT)
		_message.metadata = _data.get("metadata", "")
		_message.operator = type_convert(_data.get("operator", 0), TYPE_INT)
		return _message


	func _init(p_score: int = 0, p_subscore: int = 0, p_metadata: String = "",
			p_operator: Operator = Operator.NO_OVERRIDE) -> void:
		score = p_score
		subscore = p_subscore
		metadata = p_metadata
		operator = p_operator


	func to_json() -> String:
		var _fields := PackedStringArray()
		if score != 0:
			_fields.append('"score":' + JSON.stringify(score))
		if subscore != 0:
			_fields.append('"subscore":' + JSON.stringify(subscore))
		if not metadata.is_empty():
			_fields.append('"metadata":' + JSON.stringify(metadata))
		if operator != 0:
			_fields.append('"operator":' + JSON.stringify(operator))
		return "{%s}" % ",".join(_fields)


## A request to submit a score to a tournament.
class WriteTournamentRecordRequest:
	extends RefCounted
	var tournament_id: String
	var record: WriteTournamentRecordRequestTournamentRecordWrite


	static func from_json(_json: Variant) -> WriteTournamentRecordRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := WriteTournamentRecordRequest.new()
		_message.tournament_id = _data.get("tournament_id", "")
		_message.record = WriteTournamentRecordRequestTournamentRecordWrite.from_json(_data["record"]) if _data.get("record") != null else null
		return _message


	func _init(p_tournament_id: String = "",
			p_record: WriteTournamentRecordRequestTournamentRecordWrite = null) -> void:
		tournament_id = p_tournament_id
		record = p_record


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not tournament_id.is_empty():
			_fields.append('"tournament_id":' + JSON.stringify(tournament_id))
		if record != null:
			_fields.append('"record":' + record.to_json())
		return "{%s}" % ",".join(_fields)


## A request to list parties.
class ListPartiesRequest:
	extends RefCounted
	## int, or null when unset.
	var limit: Variant
	## bool, or null when unset.
	var open: Variant
	## String, or null when unset.
	var query: Variant
	## String, or null when unset.
	var cursor: Variant


	static func from_json(_json: Variant) -> ListPartiesRequest:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := ListPartiesRequest.new()
		_message.limit = type_convert(_data["limit"], TYPE_INT) if _data.get("limit") != null else null
		_message.open = _data["open"] if _data.get("open") != null else null
		_message.query = _data["query"] if _data.get("query") != null else null
		_message.cursor = _data["cursor"] if _data.get("cursor") != null else null
		return _message


	func _init(p_limit: Variant = null, p_open: Variant = null, p_query: Variant = null,
			p_cursor: Variant = null) -> void:
		limit = p_limit
		open = p_open
		query = p_query
		cursor = p_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if limit != null:
			_fields.append('"limit":' + JSON.stringify(limit))
		if open != null:
			_fields.append('"open":' + JSON.stringify(open))
		if query != null:
			_fields.append('"query":' + JSON.stringify(query))
		if cursor != null:
			_fields.append('"cursor":' + JSON.stringify(cursor))
		return "{%s}" % ",".join(_fields)


## Incoming information about a party.
class Party:
	extends RefCounted
	var party_id: String
	var open: bool
	var hidden: bool
	var max_size: int
	var label: String


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
		_message.label = _data.get("label", "")
		return _message


	func _init(p_party_id: String = "", p_open: bool = false, p_hidden: bool = false,
			p_max_size: int = 0, p_label: String = "") -> void:
		party_id = p_party_id
		open = p_open
		hidden = p_hidden
		max_size = p_max_size
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
		if not label.is_empty():
			_fields.append('"label":' + JSON.stringify(label))
		return "{%s}" % ",".join(_fields)


## A list of realtime matches.
class PartyList:
	extends RefCounted
	var cursor: String
	var parties: Array = []


	static func from_json(_json: Variant) -> PartyList:
		var _parsed: Variant = _json
		if _json is String:
			var _parser := JSON.new()
			var _text: String = _json
			_parsed = _parser.data if _parser.parse(_text) == OK else null
		if not _parsed is Dictionary:
			return null
		var _data: Dictionary = _parsed
		var _message := PartyList.new()
		_message.cursor = _data.get("cursor", "")
		var _list_parties: Array = _data.get("parties", [])
		_message.parties = _list_parties.map(func(_v: Variant) -> Party: return Party.from_json(_v))
		return _message


	func _init(p_parties: Array = [], p_cursor: String = "") -> void:
		parties = p_parties
		cursor = p_cursor


	func to_json() -> String:
		var _fields := PackedStringArray()
		if not cursor.is_empty():
			_fields.append('"cursor":' + JSON.stringify(cursor))
		_fields.append('"parties":[%s]' % ",".join(PackedStringArray(parties.map(func(_v: Party) -> String: return _v.to_json()))))
		return "{%s}" % ",".join(_fields)

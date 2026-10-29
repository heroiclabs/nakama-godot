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

class_name NakamaSession
extends RefCounted
## A player's authenticated session, decoded from the tokens Nakama returns.

## True if the account was just created by the authenticate call; false for restored or refreshed sessions.
var created: bool
var token: String
var refresh_token: String
var user_id: String
var username: String
var vars: Dictionary
## Unix seconds when token was issued; 0 if the token does not say.
var create_time: int
## Unix seconds when token expires.
var expire_time: int
## Unix seconds when refresh_token expires.
var refresh_expire_time: int


static func from_json(json: Variant) -> NakamaSession:
	var parsed: Variant = JSON.parse_string(str(json)) if json is String else json
	var data: Dictionary = parsed
	var new_token: String = data.get("token", "")
	var new_refresh_token: String = data.get("refresh_token", "")
	var just_created: bool = data.get("created", false)
	return NakamaSession.new(new_token, new_refresh_token, just_created)


## A session from tokens saved earlier, e.g. to log back in without asking the player again. An expired
## token is fine while refresh_token is not: the client refreshes it on the next call.
static func restore(p_token: String, p_refresh_token: String = "") -> NakamaSession:
	return NakamaSession.new(p_token, p_refresh_token)


## The payload of a JWT; signatures are checked by the server, not here.
static func _claims(jwt: String) -> Dictionary:
	var parts := jwt.split(".")
	if parts.size() != 3:
		return {}
	var payload := parts[1].replace("-", "+").replace("_", "/")
	payload += "=".repeat((4 - payload.length() % 4) % 4)
	var claims: Variant = JSON.parse_string(Marshalls.base64_to_utf8(payload))
	return claims if claims is Dictionary else {}


func _init(p_token: String = "", p_refresh_token: String = "", p_created: bool = false) -> void:
	created = p_created
	update(p_token, p_refresh_token)


## Replaces the tokens, as after a refresh, and decodes their claims.
func update(p_token: String, p_refresh_token: String) -> void:
	token = p_token
	var claims := _claims(token)
	create_time = type_convert(claims.get("iat", 0), TYPE_INT)
	expire_time = type_convert(claims.get("exp", 0), TYPE_INT)
	user_id = claims.get("uid", "")
	username = claims.get("usn", "")
	vars = claims.get("vrs", {})
	if p_refresh_token != "":
		refresh_token = p_refresh_token
		refresh_expire_time = type_convert(_claims(refresh_token).get("exp", 0), TYPE_INT)


## True if token expires within offset_sec seconds from now.
func has_expired(offset_sec: int = 0) -> bool:
	return expire_time <= Time.get_unix_time_from_system() + offset_sec


## True if refresh_token expires within offset_sec seconds from now.
func has_refresh_expired(offset_sec: int = 0) -> bool:
	return refresh_expire_time <= Time.get_unix_time_from_system() + offset_sec

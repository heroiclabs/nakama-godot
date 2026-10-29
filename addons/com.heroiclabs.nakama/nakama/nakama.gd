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

class_name Nakama
extends RefCounted
## Nakama's HTTP API: a function per server call, plus auth, session refresh, retries, and timeouts.

## Emitted after a session's tokens are renewed in place, e.g. to save the new ones.
signal session_refreshed(session: NakamaSession)

enum LogLevel { NONE, ERROR, WARNING, INFO, DEBUG }

## Refresh within this many seconds of expiry, or half the token lifetime if shorter.
const REFRESH_MARGIN_SEC := 300
const TRANSIENT_CODES := [500, 502, 503, 504]

var auto_refresh_session: bool
## Retries on transient errors, exponential backoff with full jitter.
var retry_base_delay_ms := 500
var retry_max_attempts := 4
## Cap on a single retry wait, before jitter. 0: no cap.
var retry_max_delay_ms := 10_000
## 0: no total limit.
var retry_max_total_ms := 60_000
## Seconds per request, connecting included.
var timeout_sec := 10
var log_level := LogLevel.WARNING
var scheme: String
var host: String
var port: int
var _server_key: String
## Sessions being refreshed, so concurrent calls share one refresh.
var _refreshing: Dictionary


## A Timestamp field's value, e.g. for NakamaTypes.Event.timestamp: unix_time in RFC 3339 UTC with the Z
## the server requires.
static func timestamp(unix_time: float = Time.get_unix_time_from_system()) -> String:
	return Time.get_datetime_string_from_unix_time(int(unix_time)) + ".%06dZ" % int(fmod(unix_time, 1.0) * 1_000_000)


## A new random device ID for authenticate_device_async. The ID is the player's account, so save it, e.g.
## with the session, and reuse it: authenticating with a new one makes a new account.
static func generate_device_id() -> String:
	var hex := Crypto.new().generate_random_bytes(16).hex_encode()
	return "%s-%s-%s-%s-%s" % [hex.substr(0, 8), hex.substr(8, 4), hex.substr(12, 4), hex.substr(16, 4), hex.substr(20)]


static func _rpc_request(id: String, payload: Variant,
		http_key: String) -> NakamaAPI.ApiRequestModel:
	var request := NakamaTypes.Rpc.new(id)
	match typeof(payload):
		TYPE_STRING:
			request.payload = payload
		TYPE_PACKED_BYTE_ARRAY:
			var bytes: PackedByteArray = payload
			request.payload = bytes.get_string_from_utf8()
		_:
			request.payload = JSON.stringify(payload)
	request.http_key = http_key
	var request_model := NakamaAPI.rpc_func(request)
	if http_key == "":
		request_model.url = request_model.url.get_slice("?", 0)
	return request_model


## Awaits done; if canceller cancels first, runs on_cancel, which must emit done so the wait ends.
static func _until(done: Signal, canceller: NakamaCanceller, on_cancel: Callable) -> Variant:
	if canceller == null:
		return await done
	canceller.cancelled.connect(on_cancel)
	if canceller.is_cancelled:
		on_cancel.call_deferred()
	var value: Variant = await done
	canceller.cancelled.disconnect(on_cancel)
	return value


func _init(p_server_key: String, p_host: String = "127.0.0.1", p_port: int = 7350,
		p_scheme: String = "http", p_timeout_sec: int = 10,
		p_auto_refresh_session: bool = true) -> void:
	_server_key = p_server_key
	host = p_host
	port = p_port
	scheme = p_scheme
	timeout_sec = p_timeout_sec
	auto_refresh_session = p_auto_refresh_session


## Add friends by ID or username to a user's account.
func add_friends_async(session: NakamaSession, metadata: String = "", ids: Array[String] = [],
		usernames: Array[String] = [], canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.add_friends(metadata, ids, usernames)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Add users to a group.
func add_group_users_async(session: NakamaSession, group_id: String, user_ids: Array[String],
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.add_group_users(group_id, user_ids)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Authenticate a user with an Apple ID against the server.
func authenticate_apple_async(token: String, username: String = "", create: bool = true,
		vars: Dictionary = {}, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AuthenticateAppleRequest.new(
			NakamaTypes.AccountApple.new(token, vars), create, username)
	var request_model := NakamaAPI.authenticate_apple(request)
	var result: NakamaResult = await _send(request_model, canceller)
	if result.error == null:
		result.value = NakamaSession.from_json(result.value)
	return result


## Authenticate a user with a runtime-registered provider against the server.
func authenticate_async(provider: String, payload: Dictionary = {}, username: String = "",
		create: bool = true, vars: Dictionary = {},
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AuthenticateRequest.new(
			NakamaTypes.AccountProvider.new(provider, payload, vars), create, username)
	var request_model := NakamaAPI.authenticate(request)
	var result: NakamaResult = await _send(request_model, canceller)
	if result.error == null:
		result.value = NakamaSession.from_json(result.value)
	return result


## Authenticate a user with a custom ID against the server.
func authenticate_custom_async(id: String, username: String = "", create: bool = true,
		vars: Dictionary = {}, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AuthenticateCustomRequest.new(
			NakamaTypes.AccountCustom.new(id, vars), create, username)
	var request_model := NakamaAPI.authenticate_custom(request)
	var result: NakamaResult = await _send(request_model, canceller)
	if result.error == null:
		result.value = NakamaSession.from_json(result.value)
	return result


## Authenticate a user with a device ID against the server.
func authenticate_device_async(id: String, username: String = "", create: bool = true,
		vars: Dictionary = {}, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AuthenticateDeviceRequest.new(
			NakamaTypes.AccountDevice.new(id, vars), create, username)
	var request_model := NakamaAPI.authenticate_device(request)
	var result: NakamaResult = await _send(request_model, canceller)
	if result.error == null:
		result.value = NakamaSession.from_json(result.value)
	return result


## Authenticate a user with an email+password against the server.
func authenticate_email_async(email: String, password: String, username: String = "",
		create: bool = true, vars: Dictionary = {},
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AuthenticateEmailRequest.new(
			NakamaTypes.AccountEmail.new(email, password, vars), create, username)
	var request_model := NakamaAPI.authenticate_email(request)
	var result: NakamaResult = await _send(request_model, canceller)
	if result.error == null:
		result.value = NakamaSession.from_json(result.value)
	return result


## Authenticate a user with a Facebook OAuth token against the server.
func authenticate_facebook_async(token: String, username: String = "", create: bool = true,
		sync: Variant = null, vars: Dictionary = {},
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AuthenticateFacebookRequest.new(
			NakamaTypes.AccountFacebook.new(token, vars), create, username, sync)
	var request_model := NakamaAPI.authenticate_facebook(request)
	var result: NakamaResult = await _send(request_model, canceller)
	if result.error == null:
		result.value = NakamaSession.from_json(result.value)
	return result


## Authenticate a user with a Facebook Instant Game token against the server.
func authenticate_facebook_instant_game_async(signed_player_info: String, username: String = "",
		create: bool = true, vars: Dictionary = {},
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AuthenticateFacebookInstantGameRequest.new(
			NakamaTypes.AccountFacebookInstantGame.new(signed_player_info, vars), create, username)
	var request_model := NakamaAPI.authenticate_facebook_instant_game(request)
	var result: NakamaResult = await _send(request_model, canceller)
	if result.error == null:
		result.value = NakamaSession.from_json(result.value)
	return result


## Authenticate a user with Apple's Game Center against the server.
func authenticate_game_center_async(player_id: String, bundle_id: String, timestamp_seconds: int,
		salt: String, signature: String, public_key_url: String, username: String = "",
		create: bool = true, vars: Dictionary = {},
		canceller: NakamaCanceller = null) -> NakamaResult:
	var account := NakamaTypes.AccountGameCenter.new(player_id, bundle_id, timestamp_seconds, salt,
			signature, public_key_url, vars)
	var request := NakamaTypes.AuthenticateGameCenterRequest.new(account, create, username)
	var request_model := NakamaAPI.authenticate_game_center(request)
	var result: NakamaResult = await _send(request_model, canceller)
	if result.error == null:
		result.value = NakamaSession.from_json(result.value)
	return result


## Authenticate a user with Google against the server.
func authenticate_google_async(token: String, username: String = "", create: bool = true,
		vars: Dictionary = {}, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AuthenticateGoogleRequest.new(
			NakamaTypes.AccountGoogle.new(token, vars), create, username)
	var request_model := NakamaAPI.authenticate_google(request)
	var result: NakamaResult = await _send(request_model, canceller)
	if result.error == null:
		result.value = NakamaSession.from_json(result.value)
	return result


## Authenticate a user with Steam against the server.
func authenticate_steam_async(token: String, username: String = "", create: bool = true,
		sync: Variant = null, vars: Dictionary = {},
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AuthenticateSteamRequest.new(
			NakamaTypes.AccountSteam.new(token, vars), create, username, sync)
	var request_model := NakamaAPI.authenticate_steam(request)
	var result: NakamaResult = await _send(request_model, canceller)
	if result.error == null:
		result.value = NakamaSession.from_json(result.value)
	return result


## Ban a set of users from a group.
func ban_group_users_async(session: NakamaSession, group_id: String, user_ids: Array[String],
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.ban_group_users(group_id, user_ids)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Block one or more users by ID or username.
func block_friends_async(session: NakamaSession, ids: Array[String] = [],
		usernames: Array[String] = [], canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.block_friends(ids, usernames)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Create a new group with the current user as the owner.
func create_group_async(session: NakamaSession, name: String, description: String = "",
		lang_tag: String = "", avatar_url: String = "", open: bool = true, max_count: int = 0,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.CreateGroupRequest.new(name, description, lang_tag, avatar_url, open,
			max_count)
	var request_model := NakamaAPI.create_group(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.Group.from_json(result.value)
	return result


## Delete the current user's account.
func delete_account_async(session: NakamaSession,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.delete_account()
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Delete one or more friends by ID or username.
func delete_friends_async(session: NakamaSession, ids: Array[String] = [],
		usernames: Array[String] = [], canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.delete_friends(ids, usernames)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Delete a group by ID.
func delete_group_async(session: NakamaSession, group_id: String,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.delete_group(group_id)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Delete a leaderboard record.
func delete_leaderboard_record_async(session: NakamaSession, leaderboard_id: String,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.delete_leaderboard_record(leaderboard_id)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Delete one or more notifications for the current user.
func delete_notifications_async(session: NakamaSession, ids: Array[String],
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.delete_notifications(ids)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Delete one or more storage objects.
func delete_storage_objects_async(session: NakamaSession,
		object_ids: Array[NakamaTypes.DeleteStorageObjectId],
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.DeleteStorageObjectsRequest.new(object_ids)
	var request_model := NakamaAPI.delete_storage_objects(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Delete a tournament record.
func delete_tournament_record_async(session: NakamaSession, tournament_id: String,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.delete_tournament_record(tournament_id)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Demote a set of users in a group to the next role down.
func demote_group_users_async(session: NakamaSession, group_id: String, user_ids: Array[String],
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.demote_group_users(group_id, user_ids)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Submit an event for processing in the server's registered runtime custom events handler.
func event_async(session: NakamaSession, name: String,
		event_time: String = Time.get_datetime_string_from_system(true) + "Z",
		external: bool = false, properties: Dictionary = {},
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.Event.new(name, properties, event_time, external)
	var request_model := NakamaAPI.event(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Fetch the current user's account.
func get_account_async(session: NakamaSession, canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.get_account()
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.Account.from_json(result.value)
	return result


## Get matchmaker stats.
func get_matchmaker_stats_async(session: NakamaSession,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.get_matchmaker_stats()
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.MatchmakerStats.from_json(result.value)
	return result


## Get a subscription by product ID.
func get_subscription_async(session: NakamaSession, product_id: String,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.get_subscription(product_id)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.ValidatedSubscription.from_json(result.value)
	return result


## Fetch zero or more users by ID, username and/or Facebook ID.
func get_users_async(session: NakamaSession, ids: Array[String] = [], usernames: Array[String] = [],
		facebook_ids: Array[String] = [], canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.get_users(ids, usernames, facebook_ids)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.Users.from_json(result.value)
	return result


## A healthcheck which load balancers can use to check the service.
func healthcheck_async(session: NakamaSession, canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.healthcheck()
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Import Facebook friends and add them to a user's account.
func import_facebook_friends_async(session: NakamaSession, token: String, reset: Variant = null,
		vars: Dictionary = {}, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.ImportFacebookFriendsRequest.new(
			NakamaTypes.AccountFacebook.new(token, vars), reset)
	var request_model := NakamaAPI.import_facebook_friends(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Import Steam friends and add them to a user's account.
func import_steam_friends_async(session: NakamaSession, token: String, reset: Variant = null,
		vars: Dictionary = {}, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.ImportSteamFriendsRequest.new(
			NakamaTypes.AccountSteam.new(token, vars), reset)
	var request_model := NakamaAPI.import_steam_friends(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Immediately join an open group, or request to join a closed one.
func join_group_async(session: NakamaSession, group_id: String,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.join_group(group_id)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Attempt to join an open and running tournament.
func join_tournament_async(session: NakamaSession, tournament_id: String,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.join_tournament(tournament_id)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Kick a set of users from a group.
func kick_group_users_async(session: NakamaSession, group_id: String, user_ids: Array[String],
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.kick_group_users(group_id, user_ids)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Leave a group the user is a member of.
func leave_group_async(session: NakamaSession, group_id: String,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.leave_group(group_id)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Add an Apple ID to the social profiles on the current user's account.
func link_apple_async(session: NakamaSession, token: String, vars: Dictionary = {},
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AccountApple.new(token, vars)
	var request_model := NakamaAPI.link_apple(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Add an authentication provider identity to the current user's account.
func link_async(session: NakamaSession, provider: String, payload: Dictionary = {},
		vars: Dictionary = {}, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AccountProvider.new(provider, payload, vars)
	var request_model := NakamaAPI.link(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Add a custom ID to the social profiles on the current user's account.
func link_custom_async(session: NakamaSession, id: String, vars: Dictionary = {},
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AccountCustom.new(id, vars)
	var request_model := NakamaAPI.link_custom(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Add a device ID to the social profiles on the current user's account.
func link_device_async(session: NakamaSession, id: String, vars: Dictionary = {},
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AccountDevice.new(id, vars)
	var request_model := NakamaAPI.link_device(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Add an email+password to the social profiles on the current user's account.
func link_email_async(session: NakamaSession, email: String, password: String,
		vars: Dictionary = {}, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AccountEmail.new(email, password, vars)
	var request_model := NakamaAPI.link_email(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Add Facebook to the social profiles on the current user's account.
func link_facebook_async(session: NakamaSession, token: String, sync: Variant = null,
		vars: Dictionary = {}, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.LinkFacebookRequest.new(NakamaTypes.AccountFacebook.new(token, vars),
			sync)
	var request_model := NakamaAPI.link_facebook(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Add a Facebook Instant Game profile to the social profiles on the current user's account.
func link_facebook_instant_game_async(session: NakamaSession, signed_player_info: String,
		vars: Dictionary = {}, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AccountFacebookInstantGame.new(signed_player_info, vars)
	var request_model := NakamaAPI.link_facebook_instant_game(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Add Apple's Game Center to the social profiles on the current user's account.
func link_game_center_async(session: NakamaSession, player_id: String, bundle_id: String,
		timestamp_seconds: int, salt: String, signature: String, public_key_url: String,
		vars: Dictionary = {}, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AccountGameCenter.new(player_id, bundle_id, timestamp_seconds, salt,
			signature, public_key_url, vars)
	var request_model := NakamaAPI.link_game_center(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Add Google to the social profiles on the current user's account.
func link_google_async(session: NakamaSession, token: String, vars: Dictionary = {},
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AccountGoogle.new(token, vars)
	var request_model := NakamaAPI.link_google(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Add Steam to the social profiles on the current user's account.
func link_steam_async(session: NakamaSession, token: String, sync: Variant = null,
		vars: Dictionary = {}, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.LinkSteamRequest.new(NakamaTypes.AccountSteam.new(token, vars), sync)
	var request_model := NakamaAPI.link_steam(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## List a channel's message history.
func list_channel_messages_async(session: NakamaSession, channel_id: String, cursor: String = "",
		limit: Variant = null, forward: bool = true,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.list_channel_messages(channel_id, cursor, limit, forward)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.ChannelMessageList.from_json(result.value)
	return result


## List all friends for the current user.
func list_friends_async(session: NakamaSession, cursor: String = "", limit: Variant = null,
		state: Variant = null, canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.list_friends(cursor, limit, state)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.FriendList.from_json(result.value)
	return result


## List friends of friends for the current user.
func list_friends_of_friends_async(session: NakamaSession, cursor: String = "",
		limit: Variant = null, canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.list_friends_of_friends(cursor, limit)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.FriendsOfFriendsList.from_json(result.value)
	return result


## List all users that are part of a group.
func list_group_users_async(session: NakamaSession, group_id: String, cursor: String = "",
		limit: Variant = null, state: Variant = null,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.list_group_users(group_id, cursor, limit, state)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.GroupUserList.from_json(result.value)
	return result


## List groups based on given filters.
func list_groups_async(session: NakamaSession, name: String = "", cursor: String = "",
		lang_tag: String = "", limit: Variant = null, members: Variant = null, open: Variant = null,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.list_groups(name, cursor, lang_tag, limit, members, open)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.GroupList.from_json(result.value)
	return result


## List leaderboard records around the target owner_id.
func list_leaderboard_records_around_owner_async(session: NakamaSession, leaderboard_id: String,
		owner_id: String, cursor: String = "", limit: Variant = null, expiry: Variant = null,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.list_leaderboard_records_around_owner(leaderboard_id, owner_id,
			cursor, limit, expiry)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.LeaderboardRecordList.from_json(result.value)
	return result


## List leaderboard records.
func list_leaderboard_records_async(session: NakamaSession, leaderboard_id: String,
		cursor: String = "", owner_ids: Array[String] = [], limit: Variant = null,
		expiry: Variant = null, canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.list_leaderboard_records(leaderboard_id, cursor, owner_ids,
			limit, expiry)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.LeaderboardRecordList.from_json(result.value)
	return result


## List running matches and optionally filter by matching criteria.
func list_matches_async(session: NakamaSession, limit: Variant = null,
		authoritative: Variant = null, label: Variant = null, min_size: Variant = null,
		max_size: Variant = null, query: Variant = null,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.list_matches(limit, authoritative, label, min_size, max_size,
			query)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.MatchList.from_json(result.value)
	return result


## Fetch a list of notifications.
func list_notifications_async(session: NakamaSession, cacheable_cursor: String = "",
		limit: Variant = null, canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.list_notifications(cacheable_cursor, limit)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.NotificationList.from_json(result.value)
	return result


## List parties and optionally filter by matching criteria.
func list_parties_async(session: NakamaSession, limit: Variant = null, open: Variant = null,
		query: Variant = null, cursor: Variant = null,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.list_parties(limit, open, query, cursor)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.PartyList.from_json(result.value)
	return result


## List publicly readable storage objects in a given collection.
func list_storage_objects_async(session: NakamaSession, collection: String, user_id: String = "",
		cursor: String = "", limit: Variant = null,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.list_storage_objects(user_id, collection, cursor, limit)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.StorageObjectList.from_json(result.value)
	return result


## List the current user's subscriptions.
func list_subscriptions_async(session: NakamaSession, cursor: String = "", limit: Variant = null,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.ListSubscriptionsRequest.new(limit, cursor)
	var request_model := NakamaAPI.list_subscriptions(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.SubscriptionList.from_json(result.value)
	return result


## List tournament records around the target owner_id.
func list_tournament_records_around_owner_async(session: NakamaSession, tournament_id: String,
		owner_id: String, cursor: String = "", limit: Variant = null, expiry: Variant = null,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.list_tournament_records_around_owner(tournament_id, owner_id,
			cursor, limit, expiry)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.TournamentRecordList.from_json(result.value)
	return result


## List tournament records.
func list_tournament_records_async(session: NakamaSession, tournament_id: String,
		cursor: String = "", owner_ids: Array[String] = [], limit: Variant = null,
		expiry: Variant = null, canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.list_tournament_records(tournament_id, cursor, owner_ids, limit,
			expiry)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.TournamentRecordList.from_json(result.value)
	return result


## List current or upcoming tournaments.
func list_tournaments_async(session: NakamaSession, cursor: String = "",
		category_start: Variant = null, category_end: Variant = null, start_time: Variant = null,
		end_time: Variant = null, limit: Variant = null,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.list_tournaments(cursor, category_start, category_end,
			start_time, end_time, limit)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.TournamentList.from_json(result.value)
	return result


## List groups a user belongs to.
func list_user_groups_async(session: NakamaSession, user_id: String = "", cursor: String = "",
		limit: Variant = null, state: Variant = null,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.list_user_groups(user_id, cursor, limit, state)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.UserGroupList.from_json(result.value)
	return result


## Promote a set of users in a group to the next role up.
func promote_group_users_async(session: NakamaSession, group_id: String, user_ids: Array[String],
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := NakamaAPI.promote_group_users(group_id, user_ids)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Get storage objects.
func read_storage_objects_async(session: NakamaSession,
		object_ids: Array[NakamaTypes.ReadStorageObjectId],
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.ReadStorageObjectsRequest.new(object_ids)
	var request_model := NakamaAPI.read_storage_objects(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.StorageObjects.from_json(result.value)
	return result


## A String payload is sent as is, bytes as UTF-8 text, anything else as JSON; value is a NakamaTypes.Rpc
## whose payload is the reply.
func rpc_async(session: NakamaSession, id: String, payload: Variant = "",
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := _rpc_request(id, payload, "")
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.Rpc.from_json(result.value)
	return result


## Like rpc_async with the server's runtime HTTP key instead of a session, e.g. for server
## tools. Never ship the HTTP key in a game client.
func rpc_with_key_async(http_key: String, id: String, payload: Variant = "",
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request_model := _rpc_request(id, payload, http_key)
	var result: NakamaResult = await _send_with_retry(request_model, "", canceller)
	if result.error == null:
		result.value = NakamaTypes.Rpc.from_json(result.value)
	return result


func session_logout_async(session: NakamaSession,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.SessionLogoutRequest.new(session.token, session.refresh_token)
	var request_model := NakamaAPI.session_logout(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Renews session's tokens in place and emits session_refreshed; a rejected refresh token is cleared.
func session_refresh_async(session: NakamaSession, vars: Dictionary = {},
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.SessionRefreshRequest.new(session.refresh_token, vars)
	var request_model := NakamaAPI.session_refresh(request)
	return _refreshed(session, await _send(request_model, canceller))


## Remove the Apple ID from the social profiles on the current user's account.
func unlink_apple_async(session: NakamaSession, token: String, vars: Dictionary = {},
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AccountApple.new(token, vars)
	var request_model := NakamaAPI.unlink_apple(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Remove an authentication provider identity from the current user's account.
func unlink_async(session: NakamaSession, provider: String, payload: Dictionary = {},
		vars: Dictionary = {}, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AccountProvider.new(provider, payload, vars)
	var request_model := NakamaAPI.unlink(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Remove the custom ID from the social profiles on the current user's account.
func unlink_custom_async(session: NakamaSession, id: String, vars: Dictionary = {},
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AccountCustom.new(id, vars)
	var request_model := NakamaAPI.unlink_custom(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Remove the device ID from the social profiles on the current user's account.
func unlink_device_async(session: NakamaSession, id: String, vars: Dictionary = {},
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AccountDevice.new(id, vars)
	var request_model := NakamaAPI.unlink_device(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Remove the email+password from the social profiles on the current user's account.
func unlink_email_async(session: NakamaSession, email: String, password: String,
		vars: Dictionary = {}, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AccountEmail.new(email, password, vars)
	var request_model := NakamaAPI.unlink_email(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Remove Facebook from the social profiles on the current user's account.
func unlink_facebook_async(session: NakamaSession, token: String, vars: Dictionary = {},
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AccountFacebook.new(token, vars)
	var request_model := NakamaAPI.unlink_facebook(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Remove the Facebook Instant Game profile from the social profiles on the current user's account.
func unlink_facebook_instant_game_async(session: NakamaSession, signed_player_info: String,
		vars: Dictionary = {}, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AccountFacebookInstantGame.new(signed_player_info, vars)
	var request_model := NakamaAPI.unlink_facebook_instant_game(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Remove Apple's Game Center from the social profiles on the current user's account.
func unlink_game_center_async(session: NakamaSession, player_id: String, bundle_id: String,
		timestamp_seconds: int, salt: String, signature: String, public_key_url: String,
		vars: Dictionary = {}, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AccountGameCenter.new(player_id, bundle_id, timestamp_seconds, salt,
			signature, public_key_url, vars)
	var request_model := NakamaAPI.unlink_game_center(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Remove Google from the social profiles on the current user's account.
func unlink_google_async(session: NakamaSession, token: String, vars: Dictionary = {},
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AccountGoogle.new(token, vars)
	var request_model := NakamaAPI.unlink_google(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Remove Steam from the social profiles on the current user's account.
func unlink_steam_async(session: NakamaSession, token: String, vars: Dictionary = {},
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.AccountSteam.new(token, vars)
	var request_model := NakamaAPI.unlink_steam(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Update fields in the current user's account.
func update_account_async(session: NakamaSession, username: Variant = null,
		display_name: Variant = null, avatar_url: Variant = null, lang_tag: Variant = null,
		location: Variant = null, timezone: Variant = null,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.UpdateAccountRequest.new(username, display_name, avatar_url,
			lang_tag, location, timezone)
	var request_model := NakamaAPI.update_account(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Update fields in a given group.
func update_group_async(session: NakamaSession, group_id: String, name: Variant = null,
		description: Variant = null, lang_tag: Variant = null, avatar_url: Variant = null,
		open: Variant = null, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.UpdateGroupRequest.new(group_id, name, description, lang_tag,
			avatar_url, open)
	var request_model := NakamaAPI.update_group(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	result.value = null
	return result


## Validate an Apple IAP receipt.
func validate_purchase_apple_async(session: NakamaSession, receipt: String, persist: Variant = null,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.ValidatePurchaseAppleRequest.new(receipt, persist)
	var request_model := NakamaAPI.validate_purchase_apple(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.ValidatePurchaseResponse.from_json(result.value)
	return result


## Validate a Facebook Instant Games IAP receipt.
func validate_purchase_facebook_instant_async(session: NakamaSession, signed_request: String,
		persist: Variant = null, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.ValidatePurchaseFacebookInstantRequest.new(signed_request, persist)
	var request_model := NakamaAPI.validate_purchase_facebook_instant(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.ValidatePurchaseResponse.from_json(result.value)
	return result


## Validate a Google IAP receipt.
func validate_purchase_google_async(session: NakamaSession, purchase: String,
		persist: Variant = null, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.ValidatePurchaseGoogleRequest.new(purchase, persist)
	var request_model := NakamaAPI.validate_purchase_google(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.ValidatePurchaseResponse.from_json(result.value)
	return result


## Validate a Huawei IAP receipt.
func validate_purchase_huawei_async(session: NakamaSession, purchase: String, signature: String,
		persist: Variant = null, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.ValidatePurchaseHuaweiRequest.new(purchase, signature, persist)
	var request_model := NakamaAPI.validate_purchase_huawei(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.ValidatePurchaseResponse.from_json(result.value)
	return result


## Validate a Samsung Galaxy Store IAP receipt.
func validate_purchase_samsung_async(session: NakamaSession, purchase_id: String,
		persist: Variant = null, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.ValidatePurchaseSamsungRequest.new(purchase_id, persist)
	var request_model := NakamaAPI.validate_purchase_samsung(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.ValidatePurchaseResponse.from_json(result.value)
	return result


## Validate an Apple subscription receipt.
func validate_subscription_apple_async(session: NakamaSession, receipt: String,
		persist: Variant = null, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.ValidateSubscriptionAppleRequest.new(receipt, persist)
	var request_model := NakamaAPI.validate_subscription_apple(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.ValidateSubscriptionResponse.from_json(result.value)
	return result


## Validate a Google subscription receipt.
func validate_subscription_google_async(session: NakamaSession, receipt: String,
		persist: Variant = null, canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.ValidateSubscriptionGoogleRequest.new(receipt, persist)
	var request_model := NakamaAPI.validate_subscription_google(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.ValidateSubscriptionResponse.from_json(result.value)
	return result


## Write a record to a leaderboard.
func write_leaderboard_record_async(session: NakamaSession, leaderboard_id: String, score: int,
		subscore: int = 0, metadata: String = "",
		operator: NakamaTypes.Operator = NakamaTypes.Operator.NO_OVERRIDE,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var record := NakamaTypes.WriteLeaderboardRecordRequestLeaderboardRecordWrite.new(score,
			subscore, metadata, operator)
	var request := NakamaTypes.WriteLeaderboardRecordRequest.new(leaderboard_id, record)
	var request_model := NakamaAPI.write_leaderboard_record(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.LeaderboardRecord.from_json(result.value)
	return result


## Write objects into the storage engine.
func write_storage_objects_async(session: NakamaSession,
		objects: Array[NakamaTypes.WriteStorageObject],
		canceller: NakamaCanceller = null) -> NakamaResult:
	var request := NakamaTypes.WriteStorageObjectsRequest.new(objects)
	var request_model := NakamaAPI.write_storage_objects(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.StorageObjectAcks.from_json(result.value)
	return result


## Write a record to a tournament.
func write_tournament_record_async(session: NakamaSession, tournament_id: String, score: int,
		subscore: int = 0, metadata: String = "",
		operator: NakamaTypes.Operator = NakamaTypes.Operator.NO_OVERRIDE,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var record := NakamaTypes.WriteTournamentRecordRequestTournamentRecordWrite.new(score,
			subscore, metadata, operator)
	var request := NakamaTypes.WriteTournamentRecordRequest.new(tournament_id, record)
	var request_model := NakamaAPI.write_tournament_record(request)
	var result: NakamaResult = await _send_with_session(session, request_model, canceller)
	if result.error == null:
		result.value = NakamaTypes.LeaderboardRecord.from_json(result.value)
	return result


func _log(level: LogLevel, message: String) -> void:
	if level > log_level:
		return
	match level:
		LogLevel.ERROR: push_error("Nakama: " + message)
		LogLevel.WARNING: push_warning("Nakama: " + message)
		_: print("Nakama: " + message)


## Sends a request built by NakamaAPI with the server key, as authenticate calls do.
func _send(request: NakamaAPI.ApiRequestModel, canceller: NakamaCanceller = null) -> NakamaResult:
	return await _send_with_retry(request, "Basic " + Marshalls.utf8_to_base64(_server_key + ":"), canceller)


## Sends with session's token, refreshing it first when near expiry.
func _send_with_session(session: NakamaSession, request: NakamaAPI.ApiRequestModel,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var can_refresh := session.refresh_token != "" and not session.has_refresh_expired()
	var margin_sec := mini(REFRESH_MARGIN_SEC, int((session.expire_time - session.create_time) / 2.0))
	var expires_soon := session.has_expired(margin_sec)
	if auto_refresh_session and can_refresh and expires_soon:
		await _refresh_session(session, canceller)
	return await _send_with_retry(request, "Bearer " + session.token, canceller)


## Value is the parsed JSON reply; error after retrying transient failures.
func _send_with_retry(request: NakamaAPI.ApiRequestModel, auth: String,
		canceller: NakamaCanceller = null) -> NakamaResult:
	var start := Time.get_ticks_msec()
	var retries := 0
	var what := "%s %s" % [request.verb, request.url.get_slice("?", 0)]
	while true:
		if canceller and canceller.is_cancelled:
			return NakamaResult.new(null, NakamaError.new(0, NakamaError.CANCELLED, "%s cancelled" % what))
		var response: Dictionary = await _request(request, auth, canceller)
		var code: int = response["code"]
		var text: String = response["text"]
		_log(LogLevel.DEBUG, "%s: %d" % [what, code])
		if code >= 200 and code < 300:
			if text == "":
				return NakamaResult.new({})
			var json := JSON.new()
			if json.parse(text) == OK and json.data is Dictionary:
				return NakamaResult.new(json.data)
			# Not from Nakama, e.g. a captive portal's login page.
			return NakamaResult.new(null, NakamaError.new(code, NakamaError.UNKNOWN, "%s %s: reply is not a JSON object: %s" % [
					request.verb, request.url.get_slice("?", 0), text.left(200)]))
		var error: NakamaError
		if code == 0:
			# Path only: the query can hold secrets such as the RPC http_key.
			var grpc_code: int = response["grpc_code"]
			error = NakamaError.new(0, grpc_code, "%s %s %s" % [request.verb, request.url.get_slice("?", 0), text])
		else:
			error = NakamaError.from_response(code, text)
		var backoff_ms := pow(2, retries) * retry_base_delay_ms
		if retry_max_delay_ms > 0:
			backoff_ms = minf(backoff_ms, retry_max_delay_ms)
		var delay_ms := int(backoff_ms * randf())
		if code not in TRANSIENT_CODES or retries >= retry_max_attempts or (retry_max_total_ms > 0 and Time.get_ticks_msec() - start + delay_ms >= retry_max_total_ms):
			_log(LogLevel.INFO, "%s failed: %s" % [what, error])
			return NakamaResult.new(null, error)
		retries += 1
		_log(LogLevel.WARNING, "%s failed with %d, retry %d in %d ms" % [what, code, retries, delay_ms])
		var timer: SceneTreeTimer = (Engine.get_main_loop() as SceneTree).create_timer(delay_ms / 1000.0)
		await _until(timer.timeout, canceller, func() -> void: timer.timeout.emit())
	return null


## Waits for session's refresh, starting it unless another call has. A canceller ends the wait, not the refresh,
## which other calls may share.
func _refresh_session(session: NakamaSession, canceller: NakamaCanceller) -> void:
	if not _refreshing.has(session):
		# No await: finishes on its own, for the calls that share it
		_run_refresh(session)
	while _refreshing.has(session) and not (canceller and canceller.is_cancelled):
		await (Engine.get_main_loop() as SceneTree).process_frame


func _run_refresh(session: NakamaSession) -> void:
	_refreshing[session] = true
	# On failure the call proceeds with the old token and gets UNAUTHENTICATED.
	var refreshed: NakamaResult = await session_refresh_async(session, session.vars)
	if refreshed.error != null:
		_log(LogLevel.WARNING, "session refresh failed: %s" % refreshed.error)
	_refreshing.erase(session)


## Applies a refresh reply to session: new tokens in place and session_refreshed, or, if the refresh token
## is rejected, clears it so auto refresh stops retrying it on every call.
func _refreshed(session: NakamaSession, result: NakamaResult) -> NakamaResult:
	if result.error == null:
		var new_session := NakamaSession.from_json(result.value)
		session.update(new_session.token, new_session.refresh_token)
		result.value = session
		session_refreshed.emit(session)
	elif result.error.grpc_code == NakamaError.UNAUTHENTICATED:
		session.refresh_token = ""
	return result


## {"code": HTTP status, or 0 plus "grpc_code" if no reply, "text": body or error}. One HTTPRequest per call.
func _request(request: NakamaAPI.ApiRequestModel, auth: String,
		canceller: NakamaCanceller = null) -> Dictionary:
	var http := HTTPRequest.new()
	http.timeout = timeout_sec
	# No threads: in Godot 4.7 a threaded request to a peer that stops replying spins its thread, and then a timeout
	# or cancel freezes the game waiting for it. https://github.com/godotengine/godot/pull/117749
	http.use_threads = false
	http.process_mode = Node.PROCESS_MODE_ALWAYS  # calls from a pause menu must still finish
	# Deferred: the root rejects children while setting up a scene, e.g. from _ready().
	(Engine.get_main_loop() as SceneTree).root.add_child.call_deferred(http)
	await http.ready
	var headers := PackedStringArray(["Content-Type: application/json", "Accept: application/json"])
	if auth != "":  # empty for rpc_with_key_async, whose key is in the query
		headers.append("Authorization: " + auth)
	# Godot sends no Content-Length for an empty body, and some proxies answer 411 Length Required.
	if request.body.is_empty() and request.verb in ["POST", "PUT", "PATCH"]:
		headers.append("Content-Length: 0")
	var methods := {
		"GET": HTTPClient.METHOD_GET,
		"POST": HTTPClient.METHOD_POST,
		"PUT": HTTPClient.METHOD_PUT,
		"PATCH": HTTPClient.METHOD_PATCH,
		"DELETE": HTTPClient.METHOD_DELETE,
	}
	var url := "%s://%s:%d%s" % [scheme, host, port, request.url]
	var method: HTTPClient.Method = methods[request.verb]
	var err := http.request(url, headers, method, request.body)
	if err != OK:
		http.queue_free()
		return {"code": 0, "grpc_code": NakamaError.UNAVAILABLE, "text": "failed to send: %s" % error_string(err)}
	# Result -1 marks a cancel; HTTPRequest has no result code of its own for one.
	var completed: Array = await _until(http.request_completed, canceller, func() -> void:
		http.cancel_request()
		http.request_completed.emit(-1, 0, PackedStringArray(), PackedByteArray()))
	http.queue_free()
	var result: int = completed[0]
	if result == -1:
		return {"code": 0, "grpc_code": NakamaError.CANCELLED, "text": "cancelled"}
	if result == HTTPRequest.RESULT_TIMEOUT:
		return {"code": 0, "grpc_code": NakamaError.DEADLINE_EXCEEDED, "text": "timed out after %d s" % timeout_sec}
	if result != HTTPRequest.RESULT_SUCCESS:
		return {"code": 0, "grpc_code": NakamaError.UNAVAILABLE, "text": "failed, HTTPRequest result %d" % result}
	var body: PackedByteArray = completed[3]
	return {"code": completed[1], "text": body.get_string_from_utf8()}

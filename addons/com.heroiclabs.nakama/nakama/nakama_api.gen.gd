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
class_name NakamaAPI
extends RefCounted


## Refresh a user's session using a refresh token retrieved from a previous authentication request.
static func session_refresh(request: NakamaTypes.SessionRefreshRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/session/refresh", {}, request.to_json())


## Authenticate a user with an Apple ID against the server.
static func authenticate_apple(request: NakamaTypes.AuthenticateAppleRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/authenticate/apple", {
		"create": request.create,
		"username": request.username,
	}, request.account.to_json())


## Authenticate a user with a custom ID against the server.
static func authenticate_custom(request: NakamaTypes.AuthenticateCustomRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/authenticate/custom", {
		"create": request.create,
		"username": request.username,
	}, request.account.to_json())


## Authenticate a user with a device ID against the server.
static func authenticate_device(request: NakamaTypes.AuthenticateDeviceRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/authenticate/device", {
		"create": request.create,
		"username": request.username,
	}, request.account.to_json())


## Authenticate a user with an email+password against the server.
static func authenticate_email(request: NakamaTypes.AuthenticateEmailRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/authenticate/email", {
		"create": request.create,
		"username": request.username,
	}, request.account.to_json())


## Authenticate a user with a Facebook OAuth token against the server.
static func authenticate_facebook(
		request: NakamaTypes.AuthenticateFacebookRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/authenticate/facebook", {
		"create": request.create,
		"username": request.username,
		"sync": request.sync,
	}, request.account.to_json())


## Authenticate a user with a Facebook Instant Game token against the server.
static func authenticate_facebook_instant_game(
		request: NakamaTypes.AuthenticateFacebookInstantGameRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/authenticate/facebookinstantgame", {
		"create": request.create,
		"username": request.username,
	}, request.account.to_json())


## Authenticate a user with Apple's Game Center against the server.
static func authenticate_game_center(
		request: NakamaTypes.AuthenticateGameCenterRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/authenticate/gamecenter", {
		"create": request.create,
		"username": request.username,
	}, request.account.to_json())


## Authenticate a user with Google against the server.
static func authenticate_google(request: NakamaTypes.AuthenticateGoogleRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/authenticate/google", {
		"create": request.create,
		"username": request.username,
	}, request.account.to_json())


## Authenticate a user with a runtime-registered provider against the server.
static func authenticate(request: NakamaTypes.AuthenticateRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/authenticate", {
		"create": request.create,
		"username": request.username,
	}, request.account.to_json())


## Authenticate a user with Steam against the server.
static func authenticate_steam(request: NakamaTypes.AuthenticateSteamRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/authenticate/steam", {
		"create": request.create,
		"username": request.username,
		"sync": request.sync,
	}, request.account.to_json())


## Create a new group with the current user as the owner.
static func create_group(request: NakamaTypes.CreateGroupRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/group", {}, request.to_json())


## Fetch zero or more users by ID, username and/or Facebook ID.
static func get_users(ids: Array[String] = [], usernames: Array[String] = [],
		facebook_ids: Array[String] = []) -> ApiRequestModel:
	return ApiRequestModel.new("GET", "/v2/user", {
		"ids": ids,
		"usernames": usernames,
		"facebook_ids": facebook_ids,
	})


## Get a subscription by product ID.
static func get_subscription(product_id: String = "") -> ApiRequestModel:
	var url := "/v2/iap/subscription/{product_id}"
	url = url.replace("{product_id}", str(product_id).uri_encode())
	return ApiRequestModel.new("GET", url)


## List a channel's message history.
static func list_channel_messages(channel_id: String = "", cursor: String = "",
		limit: Variant = null, forward: bool = true) -> ApiRequestModel:
	var url := "/v2/channel/{channel_id}"
	url = url.replace("{channel_id}", str(channel_id).uri_encode())
	return ApiRequestModel.new("GET", url, {
		"limit": limit,
		"forward": forward,
		"cursor": cursor,
	})


## List all friends for the current user.
static func list_friends(cursor: String = "", limit: Variant = null,
		state: Variant = null) -> ApiRequestModel:
	return ApiRequestModel.new("GET", "/v2/friend", {
		"limit": limit,
		"state": state,
		"cursor": cursor,
	})


## List friends of friends for the current user.
static func list_friends_of_friends(cursor: String = "", limit: Variant = null) -> ApiRequestModel:
	return ApiRequestModel.new("GET", "/v2/friend/friends", {
		"limit": limit,
		"cursor": cursor,
	})


## List groups based on given filters.
static func list_groups(name: String = "", cursor: String = "", lang_tag: String = "",
		limit: Variant = null, members: Variant = null, open: Variant = null) -> ApiRequestModel:
	return ApiRequestModel.new("GET", "/v2/group", {
		"name": name,
		"cursor": cursor,
		"limit": limit,
		"lang_tag": lang_tag,
		"members": members,
		"open": open,
	})


## List all users that are part of a group.
static func list_group_users(group_id: String = "", cursor: String = "", limit: Variant = null,
		state: Variant = null) -> ApiRequestModel:
	var url := "/v2/group/{group_id}/user"
	url = url.replace("{group_id}", str(group_id).uri_encode())
	return ApiRequestModel.new("GET", url, {
		"limit": limit,
		"state": state,
		"cursor": cursor,
	})


## List leaderboard records.
static func list_leaderboard_records(leaderboard_id: String = "", cursor: String = "",
		owner_ids: Array[String] = [], limit: Variant = null,
		expiry: Variant = null) -> ApiRequestModel:
	var url := "/v2/leaderboard/{leaderboard_id}"
	url = url.replace("{leaderboard_id}", str(leaderboard_id).uri_encode())
	return ApiRequestModel.new("GET", url, {
		"limit": limit,
		"cursor": cursor,
		"expiry": expiry,
		"owner_ids": owner_ids,
	})


## List leaderboard records around the target owner_id.
static func list_leaderboard_records_around_owner(leaderboard_id: String = "",
		owner_id: String = "", cursor: String = "", limit: Variant = null,
		expiry: Variant = null) -> ApiRequestModel:
	var url := "/v2/leaderboard/{leaderboard_id}/owner/{owner_id}"
	url = url.replace("{leaderboard_id}", str(leaderboard_id).uri_encode())
	url = url.replace("{owner_id}", str(owner_id).uri_encode())
	return ApiRequestModel.new("GET", url, {
		"limit": limit,
		"expiry": expiry,
		"cursor": cursor,
	})


## List running matches and optionally filter by matching criteria.
static func list_matches(limit: Variant = null, authoritative: Variant = null,
		label: Variant = null, min_size: Variant = null, max_size: Variant = null,
		query: Variant = null) -> ApiRequestModel:
	return ApiRequestModel.new("GET", "/v2/match", {
		"limit": limit,
		"authoritative": authoritative,
		"label": label,
		"min_size": min_size,
		"max_size": max_size,
		"query": query,
	})


## List parties and optionally filter by matching criteria.
static func list_parties(limit: Variant = null, open: Variant = null, query: Variant = null,
		cursor: Variant = null) -> ApiRequestModel:
	return ApiRequestModel.new("GET", "/v2/party", {
		"limit": limit,
		"open": open,
		"query": query,
		"cursor": cursor,
	})


## Fetch a list of notifications.
static func list_notifications(cacheable_cursor: String = "",
		limit: Variant = null) -> ApiRequestModel:
	return ApiRequestModel.new("GET", "/v2/notification", {
		"limit": limit,
		"cacheable_cursor": cacheable_cursor,
	})


## List publicly readable storage objects in a given collection.
static func list_storage_objects(user_id: String = "", collection: String = "", cursor: String = "",
		limit: Variant = null) -> ApiRequestModel:
	var url := "/v2/storage/{collection}"
	url = url.replace("{collection}", str(collection).uri_encode())
	return ApiRequestModel.new("GET", url, {
		"user_id": user_id,
		"limit": limit,
		"cursor": cursor,
	})


## List the current user's subscriptions.
static func list_subscriptions(request: NakamaTypes.ListSubscriptionsRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/iap/subscription", {}, request.to_json())


## List current or upcoming tournaments.
static func list_tournaments(cursor: String = "", category_start: Variant = null,
		category_end: Variant = null, start_time: Variant = null, end_time: Variant = null,
		limit: Variant = null) -> ApiRequestModel:
	return ApiRequestModel.new("GET", "/v2/tournament", {
		"category_start": category_start,
		"category_end": category_end,
		"start_time": start_time,
		"end_time": end_time,
		"limit": limit,
		"cursor": cursor,
	})


## List tournament records.
static func list_tournament_records(tournament_id: String = "", cursor: String = "",
		owner_ids: Array[String] = [], limit: Variant = null,
		expiry: Variant = null) -> ApiRequestModel:
	var url := "/v2/tournament/{tournament_id}"
	url = url.replace("{tournament_id}", str(tournament_id).uri_encode())
	return ApiRequestModel.new("GET", url, {
		"limit": limit,
		"cursor": cursor,
		"expiry": expiry,
		"owner_ids": owner_ids,
	})


## List tournament records around the target owner_id.
static func list_tournament_records_around_owner(tournament_id: String = "", owner_id: String = "",
		cursor: String = "", limit: Variant = null, expiry: Variant = null) -> ApiRequestModel:
	var url := "/v2/tournament/{tournament_id}/owner/{owner_id}"
	url = url.replace("{tournament_id}", str(tournament_id).uri_encode())
	url = url.replace("{owner_id}", str(owner_id).uri_encode())
	return ApiRequestModel.new("GET", url, {
		"limit": limit,
		"expiry": expiry,
		"cursor": cursor,
	})


## List groups a user belongs to.
static func list_user_groups(user_id: String = "", cursor: String = "", limit: Variant = null,
		state: Variant = null) -> ApiRequestModel:
	var url := "/v2/user/{user_id}/group"
	url = url.replace("{user_id}", str(user_id).uri_encode())
	return ApiRequestModel.new("GET", url, {
		"limit": limit,
		"state": state,
		"cursor": cursor,
	})


## Get storage objects.
static func read_storage_objects(request: NakamaTypes.ReadStorageObjectsRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/storage", {}, request.to_json())


## Execute an RPC function on the server.
static func rpc_func(request: NakamaTypes.Rpc) -> ApiRequestModel:
	var url := "/v2/rpc/{id}"
	url = url.replace("{id}", str(request.id).uri_encode())
	return ApiRequestModel.new("POST", url, {
		"http_key": request.http_key,
	}, JSON.stringify(request.payload))


## Validate an Apple IAP receipt.
static func validate_purchase_apple(
		request: NakamaTypes.ValidatePurchaseAppleRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/iap/purchase/apple", {}, request.to_json())


## Validate an Apple subscription receipt.
static func validate_subscription_apple(
		request: NakamaTypes.ValidateSubscriptionAppleRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/iap/subscription/apple", {}, request.to_json())


## Validate a Google IAP receipt.
static func validate_purchase_google(
		request: NakamaTypes.ValidatePurchaseGoogleRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/iap/purchase/google", {}, request.to_json())


## Validate a Google subscription receipt.
static func validate_subscription_google(
		request: NakamaTypes.ValidateSubscriptionGoogleRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/iap/subscription/google", {}, request.to_json())


## Validate a Huawei IAP receipt.
static func validate_purchase_huawei(
		request: NakamaTypes.ValidatePurchaseHuaweiRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/iap/purchase/huawei", {}, request.to_json())


## Validate a Facebook Instant Games IAP receipt.
static func validate_purchase_facebook_instant(
		request: NakamaTypes.ValidatePurchaseFacebookInstantRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/iap/purchase/facebookinstant", {}, request.to_json())


## Validate a Samsung Galaxy Store IAP receipt.
static func validate_purchase_samsung(
		request: NakamaTypes.ValidatePurchaseSamsungRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/iap/purchase/samsung", {}, request.to_json())


## Write a record to a leaderboard.
static func write_leaderboard_record(
		request: NakamaTypes.WriteLeaderboardRecordRequest) -> ApiRequestModel:
	var url := "/v2/leaderboard/{leaderboard_id}"
	url = url.replace("{leaderboard_id}", str(request.leaderboard_id).uri_encode())
	return ApiRequestModel.new("POST", url, {}, request.record.to_json())


## Write objects into the storage engine.
static func write_storage_objects(
		request: NakamaTypes.WriteStorageObjectsRequest) -> ApiRequestModel:
	return ApiRequestModel.new("PUT", "/v2/storage", {}, request.to_json())


## Write a record to a tournament.
static func write_tournament_record(
		request: NakamaTypes.WriteTournamentRecordRequest) -> ApiRequestModel:
	var url := "/v2/tournament/{tournament_id}"
	url = url.replace("{tournament_id}", str(request.tournament_id).uri_encode())
	return ApiRequestModel.new("PUT", url, {}, request.record.to_json())


## Add friends by ID or username to a user's account.
static func add_friends(metadata: String = "", ids: Array[String] = [],
		usernames: Array[String] = []) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/friend", {
		"metadata": metadata,
		"ids": ids,
		"usernames": usernames,
	})


## Add users to a group.
static func add_group_users(group_id: String = "", user_ids: Array[String] = []) -> ApiRequestModel:
	var url := "/v2/group/{group_id}/add"
	url = url.replace("{group_id}", str(group_id).uri_encode())
	return ApiRequestModel.new("POST", url, {
		"user_ids": user_ids,
	})


## Log out a session, invalidate a refresh token, or log out all sessions/refresh tokens for a user.
static func session_logout(request: NakamaTypes.SessionLogoutRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/session/logout", {}, request.to_json())


## Ban a set of users from a group.
static func ban_group_users(group_id: String = "", user_ids: Array[String] = []) -> ApiRequestModel:
	var url := "/v2/group/{group_id}/ban"
	url = url.replace("{group_id}", str(group_id).uri_encode())
	return ApiRequestModel.new("POST", url, {
		"user_ids": user_ids,
	})


## Block one or more users by ID or username.
static func block_friends(ids: Array[String] = [],
		usernames: Array[String] = []) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/friend/block", {
		"ids": ids,
		"usernames": usernames,
	})


## Delete one or more friends by ID or username.
static func delete_friends(ids: Array[String] = [],
		usernames: Array[String] = []) -> ApiRequestModel:
	return ApiRequestModel.new("DELETE", "/v2/friend", {
		"ids": ids,
		"usernames": usernames,
	})


## Delete a group by ID.
static func delete_group(group_id: String = "") -> ApiRequestModel:
	var url := "/v2/group/{group_id}"
	url = url.replace("{group_id}", str(group_id).uri_encode())
	return ApiRequestModel.new("DELETE", url)


## Delete a leaderboard record.
static func delete_leaderboard_record(leaderboard_id: String = "") -> ApiRequestModel:
	var url := "/v2/leaderboard/{leaderboard_id}"
	url = url.replace("{leaderboard_id}", str(leaderboard_id).uri_encode())
	return ApiRequestModel.new("DELETE", url)


## Delete one or more notifications for the current user.
static func delete_notifications(ids: Array[String] = []) -> ApiRequestModel:
	return ApiRequestModel.new("DELETE", "/v2/notification", {
		"ids": ids,
	})


## Delete a tournament record.
static func delete_tournament_record(tournament_id: String = "") -> ApiRequestModel:
	var url := "/v2/tournament/{tournament_id}"
	url = url.replace("{tournament_id}", str(tournament_id).uri_encode())
	return ApiRequestModel.new("DELETE", url)


## Delete one or more storage objects.
static func delete_storage_objects(
		request: NakamaTypes.DeleteStorageObjectsRequest) -> ApiRequestModel:
	return ApiRequestModel.new("PUT", "/v2/storage/delete", {}, request.to_json())


## Submit an event for processing in the server's registered runtime custom events handler.
static func event(request: NakamaTypes.Event) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/event", {}, request.to_json())


## Import Facebook friends and add them to a user's account.
static func import_facebook_friends(
		request: NakamaTypes.ImportFacebookFriendsRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/friend/facebook", {
		"reset": request.reset,
	}, request.account.to_json())


## Import Steam friends and add them to a user's account.
static func import_steam_friends(request: NakamaTypes.ImportSteamFriendsRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/friend/steam", {
		"reset": request.reset,
	}, request.account.to_json())


## Immediately join an open group, or request to join a closed one.
static func join_group(group_id: String = "") -> ApiRequestModel:
	var url := "/v2/group/{group_id}/join"
	url = url.replace("{group_id}", str(group_id).uri_encode())
	return ApiRequestModel.new("POST", url)


## Attempt to join an open and running tournament.
static func join_tournament(tournament_id: String = "") -> ApiRequestModel:
	var url := "/v2/tournament/{tournament_id}/join"
	url = url.replace("{tournament_id}", str(tournament_id).uri_encode())
	return ApiRequestModel.new("POST", url)


## Kick a set of users from a group.
static func kick_group_users(group_id: String = "",
		user_ids: Array[String] = []) -> ApiRequestModel:
	var url := "/v2/group/{group_id}/kick"
	url = url.replace("{group_id}", str(group_id).uri_encode())
	return ApiRequestModel.new("POST", url, {
		"user_ids": user_ids,
	})


## Leave a group the user is a member of.
static func leave_group(group_id: String = "") -> ApiRequestModel:
	var url := "/v2/group/{group_id}/leave"
	url = url.replace("{group_id}", str(group_id).uri_encode())
	return ApiRequestModel.new("POST", url)


## Add an Apple ID to the social profiles on the current user's account.
static func link_apple(request: NakamaTypes.AccountApple) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/link/apple", {}, request.to_json())


## Add a custom ID to the social profiles on the current user's account.
static func link_custom(request: NakamaTypes.AccountCustom) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/link/custom", {}, request.to_json())


## Add an authentication provider identity to the current user's account.
static func link(request: NakamaTypes.AccountProvider) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/link", {}, request.to_json())


## Add a device ID to the social profiles on the current user's account.
static func link_device(request: NakamaTypes.AccountDevice) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/link/device", {}, request.to_json())


## Add an email+password to the social profiles on the current user's account.
static func link_email(request: NakamaTypes.AccountEmail) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/link/email", {}, request.to_json())


## Add Facebook to the social profiles on the current user's account.
static func link_facebook(request: NakamaTypes.LinkFacebookRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/link/facebook", {
		"sync": request.sync,
	}, request.account.to_json())


## Add Facebook Instant Game to the social profiles on the current user's account.
static func link_facebook_instant_game(
		request: NakamaTypes.AccountFacebookInstantGame) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/link/facebookinstantgame", {}, request.to_json())


## Add Apple's Game Center to the social profiles on the current user's account.
static func link_game_center(request: NakamaTypes.AccountGameCenter) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/link/gamecenter", {}, request.to_json())


## Add Google to the social profiles on the current user's account.
static func link_google(request: NakamaTypes.AccountGoogle) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/link/google", {}, request.to_json())


## Add Steam to the social profiles on the current user's account.
static func link_steam(request: NakamaTypes.LinkSteamRequest) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/link/steam", {}, request.to_json())


## Promote a set of users in a group to the next role up.
static func promote_group_users(group_id: String = "",
		user_ids: Array[String] = []) -> ApiRequestModel:
	var url := "/v2/group/{group_id}/promote"
	url = url.replace("{group_id}", str(group_id).uri_encode())
	return ApiRequestModel.new("POST", url, {
		"user_ids": user_ids,
	})


## Demote a set of users in a group to the next role down.
static func demote_group_users(group_id: String = "",
		user_ids: Array[String] = []) -> ApiRequestModel:
	var url := "/v2/group/{group_id}/demote"
	url = url.replace("{group_id}", str(group_id).uri_encode())
	return ApiRequestModel.new("POST", url, {
		"user_ids": user_ids,
	})


## Remove the Apple ID from the social profiles on the current user's account.
static func unlink_apple(request: NakamaTypes.AccountApple) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/unlink/apple", {}, request.to_json())


## Remove the custom ID from the social profiles on the current user's account.
static func unlink_custom(request: NakamaTypes.AccountCustom) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/unlink/custom", {}, request.to_json())


## Remove an authentication provider identity from the current user's account.
static func unlink(request: NakamaTypes.AccountProvider) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/unlink", {}, request.to_json())


## Remove the device ID from the social profiles on the current user's account.
static func unlink_device(request: NakamaTypes.AccountDevice) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/unlink/device", {}, request.to_json())


## Remove the email+password from the social profiles on the current user's account.
static func unlink_email(request: NakamaTypes.AccountEmail) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/unlink/email", {}, request.to_json())


## Remove Facebook from the social profiles on the current user's account.
static func unlink_facebook(request: NakamaTypes.AccountFacebook) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/unlink/facebook", {}, request.to_json())


## Remove Facebook Instant Game profile from the social profiles on the current user's account.
static func unlink_facebook_instant_game(
		request: NakamaTypes.AccountFacebookInstantGame) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/unlink/facebookinstantgame", {}, request.to_json())


## Remove Apple's Game Center from the social profiles on the current user's account.
static func unlink_game_center(request: NakamaTypes.AccountGameCenter) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/unlink/gamecenter", {}, request.to_json())


## Remove Google from the social profiles on the current user's account.
static func unlink_google(request: NakamaTypes.AccountGoogle) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/unlink/google", {}, request.to_json())


## Remove Steam from the social profiles on the current user's account.
static func unlink_steam(request: NakamaTypes.AccountSteam) -> ApiRequestModel:
	return ApiRequestModel.new("POST", "/v2/account/unlink/steam", {}, request.to_json())


## Update fields in the current user's account.
static func update_account(request: NakamaTypes.UpdateAccountRequest) -> ApiRequestModel:
	return ApiRequestModel.new("PUT", "/v2/account", {}, request.to_json())


## Update fields in a given group.
static func update_group(request: NakamaTypes.UpdateGroupRequest) -> ApiRequestModel:
	var url := "/v2/group/{group_id}"
	url = url.replace("{group_id}", str(request.group_id).uri_encode())
	return ApiRequestModel.new("PUT", url, {}, request.to_json())


## Fetch the current user's account.
static func get_account() -> ApiRequestModel:
	return ApiRequestModel.new("GET", "/v2/account")


## Get matchmaker stats.
static func get_matchmaker_stats() -> ApiRequestModel:
	return ApiRequestModel.new("GET", "/v2/matchmaker/stats")


## Delete the current user's account.
static func delete_account() -> ApiRequestModel:
	return ApiRequestModel.new("DELETE", "/v2/account")


## A healthcheck which load balancers can use to check the service.
static func healthcheck() -> ApiRequestModel:
	return ApiRequestModel.new("GET", "/healthcheck")


## An HTTP request for the client to send.
class ApiRequestModel:
	var verb: String
	var url: String
	var body: String


	## p_query is appended to p_url, skipping nulls; arrays repeat the key.
	func _init(p_verb: String, p_url: String, p_query: Dictionary = {},
			p_body: String = "") -> void:
		verb = p_verb
		body = p_body
		var query := PackedStringArray()
		for key: String in p_query:
			var value: Variant = p_query[key]
			if value == null:
				continue
			for item: Variant in (value if value is Array else [value]):
				query.append("%s=%s" % [key, str(item).uri_encode()])
		url = p_url if query.is_empty() else p_url + "?" + "&".join(query)

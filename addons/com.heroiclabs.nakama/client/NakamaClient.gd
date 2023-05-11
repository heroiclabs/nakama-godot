extends RefCounted

# A client for the API in Nakama server.
class_name NakamaClient

const ChannelType = NakamaRTMessage.ChannelJoin.ChannelType

# The host address of the server. Defaults to "127.0.0.1".
var _host
var host : String:
	set(v):
		pass
	get:
		return _host

# The port number of the server. Defaults to 7350.
var _port
var port : int:
	set(v):
		pass
	get:
		return _port

# The protocol scheme used to connect with the server. Must be either "http" or "https".
var _scheme
var scheme : String:
	set(v):
		pass
	get:
		return _scheme

# The key used to authenticate with the server without a session. Defaults to "defaultkey".
var _server_key : String = "defaultkey"
var server_key:
	set(v):
		pass
	get:
		return _server_key

# Set the timeout in seconds on requests sent to the server.
var timeout : int

var logger : NakamaLogger = null

var _api_client : NakamaAPI.ApiClient

var auto_refresh : bool = true:
	set(v):
		set_auto_refresh(v)
	get:
		return get_auto_refresh()

var auto_refresh_seconds : int = true:
	set(v):
		set_auto_refresh_seconds(v)
	get:
		return get_auto_refresh_seconds()

var auto_retry : bool = true:
	set(v):
		set_auto_retry(v)
	get:
		return get_auto_retry()

var auto_retry_count:
	set(v):
		set_auto_retry_count(v)
	get:
		return get_auto_retry_count()

var auto_retry_backoff_base:
	set(v):
		set_auto_retry_backoff_base(v)
	get:
		return get_auto_retry_backoff_base()

var last_cancel_token:
	set(v):
		pass
	get:
		return get_last_cancel_token()

func get_auto_refresh():
	return _api_client.auto_refresh

func set_auto_refresh(p_value):
	_api_client.auto_refresh = p_value

func get_auto_refresh_seconds():
	return _api_client.auto_refresh_time

func set_auto_refresh_seconds(p_value):
	_api_client.auto_refresh_time = p_value

func get_last_cancel_token():
	return _api_client.last_cancel_token

func get_auto_retry():
	return _api_client.auto_retry

func set_auto_retry(p_value):
	_api_client.auto_retry = p_value

func get_auto_retry_count():
	return _api_client.auto_retry_count

func set_auto_retry_count(p_value):
	_api_client.auto_retry_count = p_value

func get_auto_retry_backoff_base():
	return _api_client.auto_retry_backoff_base

func set_auto_retry_backoff_base(p_value):
	_api_client.auto_retry_backoff_base = p_value

func cancel_request(p_token):
	_api_client.cancel_request(p_token)

func _init(p_adapter : NakamaHTTPAdapter,
		p_server_key : String,
		p_scheme : String,
		p_host : String,
		p_port : int,
		p_timeout : int):

	_server_key = p_server_key
	_scheme = p_scheme
	_host = p_host
	_port = p_port
	timeout = p_timeout
	logger = p_adapter.logger
	_api_client = NakamaAPI.ApiClient.new(_scheme + "://" + _host + ":" + str(_port), p_adapter, NakamaAPI, _server_key, p_timeout)

# Restore a session from the auth token.
# A `null` or empty authentication token will return `null`.
# @param authToken - The authentication token to restore as a session.
# Returns a session.
static func restore_session(auth_token : String):
	return NakamaSession.new(auth_token, false)

func _to_string():
	return "Client(Host='%s', Port=%s, Scheme='%s', ServerKey='%s', Timeout=%s)" % [
		host, port, scheme, server_key, timeout
	]

func _parse_auth(p_session) -> NakamaSession:
	if p_session.is_exception():
		return NakamaSession.new(null, false, null, p_session.get_exception())
	return NakamaSession.new(p_session.token, p_session.created, p_session.refresh_token)

# Add one or more friends by id or username.
# @param p_session - The session of the user.
# @param p_ids - The ids of the users to add or invite as friends.
# @param p_usernames - The usernames of the users to add as friends.
# Returns a task which represents the asynchronous operation.
func add_friends_async(p_session : NakamaSession, p_ids = null, p_usernames = null) -> NakamaAsyncResult:
	return await _api_client.add_friends_async(p_session, p_ids, p_usernames)

# Add one or more users to the group.
# @param p_session - The session of the user.
# @param p_group_id - The id of the group to add users into.
# @param p_ids - The ids of the users to add or invite to the group.
# Returns a task which represents the asynchronous operation.
func add_group_users_async(p_session : NakamaSession, p_group_id : String, p_ids : PackedStringArray) -> NakamaAsyncResult:
	return await _api_client.add_group_users_async(p_session, p_group_id, p_ids);

# Authenticate a user with an Apple ID against the server.
# @param p_username - A username used to create the user.</param>
# @param p_token - The ID token received from Apple to validate.</param>
# @param p_vars - Extra information that will be bundled in the session token.</param>
# Returns a task which resolves to a session object.
func authenticate_apple_async(p_token : String, p_username = null, p_create : bool = true, p_vars = null) -> NakamaSession:
	return _parse_auth(await _api_client.authenticate_apple_async(server_key, "",
		NakamaAPI.ApiAccountApple.create(NakamaAPI, {
			"token": p_token,
			"vars": p_vars
		}), p_create, p_username))

# Authenticate a user with a custom id.
# @param p_id - A custom identifier usually obtained from an external authentication service.
# @param p_username - A username used to create the user. May be `null`.
# @param p_create - If the user should be created when authenticated.
# @param p_vars - Extra information that will be bundled in the session token.
# Returns a task which resolves to a session object.
func authenticate_custom_async(p_id : String, p_username = null, p_create : bool = true, p_vars = null) -> NakamaSession:
	return _parse_auth(await _api_client.authenticate_custom_async(server_key, "",
		NakamaAPI.ApiAccountCustom.create(NakamaAPI, {
			"id": p_id,
			"vars": p_vars
		}), p_create, p_username))

# Authenticate a user with a device id.
# @param p_id - A device identifier usually obtained from a platform API.
# @param p_username - A username used to create the user. May be `null`.
# @param p_create - If the user should be created when authenticated.
# @param p_vars - Extra information that will be bundled in the session token.
# Returns a task which resolves to a session object.
func authenticate_device_async(p_id : String, p_username = null, p_create : bool = true, p_vars = null) -> NakamaSession:
	return _parse_auth(await _api_client.authenticate_device_async(server_key, "",
		NakamaAPI.ApiAccountDevice.create(NakamaAPI, {
			"id": p_id,
			"vars": p_vars
		}), p_create, p_username))

# Authenticate a user with an email and password.
# @param p_email - The email address of the user.
# @param p_password - The password for the user.
# @param p_username - A username used to create the user. May be `null`.
# @param p_create - If the user should be created when authenticated.
# @param p_vars - Extra information that will be bundled in the session token.
# Returns a task which resolves to a session object.
func authenticate_email_async(p_email : String, p_password : String, p_username = null, p_create : bool = true, p_vars = null) -> NakamaSession:
	return _parse_auth(await _api_client.authenticate_email_async(server_key, "",
		NakamaAPI.ApiAccountEmail.create(NakamaAPI, {
			"email": p_email,
			"password": p_password,
			"vars": p_vars
		}), p_create, p_username))

# Authenticate a user with a Facebook auth token.
# @param p_token - An OAuth access token from the Facebook SDK.
# @param p_username - A username used to create the user. May be `null`.
# @param p_create - If the user should be created when authenticated.
# @param p_import - If the Facebook friends should be imported.
# @param p_vars - Extra information that will be bundled in the session token.
# Returns a task which resolves to a session object.
func authenticate_facebook_async(p_token : String, p_username = null, p_create : bool = true, p_import : bool = true, p_vars = null) -> NakamaSession:
	return _parse_auth(await _api_client.authenticate_facebook_async(server_key, "",
		NakamaAPI.ApiAccountFacebook.create(NakamaAPI, {
			"token": p_token,
			"vars": p_vars
		}), p_create, p_username, p_import))

# Authenticate a user with a Facebook Instant Game token against the server.
# @param p_signed_player_info - Facebook Instant Game signed info from Facebook SDK.
# @param p_username - A username used to create the user. May be `null`.
# @param p_create - If the user should be created when authenticated.
# @param p_import - If the Facebook friends should be imported.
# @param p_vars - Extra information that will be bundled in the session token.
# Returns a task which resolves to a session object.
func authenticate_facebook_instant_game_async(p_signed_player_info : String, p_username = null, p_create : bool = true, p_vars = null) -> NakamaSession:
		return _parse_auth(await _api_client.authenticate_facebook_instant_game_async(server_key, "",
				NakamaAPI.ApiAccountFacebookInstantGame.create(NakamaAPI, {
						"signed_player_info": p_signed_player_info,
						"vars": p_vars
				}), p_create, p_username))

# Authenticate a user with Apple Game Center.
# @param p_bundle_id - The bundle id of the Game Center application.
# @param p_player_id - The player id of the user in Game Center.
# @param p_public_key_url - The URL for the public encryption key.
# @param p_salt - A random `NSString` used to compute the hash and keep it randomized.
# @param p_signature - The verification signature data generated.
# @param p_timestamp_seconds - The date and time that the signature was created.
# @param p_username - A username used to create the user. May be `null`.
# @param p_create - If the user should be created when authenticated.
# @param p_vars - Extra information that will be bundled in the session token.
# Returns a task which resolves to a session object.
func authenticate_game_center_async(p_bundle_id : String, p_player_id : String, p_public_key_url : String,
		p_salt : String, p_signature : String, p_timestamp_seconds : String, p_username = null, p_create : bool = true, p_vars = null) -> NakamaSession:
	return _parse_auth(await _api_client.authenticate_game_center_async(server_key, "",
		NakamaAPI.ApiAccountGameCenter.create(NakamaAPI, {
			"bundle_id": p_bundle_id,
			"player_id": p_player_id,
			"public_key_url": p_public_key_url,
			"salt": p_salt,
			"signature": p_signature,
			"timestamp_seconds": p_timestamp_seconds,
			"vars": p_vars
		}), p_create, p_username))

# Authenticate a user with a Google auth token.
# @param p_token - An OAuth access token from the Google SDK.
# @param p_username - A username used to create the user. May be `null`.
# @param p_create - If the user should be created when authenticated.
# @param p_vars - Extra information that will be bundled in the session token.
# Returns a task which resolves to a session object.
func authenticate_google_async(p_token : String, p_username = null, p_create : bool = true, p_vars = null) -> NakamaSession:
	return _parse_auth(await _api_client.authenticate_google_async(server_key, "",
		NakamaAPI.ApiAccountGoogle.create(NakamaAPI, {
			"token": p_token,
			"vars": p_vars
		}), p_create, p_username))

# Authenticate a user with a Steam auth token.
# @param p_token - An authentication token from the Steam network.
# @param p_username - A username used to create the user. May be `null`.
# @param p_create - If the user should be created when authenticated.
# @param p_vars - Extra information that will be bundled in the session token.
# Returns a task which resolves to a session object.
func authenticate_steam_async(p_token : String, p_username = null, p_create : bool = true, p_vars = null, p_sync : bool = false) -> NakamaSession:
	return _parse_auth(await _api_client.authenticate_steam_async(server_key, "",
		NakamaAPI.ApiAccountSteam.create(NakamaAPI, {
			"token": p_token,
			"vars": p_vars
		}), p_create, p_username, p_sync))

# Block one or more friends by id or username.
# @param p_session - The session of the user.
# @param p_ids - The ids of the users to block.
# @param p_usernames - The usernames of the users to block.
# Returns a task which represents the asynchronous operation.
func block_friends_async(p_session : NakamaSession, p_ids : PackedStringArray, p_usernames = null) -> NakamaAsyncResult:
	return await _api_client.block_friends_async(p_session, p_ids, p_usernames);

# Create a group.
# @param p_session - The session of the user.
# @param p_name - The name for the group.
# @param p_description - A description for the group.
# @param p_avatar_url - An avatar url for the group.
# @param p_lang_tag - A language tag in BCP-47 format for the group.
# @param p_open - If the group should have open membership.
# @param p_max_count - The maximum number of members allowed.
# Returns a task which resolves to a new group object.
func create_group_async(p_session : NakamaSession, p_name : String, p_description : String = "",
		p_avatar_url = null, p_lang_tag = null, p_open : bool = true, p_max_count : int = 100): # -> NakamaAPI.ApiGroup:
	return await _api_client.create_group_async(p_session,
		NakamaAPI.ApiCreateGroupRequest.create(NakamaAPI, {
			"avatar_url": p_avatar_url,
			"description": p_description,
			"lang_tag": p_lang_tag,
			"max_count": p_max_count,
			"name": p_name,
			"open": p_open
		}))

# Delete the current user's account on the server.
# @param p_session - The session of the user.
# Returns a task which represents the asynchronous operation.
func delete_account_async(p_session : NakamaSession) -> NakamaAsyncResult:
	return await _api_client.delete_account_async(p_session)

# Delete one more or users by id or username from friends.
# @param p_session - The session of the user.
# @param p_ids - The user ids to remove as friends.
# @param p_usernames - The usernames to remove as friends.
# Returns a task which represents the asynchronous operation.
func delete_friends_async(p_session : NakamaSession, p_ids : PackedStringArray, p_usernames = null) -> NakamaAsyncResult:
	return await _api_client.delete_friends_async(p_session, p_ids, p_usernames)

# Delete a group by id.
# @param p_session - The session of the user.
# @param p_group_id - The group id to to remove.
# Returns a task which represents the asynchronous operation.
func delete_group_async(p_session : NakamaSession, p_group_id : String) -> NakamaAsyncResult:
	return await _api_client.delete_group_async(p_session, p_group_id)

# Delete a leaderboard record.
# @param p_session - The session of the user.
# @param p_leaderboard_id - The id of the leaderboard with the record to be deleted.
# Returns a task which represents the asynchronous operation.
func delete_leaderboard_record_async(p_session : NakamaSession, p_leaderboard_id : String) -> NakamaAsyncResult:
	return await _api_client.delete_leaderboard_record_async(p_session, p_leaderboard_id)

# Delete one or more notifications by id.
# @param p_session - The session of the user.
# @param p_ids - The notification ids to remove.
# Returns a task which represents the asynchronous operation.
func delete_notifications_async(p_session : NakamaSession, p_ids : PackedStringArray) -> NakamaAsyncResult:
	return await _api_client.delete_notifications_async(p_session, p_ids)

# Delete one or more storage objects.
# @param p_session - The session of the user.
# @param p_ids - The ids of the objects to delete.
# Returns a task which represents the asynchronous operation.
func delete_storage_objects_async(p_session : NakamaSession, p_ids : Array) -> NakamaAsyncResult:
	var ids : Array = []
	for id in p_ids:
		if not id is NakamaStorageObjectId:
			continue # TODO Exceptions
		var obj_id : NakamaStorageObjectId = id
		ids.append(obj_id.as_delete().serialize())
	return await _api_client.delete_storage_objects_async(p_session,
		NakamaAPI.ApiDeleteStorageObjectsRequest.create(NakamaAPI, {
			"object_ids": ids
		}))

# Demote a set of users in a group to the next role down.
# @param p_session - The session of the user.
# @param p_group_id - The ID of the group to demote users into.
# @param p_ids - The IDs of the users to demote.
# Returns a task which represents the asynchronous operation.
func demote_group_users_async(p_session : NakamaSession, p_group_id : String, p_user_ids : Array):
	return await _api_client.demote_group_users_async(p_session, p_group_id, p_user_ids)

# Submit an event for processing in the server's registered runtime custom events handler.
# @param p_session - The session of the user.
# @param p_name - The name of the event.
# @param p_properties - The properties of the event.
# Returns a task which represents the asynchronous operation.
func event_async(p_session : NakamaSession, p_name : String, p_properties : Dictionary = {}) -> NakamaAsyncResult:
	return await _api_client.event_async(p_session, NakamaAPI.ApiEvent.create(
		NakamaAPI,
		{
			"name": p_name,
			"properties": p_properties,
			"external": true,
		}
	))

# Fetch the user account owned by the session.
# @param p_session - The session of the user.
# Returns a task which resolves to the account object.
func get_account_async(p_session : NakamaSession): # -> NakamaAPI.ApiAccount:
	return await _api_client.get_account_async(p_session)

# Get subscription by product id.
# @param p_session - The session of the user.
# @param p_product_id - The product id.
# Returns a task which resolves to the subscription object.
func get_subscription_async(p_session : NakamaSession, p_product_id : String): # -> ApiValidatedSubscription:
	return await _api_client.get_subscription_async(p_session, p_product_id)

# Fetch one or more users by id, usernames, and Facebook ids.
# @param p_session - The session of the user.
# @param p_ids - The IDs of the users to retrieve.
# @param p_usernames - The usernames of the users to retrieve.
# @param p_facebook_ids - The facebook IDs of the users to retrieve.
# Returns a task which resolves to a collection of user objects.
func get_users_async(p_session : NakamaSession, p_ids : PackedStringArray, p_usernames = null, p_facebook_ids = null): # -> NakamaAPI.ApiUsers:
	return await _api_client.get_users_async(p_session, p_ids, p_usernames, p_facebook_ids)

# Import Facebook friends and add them to the user's account.
# The server will import friends when the user authenticates with Facebook. This function can be used to be
# explicit with the import operation.
# @param p_session - The session of the user.
# @param p_token - An OAuth access token from the Facebook SDK.
# @param p_reset - If the Facebook friend import for the user should be reset.
# Returns a task which represents the asynchronous operation.
func import_facebook_friends_async(p_session : NakamaSession, p_token : String, p_reset = null) -> NakamaAsyncResult:
	return await _api_client.import_facebook_friends_async(p_session,
		NakamaAPI.ApiAccountFacebook.create(NakamaAPI, {
			"token": p_token
		}), p_reset)

# Import Steam friends and add them to the user's account.
# The server will import friends when the user authenticates with Steam. This function can be used to be
# explicit with the import operation.
# @param p_session - The session of the user.
# @param p_token - An access token from Steam.
# @param p_reset - If the Steam friend import for the user should be reset.
# Returns a task which represents the asynchronous operation.
func import_steam_friends_async(p_session : NakamaSession, p_token : String, p_reset = null):
	return await _api_client.import_steam_friends_async(p_session,
		NakamaAPI.ApiAccountSteam.create(NakamaAPI, {
			"token": p_token
		}), p_reset)

# Join a group if it has open membership or request to join it.
# @param p_session - The session of the user.
# @param p_group_id - The ID of the group to join.
# Returns a task which represents the asynchronous operation.
func join_group_async(p_session : NakamaSession, p_group_id : String) -> NakamaAsyncResult:
	return await _api_client.join_group_async(p_session, p_group_id)

# Join a tournament by ID.
# @param p_session - The session of the user.
# @param p_tournament_id - The ID of the tournament to join.
# Returns a task which represents the asynchronous operation.
func join_tournament_async(p_session : NakamaSession, p_tournament_id : String) -> NakamaAsyncResult:
	return await _api_client.join_tournament_async(p_session, p_tournament_id)

# Kick one or more users from the group.
# @param p_session - The session of the user.
# @param p_group_id - The ID of the group.
# @param p_ids - The IDs of the users to kick.
# Returns a task which represents the asynchronous operation.
func kick_group_users_async(p_session : NakamaSession, p_group_id : String, p_ids : PackedStringArray) -> NakamaAsyncResult:
	return await _api_client.kick_group_users_async(p_session, p_group_id, p_ids)

# Leave a group by ID.
# @param p_session - The session of the user.
# @param p_group_id - The ID of the group to leave.
# Returns a task which represents the asynchronous operation.
func leave_group_async(p_session : NakamaSession, p_group_id : String) -> NakamaAsyncResult:
	return await _api_client.leave_group_async(p_session, p_group_id)

# Link an Apple ID to the social profiles on the current user's account.
# @param p_session - The session of the user.
# @param p_token - The ID token received from Apple to validate.
# Returns a task which represents the asynchronous operation.
func link_apple_async(p_session : NakamaSession, p_token : String) -> NakamaAsyncResult:
	return await _api_client.link_apple_async(p_session, NakamaAPI.ApiAccountApple.create(NakamaAPI, {
		"token": p_token
	}))

# Link a custom ID to the user account owned by the session.
# @param p_session - The session of the user.
# @param p_id - A custom identifier usually obtained from an external authentication service.
# Returns a task which represents the asynchronous operation.
func link_custom_async(p_session : NakamaSession, p_id : String) -> NakamaAsyncResult:
	return await _api_client.link_custom_async(p_session, NakamaAPI.ApiAccountCustom.create(NakamaAPI, {
		"id": p_id
	}))

# Link a device ID to the user account owned by the session.
# @param p_session - The session of the user.
# @param p_id - A device identifier usually obtained from a platform API.
# Returns a task which represents the asynchronous operation.
func link_device_async(p_session : NakamaSession, p_id : String) -> NakamaAsyncResult:
	return await _api_client.link_device_async(p_session, NakamaAPI.ApiAccountDevice.create(NakamaAPI, {
		"id": p_id
	}))

# Link an email with password to the user account owned by the session.
# @param p_session - The session of the user.
# @param p_email - The email address of the user.
# @param p_password - The password for the user.
# Returns a task which represents the asynchronous operation.
func link_email_async(p_session : NakamaSession, p_email : String, p_password : String) -> NakamaAsyncResult:
	return await _api_client.link_email_async(p_session, NakamaAPI.ApiAccountEmail.create(NakamaAPI, {
		"email": p_email,
		"password": p_password
	}))

# Link a Facebook profile to a user account.
# @param p_session - The session of the user.
# @param p_token - An OAuth access token from the Facebook SDK.
# @param p_import - If the Facebook friends should be imported.
# Returns a task which represents the asynchronous operation.
func link_facebook_async(p_session : NakamaSession, p_token : String) -> NakamaAsyncResult:
	return await _api_client.link_facebook_async(p_session, NakamaAPI.ApiAccountFacebook.create(NakamaAPI, {
		"token": p_token
	}))

# Add Facebook Instant Game to the social profiles on the current user's account.
# @param p_session - The session of the user.
# @param p_token - An OAuth access token from the Facebook SDK.
# @param p_import - If the Facebook friends should be imported.
# Returns a task which represents the asynchronous operation.
func link_facebook_instant_game_async(p_session : NakamaSession, p_signed_player_info : String) -> NakamaAsyncResult:
	return await _api_client.link_facebook_instant_game_async(
		p_session,
		NakamaAPI.ApiAccountFacebookInstantGame.create(
			NakamaAPI, {
				"signed_player_info": p_signed_player_info
			})
		)

# Link a Game Center profile to a user account.
# @param p_session - The session of the user.
# @param p_bundle_id - The bundle ID of the Game Center application.
# @param p_player_id - The player ID of the user in Game Center.
# @param p_public_key_url - The URL for the public encryption key.
# @param p_salt - A random `NSString` used to compute the hash and keep it randomized.
# @param p_signature - The verification signature data generated.
# @param p_timestamp_seconds - The date and time that the signature was created.
# Returns a task which represents the asynchronous operation.
func link_game_center_async(p_session : NakamaSession,
		p_bundle_id : String, p_player_id : String, p_public_key_url : String, p_salt : String, p_signature : String, p_timestamp_seconds) -> NakamaAsyncResult:
	return await _api_client.link_game_center_async(p_session,
		NakamaAPI.ApiAccountGameCenter.create(NakamaAPI, {
			"bundle_id": p_bundle_id,
			"player_id": p_player_id,
			"public_key_url": p_public_key_url,
			"salt": p_salt,
			"signature": p_signature,
			"timestamp_seconds": p_timestamp_seconds,
		}))

# Link a Google profile to a user account.
# @param p_session - The session of the user.
# @param p_token - An OAuth access token from the Google SDK.
# Returns a task which represents the asynchronous operation.
func link_google_async(p_session : NakamaSession, p_token : String) -> NakamaAsyncResult:
	return await _api_client.link_google_async(p_session, NakamaAPI.ApiAccountGoogle.create(NakamaAPI, {
		"token": p_token
	}))

# Link a Steam profile to a user account.
# @param p_session - The session of the user.
# @param p_token - An authentication token from the Steam network.
# Returns a task which represents the asynchronous operation.
func link_steam_async(p_session : NakamaSession, p_token : String, p_sync : bool = false) -> NakamaAsyncResult:
	return await _api_client.link_steam_async(p_session, NakamaAPI.ApiLinkSteamRequest.create(
		NakamaAPI,
		{
			"account": NakamaAPI.ApiAccountSteam.create(NakamaAPI, {
				"token": p_token
			}).serialize(),
			"sync": p_sync
		}

	))

# List messages from a chat channel.
# @param p_session - The session of the user.
# @param p_channel_id - The id of the chat channel.
# @param p_limit - The number of chat messages to list.
# @param forward - Fetch messages forward from the current cursor (or the start).
# @param p_cursor - A cursor for the current position in the messages history to list.
# Returns a task which resolves to the channel message list object.
func list_channel_messages_async(p_session : NakamaSession, p_channel_id : String, limit : int = 1,
		forward : bool = true, cursor = null): # -> NakamaAPI.ApiChannelMessageList:
	return await _api_client.list_channel_messages_async(p_session, p_channel_id, limit, forward, cursor)

# List of friends of the current user.
# @param p_session - The session of the user.
# @param p_state - Filter by friendship state.
# @param p_limit - The number of friends to list.
# @param p_cursor - A cursor for the current position in the friends list.
# Returns a task which resolves to the friend objects.
func list_friends_async(p_session : NakamaSession, p_state = null, p_limit = null, p_cursor = null): # -> NakamaAPI.ApiFriendList:
	return await _api_client.list_friends_async(p_session, p_limit, p_state, p_cursor)

# List all users part of the group.
# @param p_session - The session of the user.
# @param p_group_id - The ID of the group.
# @param p_state - Filter by group membership state.
# @param p_limit - The number of groups to list.
# @param p_cursor - A cursor for the current position in the group listing.
# Returns a task which resolves to the group user objects.
func list_group_users_async(p_session : NakamaSession, p_group_id : String, p_state = null, p_limit = null, p_cursor = null): # -> NakamaAPI.ApiGroupUserList:
	return await _api_client.list_group_users_async(p_session, p_group_id, p_limit, p_state, p_cursor)

# List groups on the server.
# @param p_session - The session of the user.
# @param p_name - The name filter to apply to the group list.
# @param p_limit - The number of groups to list.
# @param p_cursor - A cursor for the current position in the groups to list.
# @param p_lang_tag - The language tag filter.
# @param p_members - The number of group members filter.
# @param p_open - Optional open/closed filter.
# Returns a task to resolve group objects.
func list_groups_async(p_session : NakamaSession, p_name = null, p_limit : int = 10, p_cursor = null, p_lang_tag = null, p_members = null, p_open = null): # -> NakamaAPI.ApiGroupList:
	return await _api_client.list_groups_async(p_session, p_name, p_cursor, p_limit, p_lang_tag, p_members, p_open)

# List records from a leaderboard.
# @param p_session - The session of the user.
# @param p_leaderboard_id - The ID of the leaderboard to list.
# @param p_owner_ids - Record owners to fetch with the list of records.
# @param p_expiry - Expiry in seconds (since epoch) to begin fetching records from. Optional. 0 means from current time.
# @param p_limit - The number of records to list.
# @param p_cursor - A cursor for the current position in the leaderboard records to list.
# Returns a task which resolves to the leaderboard record objects.
func list_leaderboard_records_async(p_session : NakamaSession,
		p_leaderboard_id : String, p_owner_ids = null, p_expiry = null, p_limit : int = 10, p_cursor = null): # -> NakamaAPI.ApiLeaderboardRecordList:
	return await _api_client.list_leaderboard_records_async(p_session,
		p_leaderboard_id, p_owner_ids, p_limit, p_cursor, p_expiry)

# List leaderboard records that belong to a user.
# @param p_session - The session for the user.
# @param p_leaderboard_id - The ID of the leaderboard to list.
# @param p_owner_id - The ID of the user to list around.
# @param p_expiry - Expiry in seconds (since epoch) to begin fetching records from. Optional. 0 means from current time.
# @param p_limit - The limit of the listings.
# @param p_cursor - A cursor for the current position in the leaderboard records to list.
# Returns a task which resolves to the leaderboard record objects.
func list_leaderboard_records_around_owner_async(p_session : NakamaSession,
		p_leaderboar_id : String, p_owner_id : String, p_expiry = null, p_limit : int = 10, p_cursor = null): # -> NakamaAPI.ApiLeaderboardRecordList:
	return await _api_client.list_leaderboard_records_around_owner_async(p_session,
		p_leaderboar_id, p_owner_id, p_limit, p_expiry, p_cursor)

# Fetch a list of matches active on the server.
# @param p_session - The session of the user.
# @param p_min - The minimum number of match participants.
# @param p_max - The maximum number of match participants.
# @param p_limit - The number of matches to list.
# @param p_authoritative - If authoritative matches should be included.
# @param p_label - The label to filter the match list on.
# @param p_query - A query for the matches to filter.
# Returns a task which resolves to the match list object.
func list_matches_async(p_session : NakamaSession, p_min : int, p_max : int, p_limit : int, p_authoritative : bool,
		p_label : String, p_query : String): # -> NakamaAPI.ApiMatchList:
	return await _api_client.list_matches_async(p_session, p_limit, p_authoritative, p_label if p_label else null, p_min, p_max, p_query if p_query else null)

# List notifications for the user with an optional cursor.
# @param p_session - The session of the user.
# @param p_limit - The number of notifications to list.
# @param p_cacheable_cursor - A cursor for the current position in notifications to list.
# Returns a task to resolve notifications objects.
func list_notifications_async(p_session : NakamaSession, p_limit : int = 10, p_cacheable_cursor = null): # -> NakamaAPI.ApiNotificationList:
	return await _api_client.list_notifications_async(p_session, p_limit, p_cacheable_cursor)

# List storage objects in a collection which have public read access.
# @param p_session - The session of the user.
# @param p_collection - The collection to list over.
# @param p_user_id - The id of the user that owns the objects.
# @param p_limit - The number of objects to list.
# @param p_cursor - A cursor to paginate over the collection.
# Returns a task which resolves to the storage object list.
func list_storage_objects_async(p_session : NakamaSession, p_collection : String, p_user_id : String = "", p_limit : int = 10, p_cursor = null): # -> NakamaAPI.ApiStorageObjectList:
	return await _api_client.list_storage_objects_async(p_session, p_collection, p_user_id, p_limit, p_cursor)

# List user's subscriptions.
# @param p_session - The session of the user.
# @param p_limit - The number of objects to list.
# @param p_cursor - A cursor to paginate over the collection.
# Returns a task which resolves to the subscription list.
func list_subscriptions_async(p_session : NakamaSession, p_limit: int = 10, p_cursor = null): # -> NakamaAPI.ApiSubscriptionList:
	return await _api_client.list_subscriptions_async(p_session, NakamaAPI.ApiListSubscriptionsRequest.create(
		NakamaAPI,
		{
			"cursor": p_cursor,
			"limit": p_limit,
		}
	))

# List tournament records around the owner.
# @param p_session - The session of the user.
# @param p_tournament_id - The ID of the tournament.
# @param p_owner_id - The ID of the owner to pivot around.
# @param p_expiry - Expiry in seconds (since epoch) to begin fetching records from.
# @param p_limit - The number of records to list.
# @param p_cursor - An optional cursor for the next page of tournament records.
# Returns a task which resolves to the tournament record list object.
func list_tournament_records_around_owner_async(p_session : NakamaSession,
		p_tournament_id : String, p_owner_id : String, p_limit : int = 10, p_cursor = null, p_expiry = null): # -> NakamaAPI.ApiTournamentRecordList:
	return await _api_client.list_tournament_records_around_owner_async(p_session, p_tournament_id, p_owner_id, p_limit, p_expiry, p_cursor)

# List records from a tournament.
# @param p_session - The session of the user.
# @param p_tournament_id - The ID of the tournament.
# @param p_owner_ids - The IDs of the record owners to return in the result.
# @param p_expiry - Expiry in seconds (since epoch) to begin fetching records from.
# @param p_limit - The number of records to list.
# @param p_cursor - An optional cursor for the next page of tournament records.
# Returns a task which resolves to the list of tournament records.
func list_tournament_records_async(p_session : NakamaSession, p_tournament_id : String,
		p_owner_ids = null, p_limit : int = 10, p_cursor = null, p_expiry = null): # -> NakamaAPI.ApiTournamentRecordList:
	return await _api_client.list_tournament_records_async(p_session, p_tournament_id, p_owner_ids, p_limit, p_cursor, p_expiry)

# List current or upcoming tournaments.
# @param p_session - The session of the user.
# @param p_category_start - The start of the category of tournaments to include.
# @param p_category_end - The end of the category of tournaments to include.
# @param p_start_time - The start time of the tournaments. (UNIX timestamp)
# @param p_end_time - The end time of the tournaments. (UNIX timestamp)
# @param p_limit - The number of tournaments to list.
# @param p_cursor - An optional cursor for the next page of tournaments.
# Returns a task which resolves to the list of tournament objects.
func list_tournaments_async(p_session : NakamaSession, p_category_start : int, p_category_end : int,
		p_start_time : int, p_end_time : int, p_limit : int = 10, p_cursor = null): # -> NakamaAPI.ApiTournamentList:
	return await _api_client.list_tournaments_async(p_session,
		p_category_start, p_category_end, p_start_time, p_end_time, p_limit, p_cursor)

# List of groups the current user is a member of.
# @param p_session - The session of the user.
# @param p_user_id - The ID of the user whose groups to list.
# @param p_state - Filter by group membership state.
# @param p_limit - The number of records to list.
# @param p_cursor - A cursor for the current position in the listing.
# Returns a task which resolves to the group list object.
func list_user_groups_async(p_session : NakamaSession, p_user_id : String, p_state = null, p_limit = null, p_cursor = null): # -> NakamaAPI.ApiUserGroupList:
	return await _api_client.list_user_groups_async(p_session, p_user_id, p_limit, p_state, p_cursor)

# List storage objects in a collection which belong to a specific user and have public read access.
# @param p_session - The session of the user.
# @param p_collection - The collection to list over.
# @param p_user_id - The user ID of the user to list objects for.
# @param p_limit - The number of objects to list.
# @param p_cursor - A cursor to paginate over the collection.
# Returns a task which resolves to the storage object list.
func list_users_storage_objects_async(p_session : NakamaSession,
		p_collection : String, p_user_id : String, p_limit : int, p_cursor : String): # -> NakamaAPI.ApiStorageObjectList:
	return await _api_client.list_storage_objects2_async(p_session, p_collection, p_user_id, p_limit, p_cursor)

# Promote one or more users in the group.
# @param p_session - The session of the user.
# @param p_group_id - The ID of the group to promote users into.
# @param p_ids - The IDs of the users to promote.
# Returns a task which represents the asynchronous operation.
func promote_group_users_async(p_session : NakamaSession, p_group_id : String, p_ids : PackedStringArray) -> NakamaAsyncResult:
	return await _api_client.promote_group_users_async(p_session, p_group_id, p_ids)

# Read one or more objects from the storage engine.
# @param p_session - The session of the user.
# @param p_ids - The objects to read.
# Returns a task which resolves to the storage batch object.
func read_storage_objects_async(p_session : NakamaSession, p_ids : Array): # -> NakamaAPI.ApiStorageObjects:
	var ids = []
	for id in p_ids:
		if not id is NakamaStorageObjectId:
			continue # TODO Exceptions
		var obj_id : NakamaStorageObjectId = id
		ids.append(obj_id.as_read().serialize())
	return await _api_client.read_storage_objects_async(p_session,
		NakamaAPI.ApiReadStorageObjectsRequest.create(NakamaAPI, {
			"object_ids": ids
		}))

# Execute a function with an input payload on the server.
# @param p_session - The session of the user.
# @param p_id - The ID of the function to execute on the server.
# @param p_payload - The payload to send with the function call.
# Returns a task which resolves to the RPC response.
func rpc_async(p_session : NakamaSession, p_id : String, p_payload = null): # -> NakamaAPI.ApiRpc:
	if p_payload == null:
		return await _api_client.rpc_func2_async(p_session.token, p_id)
	return await _api_client.rpc_func_async(p_session.token, p_id, p_payload)

# Execute a function on the server without a session.
# This function is usually used with server side code. DO NOT USE client side.
# @param p_http_key - The secure HTTP key used to authenticate.
# @param p_id - The id of the function to execute on the server.
# @param p_payload - A payload to send with the function call.
# Returns a task to resolve an RPC response.
func rpc_async_with_key(p_http_key : String, p_id : String, p_payload = null): # -> NakamaAPI.ApiRpc:
	if p_payload == null:
		return await _api_client.rpc_func2_async("", p_id, null, p_http_key)
	return await _api_client.rpc_func_async("", p_id, p_payload, p_http_key)

# Log out a session which optionally invalidates the authorization and/or refresh tokens.
# @param p_session - The session of the user.
# Returns a task which represents the asynchronous operation.
func session_logout_async(p_session : NakamaSession) -> NakamaAsyncResult:
	return await _api_client.session_logout_async(p_session,
		NakamaAPI.ApiSessionLogoutRequest.create(NakamaAPI, {
			"refresh_token": p_session.refresh_token,
			"token": p_session.token
		}))

# Refresh the session unless the current refresh token has expired. If vars are specified they will replace
# what is currently stored inside the session token.
# @param p_session - The session of the user.
# @param p_vars - Extra information which should be bundled inside the session token.
# Returns a task which resolves to a new session object.
func session_refresh_async(p_sesison : NakamaSession, p_vars = null) -> NakamaSession:
	return _parse_auth(await _api_client.session_refresh_async(server_key, "",
		NakamaAPI.ApiSessionRefreshRequest.create(NakamaAPI, {
			"token": p_sesison.refresh_token,
			"vars": p_vars
		})))

# Remove the Apple ID from the social profiles on the current user's account.
# @param p_session - The session of the user.
# @param p_token - The ID token received from Apple.
# Returns a task which represents the asynchronous operation.
func unlink_apple_async(p_session : NakamaSession, p_token : String) -> NakamaAsyncResult:
	return await _api_client.unlink_apple_async(p_session, NakamaAPI.ApiAccountApple.create(NakamaAPI, {
		"token": p_token
	}))

# Unlink a custom ID from the user account owned by the session.
# @param p_session - The session of the user.
# @param p_id - A custom identifier usually obtained from an external authentication service.
# Returns a task which represents the asynchronous operation.
func unlink_custom_async(p_session : NakamaSession, p_id : String) -> NakamaAsyncResult:
	return await _api_client.unlink_custom_async(p_session, NakamaAPI.ApiAccountCustom.create(NakamaAPI, {
		"id": p_id
	}))

# Unlink a device ID from the user account owned by the session.
# @param p_session - The session of the user.
# @param p_id - A device identifier usually obtained from a platform API.
# Returns a task which represents the asynchronous operation.
func unlink_device_async(p_session : NakamaSession, p_id : String) -> NakamaAsyncResult:
	return await _api_client.unlink_device_async(p_session, NakamaAPI.ApiAccountDevice.create(NakamaAPI, {
		"id": p_id
	}))

# Unlink an email with password from the user account owned by the session.
# @param p_session - The session of the user.
# @param p_email - The email address of the user.
# @param p_password - The password for the user.
# Returns a task which represents the asynchronous operation.
func unlink_email_async(p_session : NakamaSession, p_email : String, p_password : String) -> NakamaAsyncResult:
	return await _api_client.unlink_email_async(p_session, NakamaAPI.ApiAccountEmail.create(NakamaAPI, {
		"email": p_email,
		"password": p_password
	}))

# Unlink a Facebook profile from the user account owned by the session.
# @param p_session - The session of the user.
# @param p_token - An OAuth access token from the Facebook SDK.
# Returns a task which represents the asynchronous operation.
func unlink_facebook_async(p_session : NakamaSession, p_token : String) -> NakamaAsyncResult:
	return await _api_client.unlink_facebook_async(p_session, NakamaAPI.ApiAccountFacebook.create(NakamaAPI, {
		"token": p_token
	}))

# Unlink a Facebook profile from the user account owned by the session.
# @param p_session - The session of the user.
# @param p_token - An OAuth access token from the Facebook SDK.
# Returns a task which represents the asynchronous operation.
func unlink_facebook_instant_game_async(p_session : NakamaSession, p_signed_player_info : String) -> NakamaAsyncResult:
	return await _api_client.unlink_facebook_instant_game_async(
		p_session,
		NakamaAPI.ApiAccountFacebookInstantGame.create(NakamaAPI, {
			"signed_player_info": p_signed_player_info
		})
	)

# Unlink a Game Center profile from the user account owned by the session.
# @param p_session - The session of the user.
# @param p_bundle_id - The bundle ID of the Game Center application.
# @param p_player_id - The player ID of the user in Game Center.
# @param p_public_key_url - The URL for the public encryption key.
# @param p_salt - A random `NSString` used to compute the hash and keep it randomized.
# @param p_signature - The verification signature data generated.
# @param p_timestamp_seconds - The date and time that the signature was created.
# Returns a task which represents the asynchronous operation.
func unlink_game_center_async(p_session : NakamaSession,
		p_bundle_id : String, p_player_id : String, p_public_key_url : String, p_salt : String, p_signature : String, p_timestamp_seconds) -> NakamaAsyncResult:
	return await _api_client.unlink_game_center_async(p_session,
		NakamaAPI.ApiAccountGameCenter.create(NakamaAPI, {
			"bundle_id": p_bundle_id,
			"player_id": p_player_id,
			"public_key_url": p_public_key_url,
			"salt": p_salt,
			"signature": p_signature,
			"timestamp_seconds": p_timestamp_seconds,
		}))

# Unlink a Google profile from the user account owned by the session.
# @param p_session - The session of the user.
# @param p_token - An OAuth access token from the Google SDK.
# Returns a task which represents the asynchronous operation.
func unlink_google_async(p_session : NakamaSession, p_token : String) -> NakamaAsyncResult:
	return await _api_client.unlink_google_async(p_session, NakamaAPI.ApiAccountGoogle.create(NakamaAPI, {
		"token": p_token
	}))

# Unlink a Steam profile from the user account owned by the session.
# @param p_session - The session of the user.
# @param p_token - An authentication token from the Steam network.
# Returns a task which represents the asynchronous operation.
func unlink_steam_async(p_session : NakamaSession, p_token : String) -> NakamaAsyncResult:
	return await _api_client.unlink_steam_async(p_session, NakamaAPI.ApiAccountSteam.create(NakamaAPI, {
		"token": p_token
	}))

# Update the current user's account on the server.
# @param p_session - The session for the user.
# @param p_username - The new username for the user.
# @param p_display_name - A new display name for the user.
# @param p_avatar_url - A new avatar url for the user.
# @param p_lang_tag - A new language tag in BCP-47 format for the user.
# @param p_location - A new location for the user.
# @param p_timezone - New timezone information for the user.
# Returns a task which represents the asynchronous operation.
func update_account_async(p_session : NakamaSession, p_username = null, p_display_name = null,
		p_avatar_url = null, p_lang_tag = null, p_location = null, p_timezone = null) -> NakamaAsyncResult:
	return await _api_client.update_account_async(p_session,
		NakamaAPI.ApiUpdateAccountRequest.create(NakamaAPI, {
			"avatar_url": p_avatar_url,
			"display_name": p_display_name,
			"lang_tag": p_lang_tag,
			"location": p_location,
			"timezone": p_timezone,
			"username": p_username
		}))

# Update a group.
# The user must have the correct access permissions for the group.
# @param p_session - The session of the user.
# @param p_group_id - The ID of the group to update.
# @param p_name - A new name for the group.
# @param p_open - If the group should have open membership.
# @param p_description - A new description for the group.
# @param p_avatar_url - A new avatar url for the group.
# @param p_lang_tag - A new language tag in BCP-47 format for the group.
# Returns a task which represents the asynchronous operation.
func update_group_async(p_session : NakamaSession,
		p_group_id : String, p_name = null, p_description = null, p_avatar_url = null, p_lang_tag = null, p_open = null) -> NakamaAsyncResult:
	return await _api_client.update_group_async(p_session, p_group_id,
		NakamaAPI.ApiUpdateGroupRequest.create(NakamaAPI, {
			"name": p_name,
			"open": p_open,
			"avatar_url": p_avatar_url,
			"description": p_description,
			"lang_tag": p_lang_tag
		}))

# Validate a purchase receipt against the Apple App Store.
# @param p_session - The session of the user.
# @param p_receipt - The purchase receipt to be validated.
# Returns a task which resolves to the validated list of purchase receipts.
func validate_purchase_apple_async(p_session : NakamaSession, p_receipt : String): # -> NakamaAPI.ApiValidatePurchaseResponse
	return await _api_client.validate_purchase_apple_async(p_session,
		NakamaAPI.ApiValidatePurchaseAppleRequest.create(NakamaAPI, {
			"receipt": p_receipt
		}))

# Validate a purchase receipt against the Google Play Store.
# @param p_session - The session of the user.
# @param p_receipt - The purchase receipt to be validated.
# Returns a task which resolves to the validated list of purchase receipts.
func validate_purchase_google_async(p_session : NakamaSession, p_receipt : String): # -> NakamaAPI.ApiValidatePurchaseResponse
	return await _api_client.validate_purchase_google_async(p_session,
		NakamaAPI.ApiValidatePurchaseGoogleRequest.create(NakamaAPI, {
			"purchase": p_receipt
		}))

# Validate a purchase receipt against the Huawei AppGallery.
# @param p_session - The session of the user.
# @param p_receipt - The purchase receipt to be validated.
# @param p_signature - The signature of the purchase receipt.
# Returns a task which resolves to the validated list of purchase receipts.
func validate_purchase_huawei_async(p_session : NakamaSession, p_receipt : String, p_signature : String): # -> NakamaAPI.ApiValidatePurchaseResponse
	return await _api_client.validate_purchase_huawei_async(p_session,
		NakamaAPI.ApiValidatePurchaseHuaweiRequest.create(NakamaAPI, {
			"purchase": p_receipt,
			"signature": p_signature
		}))

# Validate Apple Subscription Receipt
# @param p_session - The session of the user.
# @param p_receipt - The purchase receipt to be validated.
# @param p_persist - Whether or not to track the receipt in the Nakama database.
# Returns a task which resolves to the validated subscription response.
func validate_subscription_apple_async(p_session : NakamaSession, p_receipt : String, p_persist : bool = true): # -> NakamaAPI.ApiValidateSubscriptionResponse:
	return await _api_client.validate_subscription_apple_async(p_session,
		NakamaAPI.ApiValidateSubscriptionAppleRequest.create(NakamaAPI, {
			"receipt": p_receipt,
			"persist": p_persist,
		}))

# Validate Google Subscription Receipt
# @param p_session - The session of the user.
# @param p_receipt - The purchase receipt to be validated.
# @param p_persist - Whether or not to track the receipt in the Nakama database.
# Returns a task which resolves to the validated subscription response.
func validate_subscription_google_async(p_session : NakamaSession, p_receipt : String, p_persist : bool = true): # -> NakamaAPI.ApiValidateSubscriptionResponse:
	return await _api_client.validate_subscription_google_async(p_session,
		NakamaAPI.ApiValidateSubscriptionGoogleRequest.create(NakamaAPI, {
			"receipt": p_receipt,
			"persist": p_persist,
		}))

# Write a record to a leaderboard.
# @param p_session - The session for the user.
# @param p_leaderboard_id - The ID of the leaderboard to write.
# @param p_score - The score for the leaderboard record.
# @param p_subscore - The subscore for the leaderboard record.
# @param p_metadata - The metadata for the leaderboard record.
# Returns a task which resolves to the leaderboard record object written.
func write_leaderboard_record_async(p_session : NakamaSession,
		p_leaderboard_id : String, p_score : int, p_subscore : int = 0, p_metadata = null): # -> NakamaAPI.ApiLeaderboardRecord:
	return await _api_client.write_leaderboard_record_async(p_session, p_leaderboard_id,
		NakamaAPI.WriteLeaderboardRecordRequestLeaderboardRecordWrite.create(NakamaAPI, {
			"metadata": p_metadata,
			"score": str(p_score),
			"subscore": str(p_subscore)
		}))

# Write objects to the storage engine.
# @param p_session - The session of the user.
# @param p_objects - The objects to write.
# Returns a task which resolves to the storage write acknowledgements.
func write_storage_objects_async(p_session : NakamaSession, p_objects : Array): # -> NakamaAPI.ApiStorageObjectAcks:
	var writes : Array = []
	for obj in p_objects:
		if not obj is NakamaWriteStorageObject:
			continue # TODO Exceptions
		var write_obj : NakamaWriteStorageObject = obj
		writes.append(write_obj.as_write().serialize())
	return await _api_client.write_storage_objects_async(p_session,
		NakamaAPI.ApiWriteStorageObjectsRequest.create(NakamaAPI, {
			"objects": writes
		}))

# Write a record to a tournament.
# @param p_session - The session of the user.
# @param p_tournament_id - The ID of the tournament to write.
# @param p_score - The score of the tournament record.
# @param p_subscore - The subscore for the tournament record.
# @param p_metadata - The metadata for the tournament record.
# Returns a task which resolves to the tournament record object written.
func write_tournament_record_async(p_session : NakamaSession,
		p_tournament_id : String, p_score : int, p_subscore : int = 0, p_metadata = null): # -> NakamaAPI.ApiLeaderboardRecord:
	return await _api_client.write_tournament_record_async(p_session, p_tournament_id,
		NakamaAPI.WriteTournamentRecordRequestTournamentRecordWrite.create(NakamaAPI, {
			"metadata": p_metadata,
			"score": str(p_score),
			"subscore": str(p_subscore)
		}))

# Write a record to a tournament.
# @param p_session - The session of the user.
# @param p_tournament_id - The ID of the tournament to write.
# @param p_score - The score of the tournament record.
# @param p_subscore - The subscore for the tournament record.
# @param p_metadata - The metadata for the tournament record.
# Returns a task which resolves to the tournament record object written.
func write_tournament_record2_async(p_session : NakamaSession,
		p_tournament_id : String, p_score : int, p_subscore : int = 0, p_metadata = null): # -> NakamaAPI.ApiLeaderboardRecord:
	return await _api_client.write_tournament_record2_async(p_session, p_tournament_id,
		NakamaAPI.WriteTournamentRecordRequestTournamentRecordWrite.create(NakamaAPI, {
			"metadata": p_metadata,
			"score": str(p_score),
			"subscore": str(p_subscore)
		}))


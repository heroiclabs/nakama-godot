extends Reference

### <summary>
### A client for the API in Nakama server.
### </summary>
class_name NakamaClient

const ChannelType = NakamaRTMessage.ChannelJoin.ChannelType

func _no_set(_p):
	return

func _no_get():
	return null

### <summary>
### The host address of the server. Defaults to "127.0.0.1".
### </summary>
var host : String setget _no_set

### <summary>
### The port number of the server. Defaults to 7350.
### </summary>
var port : int setget _no_set

### <summary>
### The protocol scheme used to connect with the server. Must be either "http" or "https".
### </summary>
var scheme : String setget _no_set

### <summary>
### The key used to authenticate with the server without a session. Defaults to "defaultkey".
### </summary>
var server_key : String = "defaultkey" setget _no_set

### <summary>
### Set the timeout in seconds on requests sent to the server.
### </summary>
var timeout : int

var logger : NakamaLogger = null

var _api_client := NakamaAPI.ApiClient.new("", NakamaAPI, null) setget _no_set, _no_get

func _init(p_adapter : NakamaHTTPAdapter,
		p_server_key : String,
		p_scheme : String,
		p_host : String,
		p_port : int,
		p_timeout : int):

	server_key = p_server_key
	scheme = p_scheme
	host = p_host
	port = p_port
	timeout = p_timeout
	logger = p_adapter.logger
	_api_client = NakamaAPI.ApiClient.new(scheme + "://" + host + ":" + str(port), p_adapter, NakamaAPI, p_timeout)

### <summary>
### Restore a session from the auth token.
### </summary>
### <remarks>
### A <c>null</c> or empty authentication token will return null.
### </remarks>
### <param name="authToken">The authentication token to restore as a session.</param>
### <returns>A session.</returns>
static func restore_session(auth_token : String):
	return NakamaSession.new(auth_token, false)

func _to_string():
	return "Client(Host='%s', Port=%s, Scheme='%s', ServerKey='%s', Timeout=%s)" % [
		host, port, scheme, server_key, timeout
	]

func _parse_auth(p_session) -> NakamaSession:
	if p_session.is_exception():
		return NakamaSession.new(null, false, p_session.get_exception())
	return NakamaSession.new(p_session.token, p_session.created)

### <summary>
### Add one or more friends by id or username.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_ids">The ids of the users to add or invite as friends.</param>
### <param name="p_usernames">The usernames of the users to add as friends.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func add_friends_async(p_session : NakamaSession, p_ids : PoolStringArray, p_usernames = null) -> NakamaAsyncResult:
	return _api_client.add_friends_async(p_session.token, p_ids, p_usernames)

### <summary>
### Add one or more users to the group.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_group_id">The id of the group to add users into.</param>
### <param name="p_ids">The ids of the users to add or invite to the group.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func add_group_users_async(p_session : NakamaSession, p_group_id : String, p_ids : PoolStringArray) -> NakamaAsyncResult:
	return _api_client.add_group_users_async(p_session.token, p_group_id, p_ids);

### <summary>
### Authenticate a user with a custom id.
### </summary>
### <param name="p_id">A custom identifier usually obtained from an external authentication service.</param>
### <param name="p_username">A username used to create the user. May be <c>null</c>.</param>
### <param name="p_create">If the user should be created when authenticated.</param>
### <param name="p_vars">Extra information that will be bundled in the session token.</param>
### <returns>A task which resolves to a session object.</returns>
func authenticate_custom_async(p_id : String, p_username = null, p_create : bool = true, p_vars = null) -> NakamaSession:
	return _parse_auth(yield(_api_client.authenticate_custom_async(server_key, "",
		NakamaAPI.ApiAccountCustom.create(NakamaAPI, {
			"id": p_id,
			"vars": p_vars
		}), p_create, p_username), "completed"))

### <summary>
### Authenticate a user with a device id.
### </summary>
### <param name="p_id">A device identifier usually obtained from a platform API.</param>
### <param name="p_username">A username used to create the user. May be <c>null</c>.</param>
### <param name="p_create">If the user should be created when authenticated.</param>
### <param name="p_vars">Extra information that will be bundled in the session token.</param>
### <returns>A task which resolves to a session object.</returns>
func authenticate_device_async(p_id : String, p_username = null, p_create : bool = true, p_vars = null) -> NakamaSession:
	return _parse_auth(yield(_api_client.authenticate_device_async(server_key, "",
		NakamaAPI.ApiAccountDevice.create(NakamaAPI, {
			"id": p_id,
			"vars": p_vars
		}), p_create, p_username), "completed"))

### <summary>
### Authenticate a user with an email and password.
### </summary>
### <param name="p_email">The email address of the user.</param>
### <param name="p_password">The password for the user.</param>
### <param name="p_username">A username used to create the user. May be <c>null</c>.</param>
### <param name="p_create">If the user should be created when authenticated.</param>
### <param name="p_vars">Extra information that will be bundled in the session token.</param>
### <returns>A task which resolves to a session object.</returns>
func authenticate_email_async(p_email : String, p_password : String, p_username = null, p_create : bool = true, p_vars = null) -> NakamaSession:
	return _parse_auth(yield(_api_client.authenticate_email_async(server_key, "",
		NakamaAPI.ApiAccountEmail.create(NakamaAPI, {
			"email": p_email,
			"password": p_password,
			"vars": p_vars
		}), p_create, p_username), "completed"))

### <summary>
### Authenticate a user with a Facebook auth token.
### </summary>
### <param name="p_token">An OAuth access token from the Facebook SDK.</param>
### <param name="p_username">A username used to create the user. May be <c>null</c>.</param>
### <param name="p_create">If the user should be created when authenticated.</param>
### <param name="p_import">If the Facebook friends should be imported.</param>
### <param name="p_vars">Extra information that will be bundled in the session token.</param>
### <returns>A task which resolves to a session object.</returns>
func authenticate_facebook_async(p_token : String, p_username = null, p_create : bool = true, p_import : bool = true, p_vars = null) -> NakamaSession:
	return _parse_auth(yield(_api_client.authenticate_facebook_async(server_key, "",
		NakamaAPI.ApiAccountFacebook.create(NakamaAPI, {
			"token": p_token,
			"vars": p_vars
		}), p_create, p_username, p_import), "completed"))

### <summary>
### Authenticate a user with Apple Game Center.
### </summary>
### <param name="p_bundle_id">The bundle id of the Game Center application.</param>
### <param name="p_player_id">The player id of the user in Game Center.</param>
### <param name="p_public_key_url">The URL for the public encryption key.</param>
### <param name="p_salt">A random <c>NSString</c> used to compute the hash and keep it randomized.</param>
### <param name="p_signature">The verification signature data generated.</param>
### <param name="p_timestamp_seconds">The date and time that the signature was created.</param>
### <param name="p_username">A username used to create the user. May be <c>null</c>.</param>
### <param name="p_create">If the user should be created when authenticated.</param>
### <param name="p_vars">Extra information that will be bundled in the session token.</param>
### <returns>A task which resolves to a session object.</returns>
func authenticate_game_center_async(p_bundle_id : String, p_player_id : String, p_public_key_url : String,
		p_salt : String, p_signature : String, p_timestamp_seconds : String, p_username = null, p_create : bool = true, p_vars = null) -> NakamaSession:
	return _parse_auth(yield(_api_client.authenticate_game_center_async(server_key, "",
		NakamaAPI.ApiAccountGameCenter.create(NakamaAPI, {
			"bundle_id": p_bundle_id,
			"player_id": p_player_id,
			"public_key_url": p_public_key_url,
			"salt": p_salt,
			"signature": p_signature,
			"timestamp_seconds": p_timestamp_seconds,
			"vars": p_vars
		}), p_create, p_username), "completed"))

### <summary>
### Authenticate a user with a Google auth token.
### </summary>
### <param name="p_token">An OAuth access token from the Google SDK.</param>
### <param name="p_username">A username used to create the user. May be <c>null</c>.</param>
### <param name="p_create">If the user should be created when authenticated.</param>
### <param name="p_vars">Extra information that will be bundled in the session token.</param>
### <returns>A task which resolves to a session object.</returns>
func authenticate_google_async(p_token : String, p_username = null, p_create : bool = true, p_vars = null) -> NakamaSession:
	return _parse_auth(yield(_api_client.authenticate_google_async(server_key, "",
		NakamaAPI.ApiAccountGoogle.create(NakamaAPI, {
			"token": p_token,
			"vars": p_vars
		}), p_create, p_username), "completed"))

### <summary>
### Authenticate a user with a Steam auth token.
### </summary>
### <param name="p_token">An authentication token from the Steam network.</param>
### <param name="p_username">A username used to create the user. May be <c>null</c>.</param>
### <param name="p_create">If the user should be created when authenticated.</param>
### <param name="p_vars">Extra information that will be bundled in the session token.</param>
### <returns>A task which resolves to a session object.</returns>
func authenticate_steam_async(p_token : String, p_username = null, p_create : bool = true, p_vars = null) -> NakamaSession:
	return _parse_auth(yield(_api_client.authenticate_steam_async(server_key, "",
		NakamaAPI.ApiAccountSteam.create(NakamaAPI, {
			"token": p_token,
			"vars": p_vars
		}), p_create, p_username), "completed"))

### <summary>
### Block one or more friends by id or username.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_ids">The ids of the users to block.</param>
### <param name="p_usernames">The usernames of the users to block.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func block_friends_async(p_session : NakamaSession, p_ids : PoolStringArray, p_usernames = null) -> NakamaAsyncResult:
	return _api_client.block_friends_async(p_session.token, p_ids, p_usernames);

### <summary>
### Create a group.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_name">The name for the group.</param>
### <param name="p_description">A description for the group.</param>
### <param name="p_avatar_url">An avatar url for the group.</param>
### <param name="p_lang_tag">A language tag in BCP-47 format for the group.</param>
### <param name="p_open">If the group should have open membership.</param>
### <param name="p_max_count">The maximum number of members allowed.</param>
### <returns>A task which resolves to a new group object.</returns>
func create_group_async(p_session : NakamaSession, p_name : String, p_description : String = "",
		p_avatar_url = null, p_lang_tag = null, p_open : bool = true, p_max_count : int = 100): # -> NakamaAPI.ApiGroup:
	return _api_client.create_group_async(p_session.token,
		NakamaAPI.ApiCreateGroupRequest.create(NakamaAPI, {
			"avatar_url": p_avatar_url,
			"description": p_description,
			"lang_tag": p_lang_tag,
			"max_count": p_max_count,
			"name": p_name,
			"open": p_open
		}))

### <summary>
### Delete one more or users by id or username from friends.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_ids">The user ids to remove as friends.</param>
### <param name="p_usernames">The usernames to remove as friends.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func delete_friends_async(p_session : NakamaSession, p_ids : PoolStringArray, p_usernames = null) -> NakamaAsyncResult:
	return _api_client.delete_friends_async(p_session.token, p_ids, p_usernames)

### <summary>
### Delete a group by id.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_group_id">The group id to to remove.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func delete_group_async(p_session : NakamaSession, p_group_id : String) -> NakamaAsyncResult:
	return _api_client.delete_group_async(p_session.token, p_group_id)

### <summary>
### Delete a leaderboard record.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_leaderboard_id">The id of the leaderboard with the record to be deleted.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func delete_leaderboard_record_async(p_session : NakamaSession, p_leaderboard_id : String) -> NakamaAsyncResult:
	return _api_client.delete_leaderboard_record_async(p_session.token, p_leaderboard_id)

### <summary>
### Delete one or more notifications by id.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_ids">The notification ids to remove.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func delete_notifications_async(p_session : NakamaSession, p_ids : PoolStringArray) -> NakamaAsyncResult:
	return _api_client.delete_notifications_async(p_session.token, p_ids)

### <summary>
### Delete one or more storage objects.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_ids">The ids of the objects to delete.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func delete_storage_objects_async(p_session : NakamaSession, p_ids : Array) -> NakamaAsyncResult:
	var ids : Array = []
	for id in p_ids:
		if not id is NakamaStorageObjectId:
			continue # TODO Exceptions
		var obj_id : NakamaStorageObjectId = id
		ids.append(obj_id.as_delete().serialize())
	return _api_client.delete_storage_objects_async(p_session.token,
		NakamaAPI.ApiDeleteStorageObjectsRequest.create(NakamaAPI, {
			"object_ids": ids
		}))

### <summary>
### Fetch the user account owned by the session.
### </summary>
### <param name="p_session">The session of the user.</param>
### <returns>A task which resolves to the account object.</returns>
func get_account_async(p_session : NakamaSession): # -> NakamaAPI.ApiAccount:
	return _api_client.get_account_async(p_session.token)

### <summary>
### Fetch one or more users by id, usernames, and Facebook ids.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_ids">The IDs of the users to retrieve.</param>
### <param name="p_usernames">The usernames of the users to retrieve.</param>
### <param name="p_facebook_ids">The facebook IDs of the users to retrieve.</param>
### <returns>A task which resolves to a collection of user objects.</returns>
func get_users_async(p_session : NakamaSession, p_ids : PoolStringArray, p_usernames = null, p_facebook_ids = null): # -> NakamaAPI.ApiUsers:
	return _api_client.get_users_async(p_session.token, p_ids, p_usernames, p_facebook_ids)

### <summary>
### Import Facebook friends and add them to the user's account.
### </summary>
### <remarks>
### The server will import friends when the user authenticates with Facebook. This function can be used to be
### explicit with the import operation.
### </remarks>
### <param name="p_session">The session of the user.</param>
### <param name="p_token">An OAuth access token from the Facebook SDK.</param>
### <param name="p_reset">If the Facebook friend import for the user should be reset.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func import_facebook_friends_async(p_session : NakamaSession, p_token : String, p_reset = null) -> NakamaAsyncResult:
	return _api_client.import_facebook_friends_async(p_session.token,
		NakamaAPI.ApiAccountFacebook.create(NakamaAPI, {
			"token": p_token
		}), p_reset)

### <summary>
### Join a group if it has open membership or request to join it.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_group_id">The ID of the group to join.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func join_group_async(p_session : NakamaSession, p_group_id : String) -> NakamaAsyncResult:
	return _api_client.join_group_async(p_session.token, p_group_id)

### <summary>
### Join a tournament by ID.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_tournament_id">The ID of the tournament to join.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func JoinTournamentAsync(p_session : NakamaSession, p_tournament_id : String) -> NakamaAsyncResult:
	return _api_client.join_tournament_async(p_session.token, p_tournament_id)

### <summary>
### Kick one or more users from the group.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_group_id">The ID of the group.</param>
### <param name="p_ids">The IDs of the users to kick.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func kick_group_users_async(p_session : NakamaSession, p_group_id : String, p_ids : PoolStringArray) -> NakamaAsyncResult:
	return _api_client.kick_group_users_async(p_session.token, p_group_id, p_ids)

### <summary>
### Leave a group by ID.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_group_id">The ID of the group to leave.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func leave_group_async(p_session : NakamaSession, p_group_id : String) -> NakamaAsyncResult:
	return _api_client.leave_group_async(p_session.token, p_group_id)

### <summary>
### Link a custom ID to the user account owned by the session.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_id">A custom identifier usually obtained from an external authentication service.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func link_custom_async(p_session : NakamaSession, p_id : String) -> NakamaAsyncResult:
	return _api_client.link_custom_async(p_session.token, NakamaAPI.ApiAccountCustom.create(NakamaAPI, {
		"id": p_id
	}))

### <summary>
### Link a device ID to the user account owned by the session.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_id">A device identifier usually obtained from a platform API.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func link_device_async(p_session : NakamaSession, p_id : String) -> NakamaAsyncResult:
	return _api_client.link_device_async(p_session.token, NakamaAPI.ApiAccountDevice.create(NakamaAPI, {
		"id": p_id
	}))

### <summary>
### Link an email with password to the user account owned by the session.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_email">The email address of the user.</param>
### <param name="p_password">The password for the user.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func link_email_async(p_session : NakamaSession, p_email : String, p_password : String) -> NakamaAsyncResult:
	return _api_client.link_email_async(p_session.token, NakamaAPI.ApiAccountEmail.create(NakamaAPI, {
		"email": p_email,
		"password": p_password
	}))

### <summary>
### Link a Facebook profile to a user account.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_token">An OAuth access token from the Facebook SDK.</param>
### <param name="p_import">If the Facebook friends should be imported.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func link_facebook_async(p_session : NakamaSession, p_token : String) -> NakamaAsyncResult:
	return _api_client.link_facebook_async(p_session.token, NakamaAPI.ApiAccountFacebook.create(NakamaAPI, {
		"token": p_token
	}))

### <summary>
### Link a Game Center profile to a user account.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_bundle_id">The bundle ID of the Game Center application.</param>
### <param name="p_player_id">The player ID of the user in Game Center.</param>
### <param name="p_public_key_url">The URL for the public encryption key.</param>
### <param name="p_salt">A random <c>NSString</c> used to compute the hash and keep it randomized.</param>
### <param name="p_signature">The verification signature data generated.</param>
### <param name="p_timestamp_seconds">The date and time that the signature was created.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func link_game_center_async(p_session : NakamaSession,
		p_bundle_id : String, p_player_id : String, p_public_key_url : String, p_salt : String, p_signature : String, p_timestamp_seconds) -> NakamaAsyncResult:
	return _api_client.link_game_center_async(p_session.token,
		NakamaAPI.ApiAccountGameCenter.create(NakamaAPI, {
			"bundle_id": p_bundle_id,
			"player_id": p_player_id,
			"public_key_url": p_public_key_url,
			"salt": p_salt,
			"signature": p_signature,
			"timestamp_seconds": p_timestamp_seconds,
		}))

### <summary>
### Link a Google profile to a user account.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_token">An OAuth access token from the Google SDK.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func link_google_async(p_session : NakamaSession, p_token : String) -> NakamaAsyncResult:
	return _api_client.link_google_async(p_session.token, NakamaAPI.ApiAccountGoogle.create(NakamaAPI, {
		"token": p_token
	}))

### <summary>
### Link a Steam profile to a user account.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_token">An authentication token from the Steam network.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func link_steam_async(p_session : NakamaSession, p_token : String) -> NakamaAsyncResult:
	return _api_client.link_steam_async(p_session.token, NakamaAPI.ApiAccountSteam.create(NakamaAPI, {
		"token": p_token
	}))

### <summary>
### List messages from a chat channel.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_channel_id">The id of the chat channel.</param>
### <param name="p_limit">The number of chat messages to list.</param>
### <param name="forward">Fetch messages forward from the current cursor (or the start).</param>
### <param name="p_cursor">A cursor for the current position in the messages history to list.</param>
### <returns>A task which resolves to the channel message list object.</returns>
func list_channel_messages_async(p_session : NakamaSession, p_channel_id : String, limit : int = 1,
		forward : bool = true, cursor = null): # -> NakamaAPI.ApiChannelMessageList:
	return _api_client.list_channel_messages_async(p_session.token, p_channel_id, limit, forward, cursor)

### <summary>
### List of friends of the current user.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_state">Filter by friendship state.</param>
### <param name="p_limit">The number of friends to list.</param>
### <param name="p_cursor">A cursor for the current position in the friends list.</param>
### <returns>A task which resolves to the friend objects.</returns>
func list_friends_async(p_session : NakamaSession, p_state = null, p_limit = null, p_cursor = null): # -> NakamaAPI.ApiFriendList:
	return _api_client.list_friends_async(p_session.token, p_limit, p_state, p_cursor)

### <summary>
### List all users part of the group.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_group_id">The ID of the group.</param>
### <param name="p_state">Filter by group membership state.</param>
### <param name="p_limit">The number of groups to list.</param>
### <param name="p_cursor">A cursor for the current position in the group listing.</param>
### <returns>A task which resolves to the group user objects.</returns>
func list_group_users_async(p_session : NakamaSession, p_group_id : String, p_state = null, p_limit = null, p_cursor = null): # -> NakamaAPI.ApiGroupUserList:
	return _api_client.list_group_users_async(p_session.token, p_group_id, p_limit, p_state, p_cursor)

### <summary>
### List groups on the server.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_name">The name filter to apply to the group list.</param>
### <param name="p_limit">The number of groups to list.</param>
### <param name="p_cursor">A cursor for the current position in the groups to list.</param>
### <returns>A task to resolve group objects.</returns>
func list_groups_async(p_session : NakamaSession, p_name = null, p_limit : int = 1, p_cursor = null): # -> NakamaAPI.ApiGroupList:
	return _api_client.list_groups_async(p_session.token, p_name, p_cursor, p_limit)

### <summary>
### List records from a leaderboard.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_leaderboard_id">The ID of the leaderboard to list.</param>
### <param name="p_owner_ids">Record owners to fetch with the list of records.</param>
### <param name="p_expiry">Expiry in seconds (since epoch) to begin fetching records from. Optional. 0 means from current time.</param>
### <param name="p_limit">The number of records to list.</param>
### <param name="p_cursor">A cursor for the current position in the leaderboard records to list.</param>
### <returns>A task which resolves to the leaderboard record objects.</returns>
func list_leaderboard_records_async(p_session : NakamaSession,
		p_leaderboard_id : String, p_owner_ids = null, p_expiry = null, p_limit : int = 1, p_cursor = null): # -> NakamaAPI.ApiLeaderboardRecordList:
	return _api_client.list_leaderboard_records_async(p_session.token,
		p_leaderboard_id, p_owner_ids, p_limit, p_cursor, p_expiry)

### <summary>
### List leaderboard records that belong to a user.
### </summary>
### <param name="p_session">The session for the user.</param>
### <param name="p_leaderboard_id">The ID of the leaderboard to list.</param>
### <param name="p_owner_id">The ID of the user to list around.</param>
### <param name="p_expiry">Expiry in seconds (since epoch) to begin fetching records from. Optional. 0 means from current time.</param>
### <param name="p_limit">The limit of the listings.</param>
### <returns>A task which resolves to the leaderboard record objects.</returns>
func list_leaderboard_records_around_owner_async(p_session : NakamaSession,
		p_leaderboar_id : String, p_owner_id : String, p_expiry = null, p_limit : int = 1): # -> NakamaAPI.ApiLeaderboardRecordList:
	return _api_client.list_leaderboard_records_around_owner_async(p_session.token,
		p_leaderboar_id, p_owner_id, p_limit, p_expiry)

### <summary>
### Fetch a list of matches active on the server.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_min">The minimum number of match participants.</param>
### <param name="p_max">The maximum number of match participants.</param>
### <param name="p_limit">The number of matches to list.</param>
### <param name="p_authoritative">If authoritative matches should be included.</param>
### <param name="p_label">The label to filter the match list on.</param>
### <param name="p_query">A query for the matches to filter.</param>
### <returns>A task which resolves to the match list object.</returns>
func list_matches_async(p_session : NakamaSession, p_min : int, p_max : int, p_limit : int, p_authoritative : bool,
		p_label : String, p_query : String): # -> NakamaAPI.ApiMatchList:
	return _api_client.list_matches_async(p_session.token, p_limit, p_authoritative, p_label, p_min, p_max, p_query)

### <summary>
### List notifications for the user with an optional cursor.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_limit">The number of notifications to list.</param>
### <param name="p_cacheable_cursor">A cursor for the current position in notifications to list.</param>
### <returns>A task to resolve notifications objects.</returns>
func list_notifications_async(p_session : NakamaSession, p_limit : int = 1, p_cacheable_cursor = null): # -> NakamaAPI.ApiNotificationList:
	return _api_client.list_notifications_async(p_session.token, p_limit, p_cacheable_cursor)

### <summary>
### List storage objects in a collection which have public read access.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_collection">The collection to list over.</param>
### <param name="p_user_id">The id of the user that owns the objects.</param>
### <param name="p_limit">The number of objects to list.</param>
### <param name="p_cursor">A cursor to paginate over the collection.</param>
### <returns>A task which resolves to the storage object list.</returns>
func list_storage_objects_async(p_session : NakamaSession, p_collection : String, p_user_id : String = "", p_limit : int = 1, p_cursor = null): # -> NakamaAPI.ApiStorageObjectList:
	return _api_client.list_storage_objects_async(p_session.token, p_collection, p_user_id, p_limit, p_cursor)

### <summary>
### List tournament records around the owner.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_tournament_id">The ID of the tournament.</param>
### <param name="p_owner_id">The ID of the owner to pivot around.</param>
### <param name="p_expiry">Expiry in seconds (since epoch) to begin fetching records from.</param>
### <param name="p_limit">The number of records to list.</param>
### <returns>A task which resolves to the tournament record list object.</returns>
func list_tournament_records_around_owner_async(p_session : NakamaSession,
		p_tournament_id : String, p_owner_id : String, p_expiry = null, p_limit : int = 1): # -> NakamaAPI.ApiTournamentRecordList:
	return _api_client.list_tournament_records_around_owner_async(p_session.token, p_tournament_id, p_owner_id, p_limit, p_expiry)

### <summary>
### List records from a tournament.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_tournament_id">The ID of the tournament.</param>
### <param name="p_owner_ids">The IDs of the record owners to return in the result.</param>
### <param name="p_expiry">Expiry in seconds (since epoch) to begin fetching records from.</param>
### <param name="p_limit">The number of records to list.</param>
### <param name="p_cursor">An optional cursor for the next page of tournament records.</param>
### <returns>A task which resolves to the list of tournament records.</returns>
func list_tournament_records_async(p_session : NakamaSession, p_tournament_id : String,
		p_owner_ids = null, p_expiry = null, p_limit : int = 1, p_cursor = null): # -> NakamaAPI.ApiTournamentRecordList:
	return _api_client.list_tournament_records_async(p_session.token, p_tournament_id, p_owner_ids, p_limit, p_cursor, p_expiry)

### <summary>
### List current or upcoming tournaments.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_category_start">The start of the category of tournaments to include.</param>
### <param name="p_category_end">The end of the category of tournaments to include.</param>
### <param name="p_start_time">The start time of the tournaments. (UNIX timestamp)</param>
### <param name="p_end_time">The end time of the tournaments. (UNIX timestamp)</param>
### <param name="p_limit">The number of tournaments to list.</param>
### <param name="p_cursor">An optional cursor for the next page of tournaments.</param>
### <returns>A task which resolves to the list of tournament objects.</returns>
func list_tournaments_async(p_session : NakamaSession, p_category_start : int, p_category_end : int,
		p_start_time : int, p_end_time : int, p_limit : int = 1, p_cursor = null): # -> NakamaAPI.ApiTournamentList:
	return _api_client.list_tournaments_async(p_session.token,
		p_category_start, p_category_end, p_start_time, p_end_time, p_limit, p_cursor)

### <summary>
### List of groups the current user is a member of.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_user_id">The ID of the user whose groups to list.</param>
### <param name="p_state">Filter by group membership state.</param>
### <param name="p_limit">The number of records to list.</param>
### <param name="p_cursor">A cursor for the current position in the listing.</param>
### <returns>A task which resolves to the group list object.</returns>
func list_user_groups_async(p_session : NakamaSession, p_user_id : String, p_state = null, p_limit = null, p_cursor = null): # -> NakamaAPI.ApiUserGroupList:
	return _api_client.list_user_groups_async(p_session.token, p_user_id, p_limit, p_state, p_cursor)

### <summary>
### List storage objects in a collection which belong to a specific user and have public read access.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_collection">The collection to list over.</param>
### <param name="p_user_id">The user ID of the user to list objects for.</param>
### <param name="p_limit">The number of objects to list.</param>
### <param name="p_cursor">A cursor to paginate over the collection.</param>
### <returns>A task which resolves to the storage object list.</returns>
func list_users_storage_objects_async(p_session : NakamaSession,
		p_collection : String, p_user_id : String, p_limit : int, p_cursor : String): # -> NakamaAPI.ApiStorageObjectList:
	return _api_client.list_storage_objects2_async(p_session.token, p_collection, p_user_id, p_limit, p_cursor)

### <summary>
### Promote one or more users in the group.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_group_id">The ID of the group to promote users into.</param>
### <param name="p_ids">The IDs of the users to promote.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func promote_group_users_async(p_session : NakamaSession, p_group_id : String, p_ids : PoolStringArray) -> NakamaAsyncResult:
	return _api_client.promote_group_users_async(p_session.token, p_group_id, p_ids)

### <summary>
### Read one or more objects from the storage engine.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_ids">The objects to read.</param>
### <returns>A task which resolves to the storage batch object.</returns>
func read_storage_objects_async(p_session : NakamaSession, p_ids : Array): # -> NakamaAPI.ApiStorageObjects:
	var ids = []
	for id in p_ids:
		if not id is NakamaStorageObjectId:
			continue # TODO Exceptions
		var obj_id : NakamaStorageObjectId = id
		ids.append(obj_id.as_read().serialize())
	return _api_client.read_storage_objects_async(p_session.token,
		NakamaAPI.ApiReadStorageObjectsRequest.create(NakamaAPI, {
			"object_ids": ids
		}))

### <summary>
### Execute a function with an input payload on the server.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_id">The ID of the function to execute on the server.</param>
### <param name="p_payload">The payload to send with the function call.</param>
### <returns>A task which resolves to the RPC response.</returns>
func rpc_async(p_session : NakamaSession, p_id : String, p_payload = null): # -> NakamaAPI.ApiRpc:
	return _api_client.rpc_func_async(p_session.token, p_id, p_payload)

### <summary>
### Execute a function on the server without a session.
### </summary>
### <remarks>
### This function is usually used with server side code. DO NOT USE client side.
### </remarks>
### <param name="p_http_key">The secure HTTP key used to authenticate.</param>
### <param name="p_id">The id of the function to execute on the server.</param>
### <param name="p_payload">A payload to send with the function call.</param>
### <returns>A task to resolve an RPC response.</returns>
func rpc_async_with_key(p_http_key : String, p_id : String, p_payload = null): # -> NakamaAPI.ApiRpc:
	return _api_client.rpc_func2_async("", p_id, p_payload, p_http_key)

### <summary>
### Unlink a custom ID from the user account owned by the session.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_id">A custom identifier usually obtained from an external authentication service.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func unlink_custom_async(p_session : NakamaSession, p_id : String) -> NakamaAsyncResult:
	return _api_client.unlink_custom_async(p_session.token, NakamaAPI.ApiAccountCustom.create(NakamaAPI, {
		"id": p_id
	}))

### <summary>
### Unlink a device ID from the user account owned by the session.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_id">A device identifier usually obtained from a platform API.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func unlink_device_async(p_session : NakamaSession, p_id : String) -> NakamaAsyncResult:
	return _api_client.unlink_device_async(p_session.token, NakamaAPI.ApiAccountDevice.create(NakamaAPI, {
		"id": p_id
	}))

### <summary>
### Unlink an email with password from the user account owned by the session.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_email">The email address of the user.</param>
### <param name="p_password">The password for the user.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func unlink_email_async(p_session : NakamaSession, p_email : String, p_password : String) -> NakamaAsyncResult:
	return _api_client.unlink_email_async(p_session.token, NakamaAPI.ApiAccountEmail.create(NakamaAPI, {
		"email": p_email,
		"password": p_password
	}))

### <summary>
### Unlink a Facebook profile from the user account owned by the session.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_token">An OAuth access token from the Facebook SDK.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func unlink_facebook_async(p_session : NakamaSession, p_token : String) -> NakamaAsyncResult:
	return _api_client.unlink_facebook_async(p_session.token, NakamaAPI.ApiAccountFacebook.create(NakamaAPI, {
		"token": p_token
	}))

### <summary>
### Unlink a Game Center profile from the user account owned by the session.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_bundle_id">The bundle ID of the Game Center application.</param>
### <param name="p_player_id">The player ID of the user in Game Center.</param>
### <param name="p_public_key_url">The URL for the public encryption key.</param>
### <param name="p_salt">A random <c>NSString</c> used to compute the hash and keep it randomized.</param>
### <param name="p_signature">The verification signature data generated.</param>
### <param name="p_timestamp_seconds">The date and time that the signature was created.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func unlink_game_center_async(p_session : NakamaSession,
		p_bundle_id : String, p_player_id : String, p_public_key_url : String, p_salt : String, p_signature : String, p_timestamp_seconds) -> NakamaAsyncResult:
	return _api_client.unlink_game_center_async(p_session.token,
		NakamaAPI.ApiAccountGameCenter.create(NakamaAPI, {
			"bundle_id": p_bundle_id,
			"player_id": p_player_id,
			"public_key_url": p_public_key_url,
			"salt": p_salt,
			"signature": p_signature,
			"timestamp_seconds": p_timestamp_seconds,
		}))

### <summary>
### Unlink a Google profile from the user account owned by the session.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_token">An OAuth access token from the Google SDK.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func unlink_google_async(p_session : NakamaSession, p_token : String) -> NakamaAsyncResult:
	return _api_client.unlink_google_async(p_session.token, NakamaAPI.ApiAccountGoogle.create(NakamaAPI, {
		"token": p_token
	}))

### <summary>
### Unlink a Steam profile from the user account owned by the session.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_token">An authentication token from the Steam network.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func unlink_steam_async(p_session : NakamaSession, p_token : String) -> NakamaAsyncResult:
	return _api_client.unlink_steam_async(p_session.token, NakamaAPI.ApiAccountSteam.create(NakamaAPI, {
		"token": p_token
	}))

### <summary>
### Update the current user's account on the server.
### </summary>
### <param name="p_session">The session for the user.</param>
### <param name="p_username">The new username for the user.</param>
### <param name="p_display_name">A new display name for the user.</param>
### <param name="p_avatar_url">A new avatar url for the user.</param>
### <param name="p_lang_tag">A new language tag in BCP-47 format for the user.</param>
### <param name="p_location">A new location for the user.</param>
### <param name="p_timezone">New timezone information for the user.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func update_account_async(p_session : NakamaSession, p_username : String, p_display_name = null,
		p_avatar_url = null, p_lang_tag = null, p_location = null, p_timezone = null) -> NakamaAsyncResult:
	return _api_client.update_account_async(p_session.token,
		NakamaAPI.ApiUpdateAccountRequest.create(NakamaAPI, {
			"avatar_url": p_avatar_url,
			"display_name": p_display_name,
			"lang_tag": p_lang_tag,
			"location": p_location,
			"timezone": p_timezone,
			"username": p_username
		}))

### <summary>
### Update a group.
### </summary>
### <remarks>
### The user must have the correct access permissions for the group.
### </remarks>
### <param name="p_session">The session of the user.</param>
### <param name="p_group_id">The ID of the group to update.</param>
### <param name="p_name">A new name for the group.</param>
### <param name="p_open">If the group should have open membership.</param>
### <param name="p_description">A new description for the group.</param>
### <param name="p_avatar_url">A new avatar url for the group.</param>
### <param name="p_lang_tag">A new language tag in BCP-47 format for the group.</param>
### <returns>A task which represents the asynchronous operation.</returns>
func update_group_async(p_session : NakamaSession,
		p_group_id : String, p_name : String, p_open : bool, p_description = null, p_avatar_url = null, p_lang_tag = null) -> NakamaAsyncResult:
	return  _api_client.update_group_async(p_session.token, p_group_id,
		NakamaAPI.ApiUpdateGroupRequest.create(NakamaAPI, {
			"name": p_name,
			"open": p_open,
			"avatar_url": p_avatar_url,
			"description": p_description,
			"lang_tag": p_lang_tag
		}))

### <summary>
### Write a record to a leaderboard.
### </summary>
### <param name="p_session">The session for the user.</param>
### <param name="p_leaderboard_id">The ID of the leaderboard to write.</param>
### <param name="p_score">The score for the leaderboard record.</param>
### <param name="p_subscore">The subscore for the leaderboard record.</param>
### <param name="p_metadata">The metadata for the leaderboard record.</param>
### <returns>A task which resolves to the leaderboard record object written.</returns>
func write_leaderboard_record_async(p_session : NakamaSession,
		p_leaderboard_id : String, p_score : int, p_subscore : int = 0, p_metadata = null): # -> NakamaAPI.ApiLeaderboardRecord:
	return _api_client.write_leaderboard_record_async(p_session.token, p_leaderboard_id,
		NakamaAPI.WriteLeaderboardRecordRequestLeaderboardRecordWrite.create(NakamaAPI, {
			"metadata": p_metadata,
			"score": str(p_score),
			"subscore": str(p_subscore)
		}))

### <summary>
### Write objects to the storage engine.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_objects">The objects to write.</param>
### <returns>A task which resolves to the storage write acknowledgements.</returns>
func write_storage_objects_async(p_session : NakamaSession, p_objects : Array): # -> NakamaAPI.ApiStorageObjectAcks:
	var writes : Array = []
	for obj in p_objects:
		if not obj is NakamaWriteStorageObject:
			continue # TODO Exceptions
		var write_obj : NakamaWriteStorageObject = obj
		writes.append(write_obj.as_write().serialize())
	return _api_client.write_storage_objects_async(p_session.token,
		NakamaAPI.ApiWriteStorageObjectsRequest.create(NakamaAPI, {
			"objects": writes
		}))

### <summary>
### Write a record to a tournament.
### </summary>
### <param name="p_session">The session of the user.</param>
### <param name="p_tournament_id">The ID of the tournament to write.</param>
### <param name="p_score">The score of the tournament record.</param>
### <param name="p_subscore">The subscore for the tournament record.</param>
### <param name="p_metadata">The metadata for the tournament record.</param>
### <returns>A task which resolves to the tournament record object written.</returns>
func write_tournament_record_async(p_session : NakamaSession,
		p_tournament_id : String, p_score : int, p_subscore : int = 0, p_metadata = null): # -> NakamaAPI.ApiLeaderboardRecord:
	return _api_client.write_tournament_record_async(p_session.token, p_tournament_id,
		NakamaAPI.WriteTournamentRecordRequestTournamentRecordWrite.create(NakamaAPI, {
			"metadata": p_metadata,
			"score": str(p_score),
			"subscore": str(p_subscore)
		}))

extends RefCounted

## A client for the API in Satori Server.
class_name SatoriClient

#region Properties

var _host
## The host address of the server.
var host : String:
	get:
		return _host

var _port
## The port number of the server.
var port : int:
	get:
		return _port

var _scheme
## The protocol scheme used to connect with the server. Must be either "http" or "https".
var scheme : String:
	get:
		return _scheme

## The key used to authenticate with the server without a session.
var api_key : String

## Set the timeout in seconds on requests sent to the server.
var timeout : int

var _api_client : SatoriAPI.ApiClient

var auto_refresh : bool = false:
	set(v):
		set_auto_refresh(v)
	get:
		return get_auto_refresh()

func get_auto_refresh():
	return _api_client.auto_refresh

func set_auto_refresh(p_value):
	_api_client.auto_refresh = p_value

#endregion

#region Initialization

func _init(p_adapter : SatoriHTTPAdapter,
	p_api_key : String,
	p_scheme : String,
	p_host : String,
	p_port : int,
	p_timeout : int):

	api_key = p_api_key
	_scheme = p_scheme
	_host = p_host
	_port = p_port
	timeout = p_timeout
	_api_client = SatoriAPI.ApiClient.new(_scheme + "://" + _host + ":" + str(_port), p_adapter, SatoriAPI, api_key, p_timeout)

#endregion

#region Client APIs

## Authenticate against the server.
## [p_id]: An optional user id.
## [p_default_properties]: Optional default properties to update with this call.
## If not set, properties are left as they are on the server.
## [p_custom_properties]: Optional custom properties to update with this call.
## If not set, properties are left as they are on the server.
func authenticate_async(p_id: String, p_default_properties: Dictionary = {}, p_custom_properties: Dictionary = {}) -> SatoriSession:
	return _parse_session(await _api_client.authenticate_async(api_key, "",
		SatoriAPI.ApiAuthenticateRequest.create(SatoriAPI, {
			"id": p_id,
			"default": p_default_properties,
			"custom": p_custom_properties
		})))

## Log out a session, invalidate a refresh token, or log out all sessions/refresh tokens for a user.
## [p_session]: The session of the user.
func authenticate_logout_async(p_session: SatoriSession) -> SatoriAsyncResult:
	return await _api_client.authenticate_logout_async(p_session,
		SatoriAPI.ApiAuthenticateLogoutRequest.create(SatoriAPI, {
			"refresh_token": p_session.refresh_token,
			"token": p_session.token
		}))

# Parses the Satori API session and returns a SatoriSession object.
func _parse_session(p_session: SatoriAPI.ApiSession) -> SatoriSession:
	if p_session.is_exception():
		return SatoriSession.new(null, null, p_session.get_exception())
	
	return SatoriSession.new(p_session.token, p_session.refresh_token)

## Refresh a user's session using a refresh token retrieved from a previous authentication request.
## [p_sesison]: The session of the user.
func session_refresh_async(p_session : SatoriSession) -> SatoriSession:
	return _parse_session(await _api_client.authenticate_refresh_async(api_key, "",
		SatoriAPI.ApiAuthenticateRefreshRequest.create(SatoriAPI, {
			"refresh_token": p_session.refresh_token,
		})
	))

## Send an event for this session.
## [p_session]: The session of the user.
## [p_event]: The event which will be sent.
func event_async(p_session: SatoriSession, p_event: Event) -> SatoriAsyncResult:
	return await events_async(p_session, [
		p_event
	])

## Send a batch of events for this session.
## [p_session]: The session of the user.
## [p_events]: The batch of events which will be sent.
func events_async(p_session: SatoriSession, p_events: Array) -> SatoriAsyncResult:
	var p_dict = {
		"events": p_events.map(func(e):
			return e.to_api_event_dict())
	}
	
	var req = SatoriAPI.ApiEventRequest.create(SatoriAPI, p_dict)
	return await _api_client.event_async(p_session,
		req)

## Get all experiments data.
## [p_session]: The session of the user.
func get_all_experiments_async(p_session: SatoriSession) -> SatoriAsyncResult:
	return await _api_client.get_experiments_async(p_session)

## Get specific experiments data.
## [p_session]: The session of the user.
## [p_names]: Experiment names.
func get_experiments_async(p_session: SatoriSession, p_names: Array) -> SatoriAPI.ApiExperimentList:
	return await _api_client.get_experiments_async(p_session, p_names)

## Get a single flag for this identity.
## This method will return the default value
## specified and will not raise an exception if the network is unavailable
## [p_session]: The session of the user.
## [p_name]: The name of the flag.
## [p_default]: The default value if the server is unreachable.
func get_flag_async(p_session: SatoriSession, p_name: String, p_default: String = "") -> SatoriAPI.ApiFlag:
	var p_names = [p_name]
	var flags = await get_flags_async(p_session, p_names)

	if flags.is_exception():
		return SatoriAPI.ApiFlag.create(SatoriAPI, {
			"name": p_name,
			"value": p_default
		})
	
	for flag in flags.flags:
		if flag.name == p_name:
			return flag
	
	return null

## List all available flags for this identity.
## [p_session]: The session of the user.
## [p_names]: Flag names, if empty all flags will be returned.
func get_flags_async(p_session: SatoriSession, p_names: Array) -> SatoriAPI.ApiFlagList:
	return await _api_client.get_flags_async(p_session.token, p_names)

## List available live events.
## [p_session]: The session of the user.
## [p_names]: Live event names, if null or empty all live events are returned.
func get_live_events_async(p_session: SatoriSession, p_names: Array = []) -> SatoriAPI.ApiLiveEventList:
	return await _api_client.get_live_events_async(p_session, p_names)

## Identify a session with a new ID.
## [p_session]: The session of the user.
## [p_id]: Identity ID to enrich the current session and return a new session.
## The old session will no longer be usable.
## Must be between eight and 128 characters (inclusive).
## Must be an alphanumeric string with only underscores and hyphens allowed.
## [p_default_properties]: The default properties.
## [p_custom_properties]: The custom event properties.
func identify_async(p_session: SatoriSession, p_id: String, p_default_properties: Dictionary = {}, p_custom_properties: Dictionary = {}) -> SatoriSession:
	var req = SatoriAPI.ApiIdentifyRequest.create(SatoriAPI, {
		"id": p_id,
		"default": p_default_properties,
		"custom": p_custom_properties
	})
	return _parse_session(await _api_client.identify_async(p_session, req))

## List properties associated with this identity.
## [p_session]: The session of the user.
func list_properties_async(p_session: SatoriSession) -> SatoriAsyncResult:
	return await _api_client.list_properties_async(p_session)

## Update properties associated with this identity.
## [p_session]: The session of the user.
## [p_default_properties]: The default properties to update.
## [p_custom_properties]: The custom properties to update.
## [p_recompute]: Whether or not to recompute the user's audience membership immediately after property update.
func update_properties_async(p_session: SatoriSession, p_default_properties: Dictionary, p_custom_properties: Dictionary, p_recompute: bool = false) -> SatoriAsyncResult:
	var req = SatoriAPI.ApiUpdatePropertiesRequest.create(SatoriAPI, {
		"default": p_default_properties,
		"custom": p_custom_properties,
		"recompute": p_recompute
	})
	return await _api_client.update_properties_async(p_session, req)

## Delete the caller's identity and associated data.
## [p_session]: The session of the user.
func delete_identity_async(p_session: SatoriSession) -> SatoriAsyncResult:
	return await _api_client.delete_identity_async(p_session)

#endregion

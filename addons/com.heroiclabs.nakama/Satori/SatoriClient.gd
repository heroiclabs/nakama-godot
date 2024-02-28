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
## [id]: An optional user id.
## [default_properties]: Optional default properties to update with this call.
## If not set, properties are left as they are on the server.
## [custom_roperties]: Optional custom properties to update with this call.
## If not set, properties are left as they are on the server.
func authenticate_async(id: String, default_properties: Dictionary = {}, custom_properties: Dictionary = {}) -> SatoriSession:
	return _parse_session(await _api_client.authenticate_async(api_key, "",
		SatoriAPI.ApiAuthenticateRequest.create(SatoriAPI, {
			"id": id,
			"default": default_properties,
			"custom": custom_properties
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
	return _parse_session(await _api_client.session_refresh_async(p_session, "",
		SatoriAPI.ApiAuthenticateRefreshRequest.create(SatoriAPI, {
			"token": p_session.refresh_token,
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

#endregion

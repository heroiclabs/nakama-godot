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

tool
extends Node

### <summary>
### The default host address of the server.
### </summary>
const DEFAULT_HOST : String = "127.0.0.1"

### <summary>
### The default port number of the server.
### </summary>
const DEFAULT_PORT : int = 7350

### <summary>
### The default timeout for the connections.
### </summary>
const DEFAULT_TIMEOUT = 3

### <summary>
### The default protocol scheme for the client connection.
### </summary>
const DEFAULT_CLIENT_SCHEME : String = "http"

### <summary>
### The default protocol scheme for the socket connection.
### </summary>
const DEFAULT_SOCKET_SCHEME : String = "ws"

const DEFAULT_LOG_LEVEL = NakamaLogger.LOG_LEVEL.DEBUG

var _http_adapter = null

func get_client_adapter() -> NakamaHTTPAdapter:
	if _http_adapter == null:
		_http_adapter = NakamaHTTPAdapter.new()
		_http_adapter.name = "NakamaHTTPAdapter"
		add_child(_http_adapter)
	return _http_adapter

func create_socket_adapter() -> NakamaSocketAdapter:
	var adapter = NakamaSocketAdapter.new()
	adapter.name = "NakamaWebSocketAdapter"
	add_child(adapter)
	return adapter

func create_client(p_server_key : String,
		p_host : String = DEFAULT_HOST,
		p_port : int = DEFAULT_PORT,
		p_scheme : String = DEFAULT_CLIENT_SCHEME,
		p_timeout : int = DEFAULT_TIMEOUT,
		p_logger = null) -> NakamaClient:
	return NakamaClient.new(get_client_adapter(), p_server_key, p_scheme, p_host, p_port, p_timeout, p_logger)

func create_socket(p_host : String = DEFAULT_HOST,
		p_port : int = DEFAULT_PORT,
		p_scheme : String = DEFAULT_SOCKET_SCHEME,
		p_logger = null) -> NakamaSocket:
	return NakamaSocket.new(create_socket_adapter(), p_host, p_port, p_scheme, p_logger, true)

func create_socket_from(p_client : NakamaClient, p_logger = null) -> NakamaSocket:
	var scheme = "ws"
	if p_client.scheme == "https":
		scheme = "wss"
	var logger = p_client.logger
	if p_logger:
		logger = p_logger
	return NakamaSocket.new(create_socket_adapter(), p_client.host, p_client.port, scheme, logger, true)

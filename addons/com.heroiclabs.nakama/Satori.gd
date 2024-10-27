@tool
extends Node

# The default host address of the server.
const DEFAULT_HOST : String = "127.0.0.1"

# The default port number of the server.
const DEFAULT_PORT : int = 7450

# The default timeout for the connections.
const DEFAULT_TIMEOUT = 15

# The default protocol scheme for the client connection.
const DEFAULT_CLIENT_SCHEME : String = "http"

# The default log level for the Satori logger.
const DEFAULT_LOG_LEVEL = SatoriLogger.LOG_LEVEL.DEBUG

var _http_adapter = null
var logger = SatoriLogger.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func get_client_adapter() -> SatoriHTTPAdapter:
	if _http_adapter == null:
		_http_adapter = SatoriHTTPAdapter.new()
		_http_adapter.logger = logger
		_http_adapter.name = "SatoriHTTPAdapter"
		add_child(_http_adapter)
	return _http_adapter

func create_client(p_api_key : String,
		p_host : String = DEFAULT_HOST,
		p_port : int = DEFAULT_PORT,
		p_scheme : String = DEFAULT_CLIENT_SCHEME,
		p_timeout : int = DEFAULT_TIMEOUT,
		p_log_level : int = DEFAULT_LOG_LEVEL,
		) -> SatoriClient:
	logger._level = p_log_level
	return SatoriClient.new(get_client_adapter(), p_api_key, p_scheme, p_host, p_port, p_timeout)

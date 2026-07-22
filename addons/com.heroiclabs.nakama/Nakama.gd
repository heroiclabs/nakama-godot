@tool
extends Node

## The default host address of the server.
const DEFAULT_HOST : String = "127.0.0.1"

## The default port number of the server.
const DEFAULT_PORT : int = 7350

## The default timeout for the connections.
const DEFAULT_TIMEOUT = 3

## The default protocol scheme for the client connection.
const DEFAULT_CLIENT_SCHEME : String = "http"

## The default protocol scheme for the socket connection.
const DEFAULT_SOCKET_SCHEME : String = "ws"

## The default log level for the Nakama logger.
const DEFAULT_LOG_LEVEL = NakamaLogger.LOG_LEVEL.DEBUG

## The path where the generated device identifier is persisted.
const DEVICE_ID_PATH : String = "user://nakama_device_id"

var _http_adapter = null
var _device_id : String = ""
var logger = NakamaLogger.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func get_client_adapter() -> NakamaHTTPAdapter:
	if _http_adapter == null:
		_http_adapter = NakamaHTTPAdapter.new()
		_http_adapter.logger = logger
		_http_adapter.name = "NakamaHTTPAdapter"
		add_child(_http_adapter)
	return _http_adapter

func create_socket_adapter() -> NakamaSocketAdapter:
	var adapter = NakamaSocketAdapter.new()
	adapter.name = "NakamaWebSocketAdapter"
	adapter.logger = logger
	add_child(adapter)
	return adapter

func create_client(p_server_key : String,
		p_host : String = DEFAULT_HOST,
		p_port : int = DEFAULT_PORT,
		p_scheme : String = DEFAULT_CLIENT_SCHEME,
		p_timeout : int = DEFAULT_TIMEOUT,
		p_log_level : int = DEFAULT_LOG_LEVEL) -> NakamaClient:
	logger._level = p_log_level
	return NakamaClient.new(get_client_adapter(), p_server_key, p_scheme, p_host, p_port, p_timeout)

func create_socket(p_host : String = DEFAULT_HOST,
		p_port : int = DEFAULT_PORT,
		p_scheme : String = DEFAULT_SOCKET_SCHEME) -> NakamaSocket:
	return NakamaSocket.new(create_socket_adapter(), p_host, p_port, p_scheme, true)

func create_socket_from(p_client : NakamaClient) -> NakamaSocket:
	var scheme = "ws"
	if p_client.scheme == "https":
		scheme = "wss"
	return NakamaSocket.new(create_socket_adapter(), p_client.host, p_client.port, scheme, true)

func get_device_id() -> String:
	if _device_id != "":
		return _device_id

	if FileAccess.file_exists(DEVICE_ID_PATH):
		var read_file := FileAccess.open(DEVICE_ID_PATH, FileAccess.READ)
		if read_file != null:
			var stored := read_file.get_as_text().strip_edges()
			read_file.close()
			if stored != "":
				_device_id = stored
				return _device_id
		else:
			logger.error("Unable to read the device id from '%s', error code: %d" % [DEVICE_ID_PATH, FileAccess.get_open_error()])

	var hex := Crypto.new().generate_random_bytes(16).hex_encode()
	_device_id = "%s-%s-%s-%s-%s" % [
		hex.substr(0, 8),
		hex.substr(8, 4),
		hex.substr(12, 4),
		hex.substr(16, 4),
		hex.substr(20, 12),
	]

	var write_file := FileAccess.open(DEVICE_ID_PATH, FileAccess.WRITE)
	if write_file != null:
		write_file.store_string(_device_id)
		write_file.close()
	else:
		logger.error("Unable to persist the device id to '%s', error code: %d. A new device id will be generated the next time the game starts, creating a new account." % [DEVICE_ID_PATH, FileAccess.get_open_error()])

	return _device_id

tool
extends Node

### <summary>
### An adapter which implements a socket with a protocol supported by Nakama.
### </summary>
class_name NakamaSocketAdapter

var _ws := WebSocketClient.new()
var _timeout : int = 30
var _start : int = 0

### <summary>
### A signal emitted when the socket is connected.
### </summary>
signal connected()

### <summary>
### A signal emitted when the socket is disconnected.
### </summary>
signal closed()

### <summary>
### A signal emitted when the socket has an error when connected.
### </summary>
signal received_error(p_exception)

### <summary>
### A signal emitted when the socket receives a message.
### </summary>
signal received(p_bytes) # PoolByteArray

### <summary>
### If the socket is connected.
### </summary>
func is_connected_to_host():
	return _ws.get_connection_status() == WebSocketClient.CONNECTION_CONNECTED

### <summary>
### If the socket is connecting.
### </summary>
func is_connecting_to_host():
	return _ws.get_connection_status() == WebSocketClient.CONNECTION_CONNECTING

### <summary>
### Close the socket with an asynchronous operation.
### </summary>
func close():
	_ws.disconnect_from_host()

### <summary>
### Connect to the server with an asynchronous operation.
### </summary>
### <param name="p_uri">The URI of the server.</param>
### <param name="p_timeout">The timeout for the connect attempt on the socket.</param>
func connect_to_host(p_uri : String, p_timeout : int):
	_ws.disconnect_from_host()
	_timeout = p_timeout
	_start = OS.get_unix_time()
	var err = _ws.connect_to_url(p_uri)
	if err != OK:
		call_deferred("emit_signal", "received_error", err)

### <summary>
### Send data to the server with an asynchronous operation.
### </summary>
### <param name="p_buffer">The buffer with the message to send.</param>
### <param name="p_reliable">If the message should be sent reliably (will be ignored by some protocols).</param>
func send(p_buffer : PoolByteArray, p_reliable : bool = true) -> int:
	return _ws.get_peer(1).put_packet(p_buffer)

func _process(delta):
	if _ws.get_connection_status() == WebSocketClient.CONNECTION_CONNECTING:
		if _start + _timeout < OS.get_unix_time():
			emit_signal("received_error", ERR_TIMEOUT)
			_ws.disconnect_from_host()
		else:
			_ws.poll()
	if _ws.get_connection_status() != WebSocketClient.CONNECTION_DISCONNECTED:
		_ws.poll()

func _init():
	_ws.connect("data_received", self, "_received")
	_ws.connect("connection_established", self, "_connected")
	_ws.connect("connection_error", self, "_error")
	_ws.connect("connection_closed", self, "_closed")

func _received():
	emit_signal("received", _ws.get_peer(1).get_packet())

func _connected(p_protocol : String):
	_ws.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	emit_signal("connected")

func _error():
	emit_signal("received_error", FAILED)

func _closed(p_clean : bool):
	emit_signal("closed")

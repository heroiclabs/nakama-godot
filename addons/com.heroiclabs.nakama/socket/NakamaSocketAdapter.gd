@tool
extends Node

# An adapter which implements a socket with a protocol supported by Nakama.
class_name NakamaSocketAdapter

var _ws := WebSocketPeer.new()
var _ws_last_state := WebSocketPeer.STATE_CLOSED
var _timeout : int = 30
var _start : int = 0
var logger = NakamaLogger.new()

# A signal emitted when the socket is connected.
signal connected()

# A signal emitted when the socket is disconnected.
signal closed()

# A signal emitted when the socket has an error when connecting.
signal received_error(p_exception)

# A signal emitted when the socket receives a message.
signal received(p_bytes) # PackedByteArray

# If the socket is connected.
func is_connected_to_host():
	return _ws.get_ready_state() == WebSocketPeer.STATE_OPEN

# If the socket is connecting.
func is_connecting_to_host():
	return _ws.get_ready_state() == WebSocketPeer.STATE_CONNECTING

# Close the socket with an asynchronous operation.
func close():
	_ws.close()

# Connect to the server with an asynchronous operation.
# @param p_uri - The URI of the server.
# @param p_timeout - The timeout for the connect attempt on the socket.
func connect_to_host(p_uri : String, p_timeout : int):
	_timeout = p_timeout
	_start = Time.get_unix_time_from_system()
	var err = _ws.connect_to_url(p_uri)
	if err != OK:
		logger.debug("Error connecting to host %s" % p_uri)
		call_deferred("emit_signal", "received_error", err)
		return
	_ws_last_state = WebSocketPeer.STATE_CLOSED

# Send data to the server with an asynchronous operation.
# @param p_buffer - The buffer with the message to send.
# @param p_reliable - If the message should be sent reliably (will be ignored by some protocols).
func send(p_buffer : PackedByteArray, p_reliable : bool = true) -> int:
	return _ws.send(p_buffer, WebSocketPeer.WRITE_MODE_TEXT)

func _process(delta):
	if _ws.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		_ws.poll()

	var state = _ws.get_ready_state()
	if _ws_last_state != state:
		_ws_last_state = state
		if state == WebSocketPeer.STATE_OPEN:
			connected.emit()
		elif state == WebSocketPeer.STATE_CLOSED:
			closed.emit()

	if state == WebSocketPeer.STATE_CONNECTING:
		if _start + _timeout < Time.get_unix_time_from_system():
			logger.debug("Timeout when connecting to socket")
			received_error.emit(ERR_TIMEOUT)
			_ws.close()

	while _ws.get_ready_state() == WebSocketPeer.STATE_OPEN and _ws.get_available_packet_count():
		received.emit(_ws.get_packet())

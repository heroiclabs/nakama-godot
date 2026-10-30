extends "res://base_test.gd"

var _connected = false

func setup():
	var client := Nakama.new(NakamaConfig.SERVER_KEY, NakamaConfig.HOST, NakamaConfig.PORT, NakamaConfig.SCHEME)

	var auth: NakamaResult = await client.authenticate_custom_async("MyIdentifier")
	if assert_cond(auth.error == null):
		return

	var socket := NakamaSocket.from(client)
	socket.connected.connect(self._on_socket_connected)
	var error: NakamaError = await socket.connect_async(auth.value)
	# Check that the connection succeeded
	if assert_cond(error == null):
		return
	# Check that the connected signal was emitted
	if assert_cond(_connected):
		return
	var adapter: WebSocketPeer = socket._adapter
	socket.close()
	# close() starts a closing handshake that only finishes while the old adapter is still polled.
	var deadline := Time.get_ticks_msec() + 2000
	while adapter.get_ready_state() != WebSocketPeer.STATE_CLOSED and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
	if assert_cond(adapter.get_ready_state() == WebSocketPeer.STATE_CLOSED):
		return
	# Reconnecting uses a fresh adapter.
	if assert_cond(await socket.connect_async(auth.value) == null):
		return
	socket.close()
	done()

func _on_socket_connected():
	_connected = true

func _process(_delta):
	assert_time(5)

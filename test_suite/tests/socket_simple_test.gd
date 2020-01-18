extends "res://base_test.gd"

var _connected = false

func setup():
	var client = Nakama.create_client(Config.SERVER_KEY, Config.HOST, Config.PORT, Config.SCHEME)

	var session = yield(client.authenticate_custom_async("MyIdentifier"), "completed")
	if assert_cond(session.is_valid()):
		return

	var socket = Nakama.create_socket_from(client)
	socket.connect("connected", self, "_on_socket_connected")
	var done = yield(socket.connect_async(session), "completed")
	# Check that connection succeded
	if assert_false(done.is_exception()):
		return
	# Check that signal has been called
	if assert_cond(_connected):
		return
	done()

func _on_socket_connected():
	_connected = true

func _process(_delta):
	assert_time(3)

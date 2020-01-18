extends "res://base_test.gd"

var content = {"My": "message"}

func setup():
	var client = Nakama.create_client(Config.SERVER_KEY, Config.HOST, Config.PORT, Config.SCHEME)

	var session1 = yield(client.authenticate_custom_async("MyIdentifier"), "completed")
	if assert_cond(session1.is_valid()):
		return

	var session2 = yield(client.authenticate_custom_async("MyIdentifier2"), "completed")
	if assert_cond(session1.is_valid()):
		return

	var socket1 = Nakama.create_socket_from(client)
	socket1.connect("received_channel_message", self, "_on_socket1_message")
	var done = yield(socket1.connect_async(session1), "completed")
	# Check that connection succeded
	if assert_false(done.is_exception()):
		return

	var socket2 = Nakama.create_socket_from(client)
	done = yield(socket2.connect_async(session2), "completed")
	# Check that connection succeded
	if assert_false(done.is_exception()):
		return

	# Join room
	var room1 = yield(socket1.join_chat_async("MyRoom", NakamaSocket.ChannelType.Room), "completed")
	if assert_false(room1.is_exception()):
		return
	var room2 = yield(socket2.join_chat_async("MyRoom", NakamaSocket.ChannelType.Room), "completed")
	if assert_false(room2.is_exception()):
		return

	# Socket 2 send message to socket 1
	var msg_ack = yield(socket2.write_chat_message_async(room2.id, content), "completed")
	if assert_false(msg_ack.is_exception()):
		return

func _on_socket1_message(msg):
	if assert_equal(msg.content, JSON.print(content)):
		return
	done()

func _process(_delta):
	assert_time(3)

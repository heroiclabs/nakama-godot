extends "res://base_test.gd"

var content = {"My": "message"}
var match_string_props = {"region": "europe"}
var match_numeric_props = {"rank": 8}
var got_msg = false
var got_match = false
var socket1 = null
var socket2 = null

func setup():
	var client = Nakama.create_client(Config.SERVER_KEY, Config.HOST, Config.PORT, Config.SCHEME)

	var session1 = yield(client.authenticate_custom_async("MyIdentifier"), "completed")
	if assert_cond(session1.is_valid()):
		return

	var session2 = yield(client.authenticate_custom_async("MyIdentifier2"), "completed")
	if assert_cond(session1.is_valid()):
		return

	socket1 = Nakama.create_socket_from(client)
	socket1.connect("received_channel_message", self, "_on_socket1_message")
	socket1.connect("received_matchmaker_matched", self, "_on_socket1_matchmaker_matched")
	var done = yield(socket1.connect_async(session1), "completed")
	# Check that connection succeded
	if assert_false(done.is_exception()):
		return

	socket2 = Nakama.create_socket_from(client)
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

	var ticket1 = yield(socket1.add_matchmaker_async("+properties.region:europe +properties.rank:>=7 +properties.rank:<=9", 2, 8, match_string_props, match_numeric_props), "completed")
	if assert_false(ticket1.is_exception()):
		return
	var ticket2 = yield(socket2.add_matchmaker_async("+properties.region:europe +properties.rank:>=7 +properties.rank:<=9", 2, 8, match_string_props, match_numeric_props), "completed")
	if assert_false(ticket2.is_exception()):
		return

func _on_socket1_message(msg):
	if assert_equal(msg.content, JSON.print(content)):
		return
	got_msg = true
	check_end()

func _on_socket1_matchmaker_matched(p_matchmaker_matched):
	if assert_equal(JSON.print(p_matchmaker_matched.users[0].string_properties), JSON.print(match_string_props)):
		return
	if assert_equal(JSON.print(p_matchmaker_matched.users[0].numeric_properties), JSON.print(match_numeric_props)):
		return
	if assert_equal(JSON.print(p_matchmaker_matched.users[1].string_properties), JSON.print(match_string_props)):
		return
	if assert_equal(JSON.print(p_matchmaker_matched.users[1].numeric_properties), JSON.print(match_numeric_props)):
		return
	got_match = true
	check_end()

func _process(_delta):
	assert_time(60)

func check_end():
	if got_match and got_msg:
		done()

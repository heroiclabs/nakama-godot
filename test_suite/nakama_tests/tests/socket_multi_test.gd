extends "res://base_test.gd"

var content = {"My": "message"}
var match_string_props = {"region": "europe"}
var match_numeric_props = {"rank": 8.0}
var got_msg = false
var got_match = false
var socket1: NakamaSocket = null
var socket2: NakamaSocket = null

func setup():
	var client := Nakama.new(NakamaConfig.SERVER_KEY, NakamaConfig.HOST, NakamaConfig.PORT, NakamaConfig.SCHEME)

	var auth1: NakamaResult = await client.authenticate_custom_async("MyIdentifier")
	if assert_cond(auth1.error == null):
		return

	var auth2: NakamaResult = await client.authenticate_custom_async("MyIdentifier2")
	if assert_cond(auth2.error == null):
		return

	socket1 = NakamaSocket.from(client)
	socket1.received_channel_message.connect(self._on_socket1_message)
	socket1.received_matchmaker_matched.connect(self._on_socket1_matchmaker_matched)
	var error: NakamaError = await socket1.connect_async(auth1.value)
	# Check that the connection succeeded
	if assert_cond(error == null):
		return

	socket2 = NakamaSocket.from(client)
	error = await socket2.connect_async(auth2.value)
	# Check that the connection succeeded
	if assert_cond(error == null):
		return

	# Join room
	var room1: NakamaResult = await socket1.join_chat_async("MyRoom", NakamaRtTypes.ChannelJoinType.ROOM)
	if assert_cond(room1.error == null):
		return
	var room2: NakamaResult = await socket2.join_chat_async("MyRoom", NakamaRtTypes.ChannelJoinType.ROOM)
	if assert_cond(room2.error == null):
		return

	# Socket 2 sends a message to socket 1
	var msg_ack: NakamaResult = await socket2.write_chat_message_async(room2.value.id, JSON.stringify(content))
	if assert_cond(msg_ack.error == null):
		return

	var query = "+properties.region:europe +properties.rank:>=7 +properties.rank:<=9"
	var ticket1: NakamaResult = await socket1.add_matchmaker_async(2, 8, query, null, match_string_props, match_numeric_props)
	if assert_cond(ticket1.error == null):
		return
	var ticket2: NakamaResult = await socket2.add_matchmaker_async(2, 8, query, null, match_string_props, match_numeric_props)
	if assert_cond(ticket2.error == null):
		return

func _on_socket1_message(msg):
	if assert_equal(msg.content, JSON.stringify(content)):
		return
	got_msg = true
	check_end()

func _on_socket1_matchmaker_matched(p_matchmaker_matched):
	if assert_equal(JSON.stringify(p_matchmaker_matched.users[0].string_properties), JSON.stringify(match_string_props)):
		return
	if assert_equal(JSON.stringify(p_matchmaker_matched.users[0].numeric_properties), JSON.stringify(match_numeric_props)):
		return
	if assert_equal(JSON.stringify(p_matchmaker_matched.users[1].string_properties), JSON.stringify(match_string_props)):
		return
	if assert_equal(JSON.stringify(p_matchmaker_matched.users[1].numeric_properties), JSON.stringify(match_numeric_props)):
		return
	got_match = true
	check_end()

func _process(_delta):
	assert_time(60)

func check_end():
	if got_match and got_msg:
		socket1.close()
		socket2.close()
		done()

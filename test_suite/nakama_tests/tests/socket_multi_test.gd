extends "res://base_test.gd"

var content := {"My": "message"}
var match_string_props := {"region": "europe"}
var match_numeric_props := {"rank": 8.0}
var _got_msg := false
var _got_match := false
var socket1: NakamaSocket = null
var socket2: NakamaSocket = null

func setup() -> void:
	var client := Nakama.new(NakamaConfig.SERVER_KEY, NakamaConfig.HOST, NakamaConfig.PORT, NakamaConfig.SCHEME)

	var auth1: NakamaResult = await client.authenticate_custom_async("MyIdentifier")
	if assert_cond(auth1.error == null):
		return

	var auth2: NakamaResult = await client.authenticate_custom_async("MyIdentifier2")
	if assert_cond(auth2.error == null):
		return

	var session1: NakamaSession = auth1.value
	var session2: NakamaSession = auth2.value
	socket1 = NakamaSocket.from(client)
	socket1.received_channel_message.connect(self._on_socket1_message)
	socket1.received_matchmaker_matched.connect(self._on_socket1_matchmaker_matched)
	var error: NakamaError = await socket1.connect_async(session1)
	if assert_cond(error == null):
		return

	socket2 = NakamaSocket.from(client)
	error = await socket2.connect_async(session2)
	if assert_cond(error == null):
		return

	var room1: NakamaResult = await socket1.join_chat_async("MyRoom", NakamaSocketTypes.ChannelJoinType.ROOM)
	if assert_cond(room1.error == null):
		return
	var room2: NakamaResult = await socket2.join_chat_async("MyRoom", NakamaSocketTypes.ChannelJoinType.ROOM)
	if assert_cond(room2.error == null):
		return

	var channel2: NakamaSocketTypes.Channel = room2.value

	var msg_ack: NakamaResult = await socket2.write_chat_message_async(channel2.id, JSON.stringify(content))
	if assert_cond(msg_ack.error == null):
		return

	var query := "+properties.region:europe +properties.rank:>=7 +properties.rank:<=9"
	var ticket1: NakamaResult = await socket1.add_matchmaker_async(2, 8, query, null, match_string_props, match_numeric_props)
	if assert_cond(ticket1.error == null):
		return
	var ticket2: NakamaResult = await socket2.add_matchmaker_async(2, 8, query, null, match_string_props, match_numeric_props)
	if assert_cond(ticket2.error == null):
		return

func _on_socket1_message(msg: NakamaTypes.ChannelMessage) -> void:
	if assert_equal(msg.content, JSON.stringify(content)):
		return
	_got_msg = true
	_check_end()

func _on_socket1_matchmaker_matched(matched: NakamaSocketTypes.MatchmakerMatched) -> void:
	var users: Array[NakamaSocketTypes.MatchmakerMatchedMatchmakerUser] = []
	users.assign(matched.users)
	if assert_equal(JSON.stringify(users[0].string_properties), JSON.stringify(match_string_props)):
		return
	if assert_equal(JSON.stringify(users[0].numeric_properties), JSON.stringify(match_numeric_props)):
		return
	if assert_equal(JSON.stringify(users[1].string_properties), JSON.stringify(match_string_props)):
		return
	if assert_equal(JSON.stringify(users[1].numeric_properties), JSON.stringify(match_numeric_props)):
		return
	_got_match = true
	_check_end()

func _process(_delta: float) -> void:
	assert_time(60)

func _check_end() -> void:
	if _got_match and _got_msg:
		socket1.close()
		socket2.close()
		done()

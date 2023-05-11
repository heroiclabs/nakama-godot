extends "res://base_test.gd"

var content = {"My": "message"}
var match_props = {"region": "europe"}
var got_msg = false
var got_match = false
var socket1 : NakamaSocket = null
var socket2 : NakamaSocket = null

func setup():
	var client = Nakama.create_client(Config.SERVER_KEY, Config.HOST, Config.PORT, Config.SCHEME)

	var session1 = await client.authenticate_custom_async("MyIdentifier")
	if assert_cond(session1.is_valid()):
		return

	var session2 = await client.authenticate_custom_async("MyIdentifier2")
	if assert_cond(session2.is_valid()):
		return

	socket1 = Nakama.create_socket_from(client)
	socket1.received_party_close.connect(self._on_party_close)
	socket1.received_party_data.connect(self._on_party_data)
	socket1.received_party_join_request.connect(self._on_party_join_request)

	var conn = await socket1.connect_async(session1)
	# Check that connection succeded
	if assert_false(conn.is_exception()):
		return

	var party = await socket1.create_party_async(false, 2)
	if assert_false(party.is_exception()):
		return
	#done()

	socket2 = Nakama.create_socket_from(client)
	socket2.received_party.connect(self._on_party)
	socket2.received_party_close.connect(self._on_party_close)
	socket2.received_party_join_request.connect(self._on_party_join_request)
	socket2.received_party_leader.connect(self._on_party_leader)
	socket2.received_party_presence.connect(self._on_party_presence)

	var conn2 = await socket2.connect_async(session2)
	# Check that connection succeded
	if assert_false(conn2.is_exception()):
		return

	var join = await socket2.join_party_async(party.party_id)
	if assert_false(join.is_exception()):
		return

func _on_party_join_request(party_join_request : NakamaRTAPI.PartyJoinRequest):
	prints("_on_party_join_request", party_join_request)
	var requests : NakamaRTAPI.PartyJoinRequest = await socket1.list_party_join_requests_async(party_join_request.party_id)
	if assert_false(requests.is_exception()):
		return
	if assert_cond(requests.presences.size() == 1):
		return

	await socket1.accept_party_member_async(party_join_request.party_id, party_join_request.presences[0])
	await socket1.promote_party_member(party_join_request.party_id, party_join_request.presences[0])

func _on_party(party):
	prints("_on_party", party)

func _on_party_close(party_close):
	prints("_on_party_close", party_close)

func _on_party_data(data : NakamaRTAPI.PartyData):
	prints("_on_party_data", data)
	var left = await socket1.leave_party_async(data.party_id)
	if assert_false(left.is_exception()):
		return

func _on_party_leader(party_leader : NakamaRTAPI.PartyLeader):
	prints("_on_party_leader", party_leader)
	var ticket = await socket2.add_matchmaker_party_async(party_leader.party_id)
	if assert_false(ticket.is_exception()):
		return
	_on_party_ticket(ticket)

func _on_party_ticket(ticket : NakamaRTAPI.PartyMatchmakerTicket):
	prints("_on_party_ticket", ticket)
	var removed = await socket2.remove_matchmaker_party_async(ticket.party_id, ticket.ticket)
	if assert_false(removed.is_exception()):
		return
	var sent = await socket2.send_party_data_async(ticket.party_id, 1, "asd")
	if assert_false(sent.is_exception()):
		return

func _on_party_presence(party_presence : NakamaRTAPI.PartyPresenceEvent):
	prints("_on_party_presence", party_presence)
	var left = party_presence.leaves.size() == 1
	if left:
		var closed = await socket2.close_party_async(party_presence.party_id)
		if assert_false(closed.is_exception()):
			return
		done()

extends "res://base_test.gd"

var content = {"My": "message"}
var match_props = {"region": "europe"}
var got_msg = false
var got_match = false
var socket1 : NakamaSocket = null
var socket2 : NakamaSocket = null

func setup():
	var client = Nakama.create_client(Config.SERVER_KEY, Config.HOST, Config.PORT, Config.SCHEME)

	var session1 = yield(client.authenticate_custom_async("MyIdentifier"), "completed")
	if assert_cond(session1.is_valid()):
		return

	var session2 = yield(client.authenticate_custom_async("MyIdentifier2"), "completed")
	if assert_cond(session2.is_valid()):
		return

	socket1 = Nakama.create_socket_from(client)
	socket1.connect("received_party_close", self, "_on_party_close")
	socket1.connect("received_party_data", self, "_on_party_data")
	socket1.connect("received_party_join_request", self, "_on_party_join_request")

	var done = yield(socket1.connect_async(session1), "completed")
	# Check that connection succeded
	if assert_false(done.is_exception()):
		return

	var party = yield(socket1.create_party_async(false, 2), "completed")
	if assert_false(party.is_exception()):
		return
	#done()

	socket2 = Nakama.create_socket_from(client)
	socket2.connect("received_party", self, "_on_party")
	socket2.connect("received_party_close", self, "_on_party_close")
	socket2.connect("received_party_join_request", self, "_on_party_join_request")
	socket2.connect("received_party_leader", self, "_on_party_leader")
	socket2.connect("received_party_matchmaker_ticket", self, "_on_party_ticket")
	socket2.connect("received_party_presence", self, "_on_party_presence")

	var done2 = yield(socket2.connect_async(session2), "completed")
	# Check that connection succeded
	if assert_false(done2.is_exception()):
		return

	var join = yield(socket2.join_party_async(party.party_id), "completed")
	if assert_false(join.is_exception()):
		return

func _on_party_join_request(party_join_request : NakamaRTAPI.PartyJoinRequest):
	prints("_on_party_join_request", party_join_request)
	var requests : NakamaRTAPI.PartyJoinRequest = yield(socket1.list_party_join_requests_async(party_join_request.party_id), "completed")
	if assert_false(requests.is_exception()):
		return
	if assert_cond(requests.presences.size() == 1):
		return
	yield(socket1.accept_party_member_async(party_join_request.party_id, party_join_request.presences[0]), "completed")
	yield(socket1.promote_party_member(party_join_request.party_id, party_join_request.presences[0]), "completed")

func _on_party(party):
	prints("_on_party", party)

func _on_party_close(party_close):
	prints("_on_party_close", party_close)

func _on_party_data(data : NakamaRTAPI.PartyData):
	prints("_on_party_data", data)
	var left = yield(socket1.leave_party_async(data.party_id), "completed")
	if assert_false(left.is_exception()):
		return

func _on_party_leader(party_leader : NakamaRTAPI.PartyLeader):
	prints("_on_party_leader", party_leader)
	var ticket = yield(socket2.add_matchmaker_party_async(party_leader.party_id), "completed")
	if assert_false(ticket.is_exception()):
		return

func _on_party_ticket(ticket : NakamaRTAPI.PartyMatchmakerTicket):
	prints("_on_party_ticket", ticket)
	var removed = yield(socket2.remove_matchmaker_party_async(ticket.party_id, ticket.ticket), "completed")
	if assert_false(removed.is_exception()):
		return
	var sent = yield(socket2.send_party_data_async(ticket.party_id, 1, "asd"), "completed")
	if assert_false(sent.is_exception()):
		return

func _on_party_presence(party_presence : NakamaRTAPI.PartyPresenceEvent):
	prints("_on_party_presence", party_presence)
	var left = party_presence.leaves.size() == 1
	if left:
		var closed = yield(socket2.close_party_async(party_presence.party_id), "completed")
		if assert_false(closed.is_exception()):
			return
		done()

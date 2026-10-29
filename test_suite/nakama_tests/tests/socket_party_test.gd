extends "res://base_test.gd"

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
	socket1.received_party_close.connect(self._on_party_close)
	socket1.received_party_data.connect(self._on_party_data)
	socket1.received_party_join_request.connect(self._on_party_join_request)

	var error: NakamaError = await socket1.connect_async(auth1.value)
	# Check that the connection succeeded
	if assert_cond(error == null):
		return

	var party: NakamaResult = await socket1.create_party_async(false, 2)
	if assert_cond(party.error == null):
		return

	socket2 = NakamaSocket.from(client)
	socket2.received_party.connect(self._on_party)
	socket2.received_party_close.connect(self._on_party_close)
	socket2.received_party_join_request.connect(self._on_party_join_request)
	socket2.received_party_leader.connect(self._on_party_leader)
	socket2.received_party_presence.connect(self._on_party_presence)

	error = await socket2.connect_async(auth2.value)
	# Check that the connection succeeded
	if assert_cond(error == null):
		return

	var join: NakamaResult = await socket2.join_party_async(party.value.party_id)
	if assert_cond(join.error == null):
		return

func _on_party_join_request(party_join_request: NakamaRtTypes.PartyJoinRequest):
	prints("_on_party_join_request", party_join_request.to_json())
	var requests: NakamaResult = await socket1.list_party_join_requests_async(party_join_request.party_id)
	if assert_cond(requests.error == null):
		return
	if assert_cond(requests.value.presences.size() == 1):
		return

	await socket1.accept_party_member_async(party_join_request.party_id, party_join_request.presences[0])
	await socket1.promote_party_member_async(party_join_request.party_id, party_join_request.presences[0])

func _on_party(party: NakamaRtTypes.Party):
	prints("_on_party", party.to_json())

func _on_party_close(party_close: NakamaRtTypes.PartyClose):
	prints("_on_party_close", party_close.to_json())

func _on_party_data(data: NakamaRtTypes.PartyData):
	prints("_on_party_data", data.to_json())
	var left: NakamaResult = await socket1.leave_party_async(data.party_id)
	if assert_cond(left.error == null):
		return

func _on_party_leader(party_leader: NakamaRtTypes.PartyLeader):
	prints("_on_party_leader", party_leader.to_json())
	var ticket: NakamaResult = await socket2.add_matchmaker_party_async(party_leader.party_id)
	if assert_cond(ticket.error == null):
		return
	_on_party_ticket(ticket.value)

func _on_party_ticket(ticket: NakamaRtTypes.PartyMatchmakerTicket):
	prints("_on_party_ticket", ticket.to_json())
	var removed: NakamaResult = await socket2.remove_matchmaker_party_async(ticket.party_id, ticket.ticket)
	if assert_cond(removed.error == null):
		return
	var sent: NakamaResult = await socket2.send_party_data_async(ticket.party_id, 1, "asd")
	if assert_cond(sent.error == null):
		return

func _on_party_presence(party_presence: NakamaRtTypes.PartyPresenceEvent):
	prints("_on_party_presence", party_presence.to_json())
	var left = party_presence.leaves.size() == 1
	if left:
		var closed: NakamaResult = await socket2.close_party_async(party_presence.party_id)
		if assert_cond(closed.error == null):
			return
		socket1.close()
		socket2.close()
		done()

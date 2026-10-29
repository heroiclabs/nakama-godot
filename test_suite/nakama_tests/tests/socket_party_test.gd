extends "res://base_test.gd"

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
	socket1.received_party_close.connect(self._on_party_close)
	socket1.received_party_data.connect(self._on_party_data)
	socket1.received_party_join_request.connect(self._on_party_join_request)

	var error: NakamaError = await socket1.connect_async(session1)
	if assert_cond(error == null):
		return

	var party: NakamaResult = await socket1.create_party_async(false, 2)
	if assert_cond(party.error == null):
		return

	var created: NakamaSocketTypes.Party = party.value

	socket2 = NakamaSocket.from(client)
	socket2.received_party.connect(self._on_party)
	socket2.received_party_close.connect(self._on_party_close)
	socket2.received_party_join_request.connect(self._on_party_join_request)
	socket2.received_party_leader.connect(self._on_party_leader)
	socket2.received_party_presence.connect(self._on_party_presence)

	error = await socket2.connect_async(session2)
	if assert_cond(error == null):
		return

	var join: NakamaResult = await socket2.join_party_async(created.party_id)
	if assert_cond(join.error == null):
		return

func _on_party_join_request(party_join_request: NakamaSocketTypes.PartyJoinRequest) -> void:
	prints("_on_party_join_request", party_join_request.to_json())
	var requests: NakamaResult = await socket1.list_party_join_requests_async(party_join_request.party_id)
	if assert_cond(requests.error == null):
		return
	var pending: NakamaSocketTypes.PartyJoinRequest = requests.value
	if assert_cond(pending.presences.size() == 1):
		return

	var presence: NakamaSocketTypes.UserPresence = party_join_request.presences[0]
	await socket1.accept_party_member_async(party_join_request.party_id, presence)
	await socket1.promote_party_member_async(party_join_request.party_id, presence)

func _on_party(party: NakamaSocketTypes.Party) -> void:
	prints("_on_party", party.to_json())

func _on_party_close(party_close: NakamaSocketTypes.PartyClose) -> void:
	prints("_on_party_close", party_close.to_json())

func _on_party_data(data: NakamaSocketTypes.PartyData) -> void:
	prints("_on_party_data", data.to_json())
	var left: NakamaResult = await socket1.leave_party_async(data.party_id)
	if assert_cond(left.error == null):
		return

func _on_party_leader(party_leader: NakamaSocketTypes.PartyLeader) -> void:
	prints("_on_party_leader", party_leader.to_json())
	var ticket: NakamaResult = await socket2.add_matchmaker_party_async(party_leader.party_id)
	if assert_cond(ticket.error == null):
		return
	var party_ticket: NakamaSocketTypes.PartyMatchmakerTicket = ticket.value
	_on_party_ticket(party_ticket)

func _on_party_ticket(ticket: NakamaSocketTypes.PartyMatchmakerTicket) -> void:
	prints("_on_party_ticket", ticket.to_json())
	var removed: NakamaResult = await socket2.remove_matchmaker_party_async(ticket.party_id, ticket.ticket)
	if assert_cond(removed.error == null):
		return
	var sent: NakamaResult = await socket2.send_party_data_async(ticket.party_id, 1, "asd")
	if assert_cond(sent.error == null):
		return

func _on_party_presence(party_presence: NakamaSocketTypes.PartyPresenceEvent) -> void:
	prints("_on_party_presence", party_presence.to_json())
	var left := party_presence.leaves.size() == 1
	if left:
		var closed: NakamaResult = await socket2.close_party_async(party_presence.party_id)
		if assert_cond(closed.error == null):
			return
		socket1.close()
		socket2.close()
		done()

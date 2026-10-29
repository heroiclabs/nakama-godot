extends "res://base_test.gd"

func setup() -> void:
	var client := Nakama.new(NakamaConfig.SERVER_KEY, NakamaConfig.HOST, NakamaConfig.PORT, NakamaConfig.SCHEME)
	var auth: NakamaResult = await client.authenticate_device_async("socket-reply-test-%d" % randi())
	if assert_cond(auth.error == null):
		return
	var session: NakamaSession = auth.value
	var socket := NakamaSocket.from(client)
	if assert_cond(await socket.connect_async(session) == null):
		return

	# Requests sent at once each get their own reply: an error, an RPC reply naming its RPC, and a match.
	var results := {}
	(func() -> void: results.fail = await socket.rpc_async("fail_500")).call()
	(func() -> void: results.rpc = await socket.rpc_async("create_bridge_match")).call()
	(func() -> void: results.match = await socket.create_match_async()).call()
	while results.size() < 3:
		await get_tree().process_frame
	var failed: NakamaResult = results.fail
	var rpc: NakamaResult = results.rpc
	var created: NakamaResult = results.match
	if assert_cond(failed.error != null and failed.value == null):
		return
	if assert_cond(rpc.error == null and created.error == null):
		return
	var rpc_reply: NakamaTypes.Rpc = rpc.value
	var match_reply: NakamaSocketTypes.Match = created.value
	if assert_cond(rpc_reply.id == "create_bridge_match" and match_reply.match_id != ""):
		return
	if assert_cond(socket._responses.is_empty()):
		return

	# The server answers one socket's requests in order, so a reply out of order is delivered by hand: it must
	# reach the request with its cid, not the oldest one waiting.
	var offline := NakamaSocket.new("ws", "127.0.0.1", 0)
	offline._responses = {"1": null, "2": null}
	offline._process_message(JSON.stringify({cid = "2", rpc = {id = "second"}}))
	offline._process_message(JSON.stringify({cid = "9", rpc = {id = "nobody asked"}}))
	if assert_cond(offline._responses["1"] == null and offline._responses["2"] != null and offline._responses.size() == 2):
		return

	# A join that times out on the client but goes through on the server is left once its late reply arrives, so
	# the other players do not keep a ghost.
	var host_auth: NakamaResult = await client.authenticate_device_async("socket-reply-host-%d" % randi())
	if assert_cond(host_auth.error == null):
		return
	var host_session: NakamaSession = host_auth.value
	var host := NakamaSocket.from(client)
	if assert_cond(await host.connect_async(host_session) == null):
		return
	var left := []
	host.received_match_presence.connect(func(event: NakamaSocketTypes.MatchPresenceEvent) -> void:
		for presence: NakamaSocketTypes.UserPresence in event.leaves:
			left.append(presence.user_id))
	var hosted: NakamaResult = await host.create_match_async()
	if assert_cond(hosted.error == null):
		return
	var hosted_match: NakamaSocketTypes.Match = hosted.value
	# Negative, so the join times out before its reply can arrive.
	socket._send_timeout_sec = -1
	var timed_out: NakamaResult = await socket.join_match_async(hosted_match.match_id)
	socket._send_timeout_sec = NakamaSocket.DEFAULT_SEND_TIMEOUT_SEC
	if assert_cond(timed_out.error != null and timed_out.error.grpc_code == NakamaError.DEADLINE_EXCEEDED):
		return
	var deadline := Time.get_ticks_msec() + 3000
	while not left.has(session.user_id) and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
	host.close()
	if assert_cond(left.has(session.user_id)):
		return

	# close() while a request waits fails it at once instead of leaving it to time out.
	var pending := {}
	(func() -> void: pending.result = await socket.create_match_async()).call()
	socket.close()
	while pending.is_empty():
		await get_tree().process_frame
	var closed: NakamaResult = pending.result
	if assert_cond(closed.error != null and closed.error.grpc_code == NakamaError.UNAVAILABLE):
		return
	if assert_cond(socket._responses.is_empty()):
		return
	done()

func _process(_delta: float) -> void:
	assert_time(10)

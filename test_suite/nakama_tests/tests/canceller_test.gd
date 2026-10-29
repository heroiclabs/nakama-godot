extends "res://base_test.gd"

func setup():
	var client := Nakama.new(NakamaConfig.SERVER_KEY, NakamaConfig.HOST, NakamaConfig.PORT, NakamaConfig.SCHEME)
	var auth: NakamaResult = await client.authenticate_device_async("cancel-test-%d" % randi())
	if assert_cond(auth.error == null):
		return
	var session: NakamaSession = auth.value

	# A call with an already cancelled canceller does not run.
	var early := NakamaCanceller.new()
	early.cancel()
	if assert_cond(_is_cancelled(await client.get_account_async(session, early))):
		return

	# One canceller, cancelled right after starting two calls, stops both in flight.
	var shared := NakamaCanceller.new()
	var results := []
	(func(): results.append(await client.get_account_async(session, shared))).call()
	(func(): results.append(await client.list_friends_async(session, "", null, null, shared))).call()
	shared.cancel()
	while results.size() < 2:
		await get_tree().process_frame
	if assert_cond(results.all(_is_cancelled)):
		return

	# The server answers 500 here, which is retried; cancelling ends the long retry wait at once.
	var slow := Nakama.new(NakamaConfig.SERVER_KEY, NakamaConfig.HOST, NakamaConfig.PORT, NakamaConfig.SCHEME)
	slow.retry_base_delay_ms = 20_000
	var waiting := NakamaCanceller.new()
	get_tree().create_timer(0.5).timeout.connect(waiting.cancel)
	var start_ms := Time.get_ticks_msec()
	var retried: NakamaResult = await slow.delete_tournament_record_async(session, "no-such-tournament", waiting)
	if assert_cond(_is_cancelled(retried) and Time.get_ticks_msec() - start_ms < 2000):
		return

	# Cancelling ends the wait for an automatic session refresh, though the refresh itself goes on. The refresh
	# goes to a local server that never replies, and the session looks expired so the call refreshes first.
	var silent := TCPServer.new()
	if assert_cond(silent.listen(0, "127.0.0.1") == OK):
		return
	var stuck := Nakama.new(NakamaConfig.SERVER_KEY, "127.0.0.1", silent.get_local_port(), "http", 5)
	var expiring := NakamaSession.restore(session.token, session.refresh_token)
	expiring.expire_time = int(Time.get_unix_time_from_system())
	var refreshing := NakamaCanceller.new()
	get_tree().create_timer(0.5).timeout.connect(refreshing.cancel)
	start_ms = Time.get_ticks_msec()
	if assert_cond(_is_cancelled(await stuck.get_account_async(expiring, refreshing)) and Time.get_ticks_msec() - start_ms < 2000):
		return

	# Cancelling or timing out a request that gets no reply returns at once; a threaded HTTPRequest froze the game.
	var in_flight := NakamaCanceller.new()
	get_tree().create_timer(0.5).timeout.connect(in_flight.cancel)
	start_ms = Time.get_ticks_msec()
	if assert_cond(_is_cancelled(await stuck.get_account_async(session, in_flight)) and Time.get_ticks_msec() - start_ms < 2000):
		return
	var quick := Nakama.new(NakamaConfig.SERVER_KEY, "127.0.0.1", silent.get_local_port(), "http", 1)
	start_ms = Time.get_ticks_msec()
	var timed_out: NakamaResult = await quick.get_account_async(session)
	if assert_cond(timed_out.error != null and timed_out.error.grpc_code == NakamaError.DEADLINE_EXCEEDED and Time.get_ticks_msec() - start_ms < 3000):
		return

	# A fresh canceller does not stop anything.
	var after: NakamaResult = await client.get_account_async(session, NakamaCanceller.new())
	if assert_cond(after.error == null):
		return

	done()

func _is_cancelled(result: NakamaResult) -> bool:
	return result.value == null and result.error != null and result.error.grpc_code == NakamaError.CANCELLED and result.error.http_status == 0

func _process(_delta):
	assert_time(10)

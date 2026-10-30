extends "res://base_test.gd"

func setup():
	var client := Nakama.new(NakamaConfig.SERVER_KEY, "localhost", 9999, "http", 1)
	client.retry_max_attempts = 100
	client.retry_max_total_ms = 300

	# Send a request to a bad port. Only 5xx replies are retried, so a refused
	# connection fails at once, and well within the total time allowed for retries.
	var start_ms = Time.get_ticks_msec()
	var result: NakamaResult = await client.authenticate_custom_async("MyIdentifier")
	var elapsed_ms = Time.get_ticks_msec() - start_ms

	if assert_cond(result.error != null and result.error.grpc_code == NakamaError.UNAVAILABLE):
		return
	if assert_cond(elapsed_ms <= 300):
		return

	# A 500 is retried until the total time allowed runs out. Each wait is at most 100 ms, so stopping
	# at 400 ms or later means the budget ended the retries; without it, 100 retries would take seconds.
	var server := Nakama.new(NakamaConfig.SERVER_KEY, NakamaConfig.HOST, NakamaConfig.PORT, NakamaConfig.SCHEME)
	var auth: NakamaResult = await server.authenticate_custom_async("MyIdentifier")
	if assert_cond(auth.error == null):
		return
	server.retry_max_attempts = 100
	server.retry_base_delay_ms = 100
	server.retry_max_delay_ms = 100
	server.retry_max_total_ms = 500

	start_ms = Time.get_ticks_msec()
	var failed: NakamaResult = await server.rpc_async(auth.value, "fail_500")
	elapsed_ms = Time.get_ticks_msec() - start_ms

	if assert_cond(failed.error != null and failed.error.http_status == 500):
		return
	if assert_cond(elapsed_ms >= 400 and elapsed_ms < 1000):
		return

	done()

func _process(_delta):
	assert_time(5)

extends "res://base_test.gd"

func setup():
	var client := Nakama.new(NakamaConfig.SERVER_KEY, NakamaConfig.HOST, NakamaConfig.PORT, NakamaConfig.SCHEME)
	var auth: NakamaResult = await client.authenticate_custom_async("MyIdentifier")
	if assert_cond(auth.error == null):
		return

	# Uncapped, three waits of up to 10, 20 and 40 s; capped, each is at most 50 ms.
	client.retry_max_attempts = 3
	client.retry_base_delay_ms = 10_000
	client.retry_max_delay_ms = 50

	var start_ms = Time.get_ticks_msec()
	var result: NakamaResult = await client.rpc_async(auth.value, "fail_500")
	var elapsed_ms = Time.get_ticks_msec() - start_ms

	if assert_cond(result.error != null and result.error.http_status == 500):
		return
	if assert_cond(elapsed_ms < 1000):
		return

	done()

func _process(_delta):
	assert_time(5)

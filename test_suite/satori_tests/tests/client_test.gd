extends "res://base_test.gd"

const IDENTITY = "285fb548-1c23-42c2-84b5-cd18c22d7053"

var _client: Satori

func setup():
	_client = Satori.new(SatoriConfig.API_KEY, SatoriConfig.HOST, SatoriConfig.TIMEOUT)

	if assert_cond(await _authenticate_and_logout()):
		return

	if assert_cond(await _refresh_session()):
		return

	if assert_cond(await _send_events()):
		return

	if assert_cond(await _get_experiments()):
		return

	if assert_cond(await _get_flags()):
		return

	if assert_cond(await _get_live_events()):
		return

	done()

func _process(_delta):
	assert_time(15)

func _authenticate_and_logout():
	var auth: SatoriResult = await _client.authenticate_async(IDENTITY)
	if assert_cond(auth.error == null):
		return

	var result: SatoriResult = await _client.authenticate_logout_async(auth.value)
	if assert_cond(result.error == null):
		return

	# The logged out session no longer works.
	var experiments: SatoriResult = await _client.get_experiments_async(auth.value)
	if assert_cond(experiments.error != null):
		return

	return true

func _refresh_session():
	var auth: SatoriResult = await _client.authenticate_async(IDENTITY)
	if assert_cond(auth.error == null):
		return

	var refreshed: SatoriResult = await _client.authenticate_refresh_async(auth.value)
	if assert_cond(refreshed.error == null and refreshed.value.token != ""):
		return

	return true

func _get_experiments():
	var auth: SatoriResult = await _client.authenticate_async(IDENTITY)
	if assert_cond(auth.error == null):
		return
	var experiments: SatoriResult = await _client.get_experiments_async(auth.value)
	if assert_cond(experiments.error == null):
		return

	return true

func _get_flags():
	var auth: SatoriResult = await _client.authenticate_async(IDENTITY)
	if assert_cond(auth.error == null):
		return

	# All flags; any server under test has some.
	var flags: SatoriResult = await _client.get_flags_async(auth.value, [])
	if assert_cond(flags.error == null and not flags.value.flags.is_empty()):
		return

	# Named flags: asking for one of them returns only that one.
	var name: String = flags.value.flags[0].name
	var named_flags: SatoriResult = await _client.get_flags_async(auth.value, [name])
	if assert_cond(named_flags.error == null and named_flags.value.flags.size() == 1 and named_flags.value.flags[0].name == name):
		return

	return true

func _send_events():
	var auth: SatoriResult = await _client.authenticate_async(IDENTITY)
	if assert_cond(auth.error == null):
		return

	var event := SatoriTypes.Event.new("gameFinished", "", {
		"score": "100",
		"level": "1"
	})
	var result: SatoriResult = await _client.event_async(auth.value, event)
	if assert_cond(result.error == null):
		return

	return true

func _get_live_events():
	var auth: SatoriResult = await _client.authenticate_async(IDENTITY)
	if assert_cond(auth.error == null):
		return
	var events: SatoriResult = await _client.get_live_events_async(auth.value)
	if assert_cond(events.error == null and events.value.live_events.is_empty()):
		return

	return true

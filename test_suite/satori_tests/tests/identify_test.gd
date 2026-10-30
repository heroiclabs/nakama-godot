extends "res://base_test.gd"

func setup():
	var _client := Satori.new(SatoriConfig.API_KEY, SatoriConfig.HOST, SatoriConfig.TIMEOUT)

	var auth1: SatoriResult = await _client.authenticate_async("11111111-1111-0000-0000-000000000000")
	if assert_cond(auth1.error == null):
		return
	var session1: SatoriSession = auth1.value

	var props1 = {
		"email": "a@b.com",
		"pushTokenIos": "foo"
	}
	var custom_props1 = {
		"earlyAccess": "true"
	}
	var updated1: SatoriResult = await _client.update_properties_async(session1, props1, custom_props1)
	if assert_cond(updated1.error == null):
		return

	# Satori only accepts events it defines.
	var events: Array[SatoriTypes.Event] = [
		SatoriTypes.Event.new("appLaunched"),
		SatoriTypes.Event.new("gameFinished"),
	]
	var sent: SatoriResult = await _client.events_async(session1, events)
	if assert_cond(sent.error == null):
		return

	await get_tree().create_timer(2.0).timeout

	var auth2: SatoriResult = await _client.authenticate_async("22222222-2222-0000-0000-000000000000")
	if assert_cond(auth2.error == null):
		return

	var props2 = {
		"email": "a@b.com",
		"pushTokenAndroid": "bar"
	}
	var custom_props2 = {
		"earlyAccess": "false"
	}
	var updated2: SatoriResult = await _client.update_properties_async(auth2.value, props2, custom_props2)
	if assert_cond(updated2.error == null):
		return

	await get_tree().create_timer(2.0).timeout

	# Identify updates session1 in place, so its holders keep working.
	var identified: SatoriResult = await _client.identify_async(session1, "22222222-2222-0000-0000-000000000000", {}, {})
	if assert_cond(identified.error == null):
		return
	var session: SatoriSession = identified.value
	if assert_cond(session == session1 and session.identity_id == "22222222-2222-0000-0000-000000000000"):
		return

	var listed: SatoriResult = await _client.list_properties_async(session)
	if assert_cond(listed.error == null):
		return
	var props: SatoriTypes.Properties = listed.value
	# Satori keeps custom properties only if it defines them, so their checks below run when it does.
	if assert_cond(props.default.size() > 0):
		return

	for key in props.default.keys():
		match key:
			"email":
				if assert_cond(props.default[key] == "a@b.com"):
					return
			"pushTokenAndroid":
				if assert_cond(props.default[key] == "bar"):
					return
			"pushTokenIos":
				if assert_cond(props.default[key] == "foo"):
					return

	for key in props.custom.keys():
		match key:
			"earlyAccess":
				if assert_cond(props.custom[key] == "false"):
					return

	done()

func _process(_delta):
	assert_time(15)

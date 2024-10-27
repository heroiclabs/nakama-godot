extends "res://base_test.gd"

func setup():
	var _client = Satori.create_client(SatoriConfig.API_KEY, SatoriConfig.HOST, SatoriConfig.PORT, SatoriConfig.SCHEME, SatoriConfig.TIMEOUT)
	
	var session1 = await _client.authenticate_async("11111111-1111-0000-0000-000000000000")

	var props1 = {
		"email": "a@b.com",
		"pushTokenIos": "foo"
	}
	var customProps1 = {
		"earlyAccess": "true"
	}
	
	await _client.update_properties_async(session1, props1, customProps1)

	var events = [
		Event.new("awardReceived", Time.get_unix_time_from_system()),
		Event.new("inventoryUpdated", Time.get_unix_time_from_system()),
	]
	await _client.events_async(session1, events)
	
	await get_tree().create_timer(2.0).timeout # Wait for 2 seconds

	var _session2 = await _client.authenticate_async("22222222-2222-0000-0000-000000000000")

	var props2 = {
		"email": "a@b.com",
		"pushTokenAndroid": "bar"
	}
	var customProps2 = {
		"earlyAccess": "false"
	}
	await _client.update_properties_async(_session2, props2, customProps2)

	await get_tree().create_timer(2.0).timeout # Wait for 2 seconds

	var session = await _client.identify_async(session1, "22222222-2222-0000-0000-000000000000", {}, {})

	assert(session != null)
	assert(session.identity_id == "22222222-2222-0000-0000-000000000000")

	var props = await _client.list_properties_async(session)
	assert(props.default.size() > 0)
	assert(props.custom.size() > 0)

	for key in props.default.keys():
		match key:
			"email":
				assert(props.default[key] == "a@b.com")
			"pushTokenAndroid":
				assert(props.default[key] == "bar")
			"pushTokenIos":
				assert(props.default[key] == "foo")

	for key in props.custom.keys():
		match key:
			"earlyAccess":
				assert(props.custom[key] == "false")
	
	done()

func _process(_delta):
	assert_time(15)
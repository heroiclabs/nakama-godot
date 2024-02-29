extends "res://base_test.gd"

var _client: SatoriClient

func setup():
	_client = Satori.create_client(SatoriConfig.API_KEY, SatoriConfig.HOST, SatoriConfig.PORT, SatoriConfig.SCHEME, SatoriConfig.TIMEOUT)
	
	if assert_cond(await test_authenticate_and_logout()):
		return
	
	if assert_cond(await test_refresh_session()):
		return
	
	if assert_cond(await test_send_events()):
		return
	
	if assert_cond(await test_get_all_experiments()):
		return
	
	if assert_cond(await test_get_flags()):
		return

	if assert_cond(await test_get_live_events()):
		return
	
	done()

func _process(_delta):
	assert_time(15)

func test_authenticate_and_logout():
	var _session = await _client.authenticate_async("285fb548-1c23-42c2-84b5-cd18c22d7053")
	if assert_cond(_session.is_valid()):
		return
	
	var result = await _client.authenticate_logout_async(_session)
	if assert_cond(not result.is_exception()):
		return
	
	var _experiments = await _client.get_all_experiments_async(_session)
	if assert_cond(_experiments.is_exception()):
		return
	
	return true

func test_refresh_session():
	var _session = await _client.authenticate_async("285fb548-1c23-42c2-84b5-cd18c22d7053")
	if assert_cond(_session.is_valid()):
		return
	
	var _refreshed = await _client.session_refresh_async(_session)
	if assert_cond(not _refreshed.is_exception() && _refreshed.is_valid()):
		return
	
	return true

func test_get_all_experiments():
	var _session = await _client.authenticate_async("285fb548-1c23-42c2-84b5-cd18c22d7053")
	var _experiments = await _client.get_all_experiments_async(_session)

	if assert_cond(not _experiments.is_exception()):
		return
	
	return true

func test_get_flags():
	var _session = await _client.authenticate_async("285fb548-1c23-42c2-84b5-cd18c22d7053")
	
	# All flags
	var _flags = await _client.get_flags_async(_session, [])
	if assert_cond(not _flags.is_exception() and _flags.flags.size() == 4):
		return

	# Named flags
	var _namedFlags = await _client.get_flags_async(_session, ["Min-Build-Number"])
	if assert_cond(not _namedFlags.is_exception() and _namedFlags.flags.size() == 1):
		return
	
	return true

func test_send_events():
	var _session = await _client.authenticate_async("285fb548-1c23-42c2-84b5-cd18c22d7053")
	var _now = Time.get_unix_time_from_system()
	
	var result = await _client.event_async(_session,
		Event.new("gameFinished", _now, "", {
			"score": "100",
			"level": "1"
		}),
	)

	if assert_cond(not result.is_exception()):
		return
	
	return true

func test_get_live_events():
	var _session = await _client.authenticate_async("285fb548-1c23-42c2-84b5-cd18c22d7053")
	var _events = await _client.get_live_events_async(_session)
	if assert_cond(not _events.is_exception() and _events.live_events.is_empty()):
		return
	
	return true

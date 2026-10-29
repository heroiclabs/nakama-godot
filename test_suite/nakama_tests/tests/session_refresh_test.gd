extends "res://base_test.gd"

func setup():
	var client := Nakama.new(NakamaConfig.SERVER_KEY, NakamaConfig.HOST, NakamaConfig.PORT, NakamaConfig.SCHEME)
	var refreshes := []
	client.session_refreshed.connect(func(s): refreshes.append(s))

	var auth: NakamaResult = await client.authenticate_device_async("refresh-test-%d" % randi(), "", true, {"keep": "me"})
	if assert_cond(auth.error == null):
		return
	var session: NakamaSession = auth.value

	# An explicit refresh renews the passed session in place and emits once.
	var refreshed: NakamaResult = await client.session_refresh_async(session)
	if assert_cond(refreshed.error == null and refreshed.value == session):
		return
	if assert_cond(refreshes == [session] and session.vars == {"keep": "me"}):
		return

	# A restored session with an expired token refreshes on its first call.
	var stale := NakamaSession.restore(session.token, session.refresh_token)
	stale.expire_time = int(Time.get_unix_time_from_system()) - 1
	var account: NakamaResult = await client.get_account_async(stale)
	if assert_cond(account.error == null and not stale.has_expired() and refreshes.size() == 2):
		return

	# Concurrent calls on a stale session share one refresh.
	var shared := NakamaSession.restore(session.token, session.refresh_token)
	shared.expire_time = int(Time.get_unix_time_from_system()) - 1
	var results := []
	(func(): results.append(await client.get_account_async(shared))).call()
	(func(): results.append(await client.list_friends_async(shared))).call()
	while results.size() < 2:
		await get_tree().process_frame
	if assert_cond(results.all(func(r): return r.error == null) and refreshes.size() == 3):
		return

	# A rejected refresh token is cleared, so auto refresh stops retrying it on every call.
	var bad := NakamaSession.restore(session.token, "garbage")
	var rejected: NakamaResult = await client.session_refresh_async(bad)
	if assert_cond(rejected.error != null and rejected.error.grpc_code == NakamaError.UNAUTHENTICATED):
		return
	if assert_cond(bad.refresh_token == "" and refreshes.size() == 3):
		return

	done()

func _process(_delta):
	assert_time(10)

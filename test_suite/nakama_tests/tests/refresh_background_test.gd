extends "res://base_test.gd"

# Answers every call at once except refresh, which takes 1 s; records the token each call sent. No server needed.
class SlowRefreshNakama extends Nakama:
	var auths: Array[String] = []

	func _init() -> void:
		super("serverkey", "nakama.invalid", 7350, "http")

	func _request(request: NakamaAPI.ApiRequestModel, auth: String, _canceller: NakamaCanceller = null) -> Dictionary:
		if request.url.contains("refresh"):
			await (Engine.get_main_loop() as SceneTree).create_timer(1.0).timeout
			return {"code": 200, "text": JSON.stringify({token = "new-token", refresh_token = "refresh-token"})}
		auths.append(auth)
		return {"code": 200, "text": "{}"}

func setup() -> void:
	var client := SlowRefreshNakama.new()
	var refreshes := []
	client.session_refreshed.connect(refreshes.append)
	var now := int(Time.get_unix_time_from_system())

	# A token inside the refresh margin still works: the call goes out with it at once, and the refresh runs behind.
	var session := NakamaSession.restore("old-token", "refresh-token")
	session.create_time = now - 3600
	session.expire_time = now + 60
	session.refresh_expire_time = now + 3600
	var start := Time.get_ticks_msec()
	var account: NakamaResult = await client.get_account_async(session)
	if assert_cond(account.error == null and Time.get_ticks_msec() - start < 500 and client.auths == ["Bearer old-token"]):
		return
	while refreshes.is_empty() and Time.get_ticks_msec() - start < 3000:
		await get_tree().process_frame
	if assert_cond(refreshes.size() == 1 and session.token == "new-token"):
		return

	# An expired token does not work, so the call waits for the refresh and sends the new token.
	var expired := NakamaSession.restore("old-token", "refresh-token")
	expired.create_time = now - 3600
	expired.expire_time = now - 1
	expired.refresh_expire_time = now + 3600
	start = Time.get_ticks_msec()
	account = await client.get_account_async(expired)
	var last_auth: String = client.auths.back()
	if assert_cond(account.error == null and Time.get_ticks_msec() - start >= 900 and last_auth == "Bearer new-token"):
		return
	done()

func _process(_delta: float) -> void:
	assert_time(10)

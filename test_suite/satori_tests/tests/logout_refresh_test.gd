extends "res://base_test.gd"

# Answers refresh with a new token and records each logout body; no server needed.
class FakeSatori extends Satori:
	var logout_bodies := []

	func _init() -> void:
		super("apikey", "satori.invalid", 5)

	func _request(request: SatoriAPI.ApiRequestModel, _auth: String, _canceller: SatoriCanceller = null) -> Dictionary:
		if request.url.contains("refresh"):
			# A real refresh takes at least a frame.
			await (Engine.get_main_loop() as SceneTree).process_frame
			return {"code": 200, "text": JSON.stringify({token = "new-token", refresh_token = "refresh-token"})}
		if request.url.contains("logout"):
			logout_bodies.append(JSON.parse_string(request.body))
		return {"code": 200, "text": ""}

# Satori revokes only the tokens a logout names, so a session refreshed on the way to logout must name its new
# token, or that token stays valid.
func setup() -> void:
	var client := FakeSatori.new()
	var session := SatoriSession.restore("old-token", "refresh-token")
	var now := int(Time.get_unix_time_from_system())
	session.create_time = now - 3600
	session.expire_time = now - 1
	session.refresh_expire_time = now + 3600
	var result: SatoriResult = await client.authenticate_logout_async(session)
	if assert_cond(result.error == null and client.logout_bodies.size() == 1):
		return
	var body: Dictionary = client.logout_bodies[0]
	if assert_cond(body.get("token") == "new-token" and body.get("refresh_token") == "refresh-token"):
		return

	# Still valid but inside the refresh margin, where other calls refresh in the background: logout waits for it.
	var due := SatoriSession.restore("old-token", "refresh-token")
	due.create_time = now - 3600
	due.expire_time = now + 60
	due.refresh_expire_time = now + 3600
	result = await client.authenticate_logout_async(due)
	if assert_cond(result.error == null and client.logout_bodies.size() == 2):
		return
	body = client.logout_bodies[1]
	if assert_cond(body.get("token") == "new-token"):
		return
	done()

func _process(_delta: float) -> void:
	assert_time(5)

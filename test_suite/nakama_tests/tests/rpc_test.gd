extends "res://base_test.gd"

func setup() -> void:
	var client := Nakama.new(NakamaConfig.SERVER_KEY, NakamaConfig.HOST, NakamaConfig.PORT, NakamaConfig.SCHEME)
	var auth: NakamaResult = await client.authenticate_custom_async("MyIdentifier")
	if assert_cond(auth.error == null):
		return
	var session: NakamaSession = auth.value

	# With a session the RPC runs as that user; the http_key is not sent, or the server would ignore the session.
	var as_user: NakamaResult = await client.rpc_async(session, "whoami", {"level": 3})
	if assert_cond(as_user.error == null):
		return
	var user_rpc: NakamaTypes.Rpc = as_user.value
	var user_reply: Dictionary = JSON.parse_string(user_rpc.payload)
	if assert_cond(str(user_reply["user_id"]) == session.user_id):
		return
	if assert_cond(str(user_reply["payload"]) == JSON.stringify({"level": 3})):
		return

	# With the http_key the RPC runs as no user, so RPCs can tell server tools from players.
	var as_key: NakamaResult = await client.rpc_with_key_async(NakamaConfig.HTTP_KEY, "whoami", "hello")
	if assert_cond(as_key.error == null):
		return
	var key_rpc: NakamaTypes.Rpc = as_key.value
	var key_reply: Dictionary = JSON.parse_string(key_rpc.payload)
	if assert_cond(str(key_reply["user_id"]) == ""):
		return
	if assert_cond(str(key_reply["payload"]) == "hello"):
		return

	# A wrong key is rejected, not let through as an anonymous call.
	var bad_key: NakamaResult = await client.rpc_with_key_async("not-the-key", "whoami")
	if assert_cond(bad_key.error != null and bad_key.error.grpc_code == NakamaError.UNAUTHENTICATED):
		return

	done()

func _process(_delta: float) -> void:
	assert_time(3)

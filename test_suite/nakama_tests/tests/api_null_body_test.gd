extends "res://base_test.gd"

# A builder given a null body message sends an empty body, and the server rejects it with an error.
func setup() -> void:
	var client := Nakama.new(NakamaConfig.SERVER_KEY, NakamaConfig.HOST, NakamaConfig.PORT, NakamaConfig.SCHEME)
	var request_model := NakamaAPI.authenticate_device(NakamaTypes.AuthenticateDeviceRequest.new(null))
	if assert_equal(request_model.body, "{}"):
		return
	var result: NakamaResult = await client._send(request_model)
	if assert_cond(result.error != null and result.error.grpc_code == NakamaError.INVALID_ARGUMENT and result.error.http_status == 400):
		return
	done()

func _process(_delta: float) -> void:
	assert_time(5)

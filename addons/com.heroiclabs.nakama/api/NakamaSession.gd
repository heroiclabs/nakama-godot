extends NakamaAsyncResult
class_name NakamaSession


var created : bool = false setget _no_set
var token : String = "" setget _no_set
var create_time : int = 0 setget _no_set
var expire_time : int = 0 setget _no_set
var expired : bool = true setget _no_set, is_expired
var vars : Dictionary = {} setget _no_set
var username : String = "" setget _no_set
var user_id : String = "" setget _no_set
var refresh_token : String = "" setget _no_set
var refresh_expire_time : int = 0 setget _no_set
var valid : bool = false setget _no_set, is_valid

func _no_set(v):
	return

func is_expired() -> bool:
	return expire_time < OS.get_unix_time()

func would_expire_in(p_secs : int) -> bool:
	return expire_time < OS.get_unix_time() + p_secs

func is_refresh_expired() -> bool:
	return refresh_expire_time < OS.get_unix_time()

func is_valid():
	return valid

func _init(p_token = null, p_created : bool = false, p_refresh_token = null, p_exception = null).(p_exception):
	if p_token:
		created = p_created
		_parse_token(p_token)
	if p_refresh_token:
		_parse_refresh_token(p_refresh_token)

func refresh(p_session):
	if p_session.token:
		_parse_token(p_session.token)
	if p_session.refresh_token:
		_parse_refresh_token(p_session.refresh_token)

func _parse_token(p_token):
	var decoded = _jwt_unpack(p_token)
	if decoded.empty():
		valid = false
		return
	valid = true
	token = p_token
	create_time = OS.get_unix_time()
	expire_time = int(decoded.get("exp", 0))
	username = str(decoded.get("usn", ""))
	user_id = str(decoded.get("uid", ""))
	vars = {}
	if decoded.has("vrs") and typeof(decoded["vrs"]) == TYPE_DICTIONARY:
		for k in decoded["vrs"]:
			vars[k] = decoded["vrs"][k]

func _parse_refresh_token(p_refresh_token):
	var decoded = _jwt_unpack(p_refresh_token)
	if decoded.empty():
		return
	refresh_expire_time = int(decoded.get("exp", 0))
	refresh_token = p_refresh_token

func _to_string():
	if is_exception():
		return get_exception()._to_string()
	return "Session<created=%s, token=%s, create_time=%d, username=%s, user_id=%s, vars=%s, expire_time=%d, refresh_token=%s refresh_expire_time=%d>" % [
		created, token, create_time, username, user_id, str(vars), expire_time, refresh_token, refresh_expire_time]

func _jwt_unpack(p_token : String) -> Dictionary:
	# Hack decode JSON payload from JWT.
	if p_token.find(".") == -1:
		_ex = NakamaException.new("Missing payload: %s" % p_token)
		return {}
	var payload = p_token.split('.')[1];
	var pad_length = ceil(payload.length() / 4.0) * 4;
	# Pad base64
	for i in range(0, pad_length - payload.length()):
		payload += "="
	payload = payload.replace("-", "+").replace("_", "/")
	var unpacked = Marshalls.base64_to_utf8(payload)
	if not validate_json(unpacked):
		var decoded = parse_json(unpacked)
		if typeof(decoded) == TYPE_DICTIONARY:
			return decoded
	_ex = NakamaException.new("Unable to unpack token: %s" % p_token)
	return {}

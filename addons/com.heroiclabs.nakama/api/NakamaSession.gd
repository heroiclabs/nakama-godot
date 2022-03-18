extends NakamaAsyncResult
class_name NakamaSession


var created : bool = false:
	set(v):
		_no_set(v)

var token : String = "":
	set(v):
		_no_set(v)

var create_time : int = 0:
	set(v):
		_no_set(v)

var expire_time : int = 0:
	set(v):
		_no_set(v)

var expired : bool = true:
	set(v):
		_no_set(v)
	get:
		return is_expired()
		
var vars : Dictionary = {}:
	set(v):
		_no_set(v)

var username : String = "":
	set(v):
		_no_set(v)

var user_id : String = "":
	set(v):
		_no_set(v)

var refresh_token : String = "":
	set(v):
		_no_set(v)

var refresh_expire_time : int = 0:
	set(v):
		_no_set(v)

var valid : bool = false: 
	set(v):
		_no_set(v)
	get:
		return is_valid()

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

func _init(p_token = null, p_created : bool = false, p_refresh_token = null, p_exception = null):
	super(p_exception)
	
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
	
	var json = JSON.new()
	var error = json.parse(unpacked)

	if error == OK:
		var decoded = json.get_data()
		if typeof(decoded) == TYPE_DICTIONARY:
			return decoded
	_ex = NakamaException.new("Unable to unpack token: %s" % p_token)
	return {}

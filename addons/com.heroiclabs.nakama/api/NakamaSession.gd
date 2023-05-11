extends NakamaAsyncResult
class_name NakamaSession

var _created : bool = false
var created : bool:
	set(v):
		pass
	get:
		return _created

var _token : String = ""
var token : String:
	set(v):
		pass
	get:
		return _token

var _create_time : int = 0
var create_time : int:
	set(v):
		pass
	get:
		return _create_time

var _expire_time : int = 0
var expire_time : int:
	set(v):
		pass
	get:
		return _expire_time

var expired : bool:
	set(v):
		pass
	get:
		return is_expired()

var _vars : Dictionary = {}
var vars : Dictionary:
	set(v):
		pass
	get:
		return _vars

var _username : String = ""
var username : String:
	set(v):
		pass
	get:
		return _username

var _user_id : String = ""
var user_id : String:
	set(v):
		pass
	get:
		return _user_id

var _refresh_token : String = ""
var refresh_token : String:
	set(v):
		pass
	get:
		return _refresh_token

var _refresh_expire_time : int = 0
var refresh_expire_time : int:
	set(v):
		pass
	get:
		return _refresh_expire_time

var _valid : bool = false
var valid : bool:
	set(v):
		pass
	get:
		return _valid

func is_expired() -> bool:
	return _expire_time < Time.get_unix_time_from_system()

func would_expire_in(p_secs : int) -> bool:
	return _expire_time < Time.get_unix_time_from_system() + p_secs

func is_refresh_expired() -> bool:
	return _refresh_expire_time < Time.get_unix_time_from_system()

func is_valid():
	return _valid

func _init(p_token = null, p_created : bool = false, p_refresh_token = null, p_exception = null):
	super(p_exception)
	
	if p_token:
		_created = p_created
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
	if decoded.is_empty():
		_valid = false
		return
	_valid = true
	_token = p_token
	_create_time = Time.get_unix_time_from_system()
	_expire_time = int(decoded.get("exp", 0))
	_username = str(decoded.get("usn", ""))
	_user_id = str(decoded.get("uid", ""))
	_vars = {}
	if decoded.has("vrs") and typeof(decoded["vrs"]) == TYPE_DICTIONARY:
		for k in decoded["vrs"]:
			_vars[k] = decoded["vrs"][k]

func _parse_refresh_token(p_refresh_token):
	var decoded = _jwt_unpack(p_refresh_token)
	if decoded.is_empty():
		return
	_refresh_expire_time = int(decoded.get("exp", 0))
	_refresh_token = p_refresh_token

func _to_string():
	if is_exception():
		return get_exception()._to_string()
	return "Session<created=%s, token=%s, create_time=%d, username=%s, user_id=%s, vars=%s, expire_time=%d, refresh_token=%s refresh_expire_time=%d>" % [
		_created, _token, _create_time, _username, _user_id, str(_vars), _expire_time, _refresh_token, _refresh_expire_time]

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

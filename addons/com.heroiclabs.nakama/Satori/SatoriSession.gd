extends  SatoriAsyncResult
class_name SatoriSession

var _token: String = ""
var token: String:
    get:
        return _token

var _refresh_token: String = ""
var refresh_token: String:
    get:
        return _refresh_token

var _expire_time: int = 0
var expire_time: int:
    get:
        return _expire_time

var expired: bool:
    get:
        return is_expired()

var _refresh_expire_time: int = 0
var refresh_expire_time: int:
    get:
        return _refresh_expire_time

var _identity_id: String = ""
var identity_id: String:
    get:
        return _identity_id

var _valid : bool = false
var valid : bool:
    get:
        return _valid

func is_expired() -> bool:
    return _expire_time < Time.get_unix_time_from_system()

func would_expire_in(p_secs : int) -> bool:
    return _expire_time < Time.get_unix_time_from_system() + p_secs

func has_refresh_expired(offset: float) -> bool:
    return _expire_time < offset

func is_refresh_expired() -> bool:
    return _refresh_expire_time < Time.get_unix_time_from_system()

func is_valid():
    return _valid

# Initializes a new instance of the SatoriSession class.
# 
# @param p_token - The authentication token.
# @param p_refresh_token - The refresh token.
# @param p_exception - The exception to be thrown, if any.
func _init(p_token = null, p_refresh_token = null, p_exception = null):
    super(p_exception)
    
    _refresh_expire_time = 0
    if p_token:
        _update(p_token, p_refresh_token)

func _update(p_token, p_refresh_token):
    _token = p_token
    _refresh_token = p_refresh_token
    
    var decoded = _jwt_unpack(p_token)
    if decoded.is_empty():
        _valid = false
        return
    
    _valid = true
    _expire_time = int(decoded.get("exp", 0))
    _identity_id = str(decoded.get("iid", ""))
    _refresh_expire_time = int(_jwt_unpack(refresh_token).get("exp", 0)) if !refresh_token.is_empty() else 0

func _to_string():
    if is_exception():
        return get_exception()._to_string()
    
    return "Session<AuthToken=%s, ExpireTime=%d, RefreshToken=%s, RefreshExpireTime=%d, IdentityId=%s>" % [
        _token, _expire_time, _refresh_token, _refresh_expire_time, identity_id]

func _jwt_unpack(p_token : String) -> Dictionary:
    # Hack decode JSON payload from JWT.
    if p_token.find(".") == -1:
        _ex = SatoriException.new("Missing payload: %s" % p_token)
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
    _ex = SatoriException.new("Unable to unpack token: %s" % p_token)
    return {}
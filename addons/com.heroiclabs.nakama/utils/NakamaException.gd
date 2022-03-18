extends RefCounted

# An exception generated during a request.
# Usually contains at least an error message.
class_name NakamaException

var status_code : int = -1:
	set(v):
		_no_set(v)

var grpc_status_code : int = -1:
	set(v):
		_no_set(v)
		
var message : String = "":
	set(v):
		_no_set(v)

var cancelled : bool = false:
	set(v):
		_no_set(v)

func _no_set(_p):
	pass

func _init(p_message : String = "", p_status_code : int = -1, p_grpc_status_code : int = -1, p_cancelled : bool = false):
	status_code = p_status_code
	grpc_status_code = p_grpc_status_code
	message = p_message
	cancelled = p_cancelled

func _to_string() -> String:
	return "NakamaException(StatusCode={%s}, Message='{%s}', GrpcStatusCode={%s})" % [status_code, message, grpc_status_code]

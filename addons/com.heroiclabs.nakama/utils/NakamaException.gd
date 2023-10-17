extends RefCounted

# An exception generated during a request.
# Usually contains at least an error message.
class_name NakamaException

enum { GRPC_OK,
       GRPC_CANCELED,
       GRPC_UNKNOWN,
       GRPC_INVALID_ARGUMENT,
       GRPC_DEADLINE_EXCEEDED,
       GRPC_NOT_FOUND,
       GRPC_ALREADY_EXISTS,
       GRPC_PERMISSION_DENIED,
       GRPC_RESOURCE_EXHAUSTED,
       GRPC_FAILED_PRECONDITION,
       GRPC_ABORTED,
       GRPC_OUT_OF_RANGE,
       GRPC_UNIMPLEMENTED,
       GRPC_INTERNAL,
       GRPC_UNAVAILABLE,
       GRPC_DATA_LOSS,
       GRPC_UNAUTHENTICATED
}

var _status_code : int = -1
var status_code : int:
	set(v):
		pass
	get:
		return _status_code

var _grpc_status_code : int = -1
var grpc_status_code : int:
	set(v):
		pass
	get:
		return _grpc_status_code

var _message : String = ""
var message : String:
	set(v):
		pass
	get:
		return _message

var _cancelled : bool = false
var cancelled : bool:
	set(v):
		pass
	get:
		return _cancelled

func _init(p_message : String = "", p_status_code : int = -1, p_grpc_status_code : int = -1, p_cancelled : bool = false):
	_status_code = p_status_code
	_grpc_status_code = p_grpc_status_code
	_message = p_message
	_cancelled = p_cancelled

func _to_string() -> String:
	return "NakamaException(StatusCode={%s}, Message='{%s}', GrpcStatusCode={%s})" % [_status_code, _message, _grpc_status_code]

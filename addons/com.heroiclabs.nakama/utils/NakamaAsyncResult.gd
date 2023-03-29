extends RefCounted
class_name NakamaAsyncResult

var exception : NakamaException:
	set(v):
		pass
	get:
		return get_exception()

var _ex = null

func _init(p_ex = null):
	_ex = p_ex

func is_exception():
	return get_exception() != null

func was_cancelled():
	return is_exception() and get_exception().cancelled

func get_exception() -> NakamaException:
	return _ex as NakamaException

func _to_string():
	if is_exception():
		return get_exception()._to_string()
	return "NakamaAsyncResult<>"

static func _safe_ret(p_obj, p_type : GDScript):
	if is_instance_of(p_obj, p_type):
		return p_obj # Correct type
	elif p_obj is NakamaException:
		return p_type.new(p_obj) # It's an exception. Incapsulate it
	return p_type.new(NakamaException.new()) # It's something else. generate an exception

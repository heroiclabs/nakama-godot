extends RefCounted
class_name SatoriAsyncResult

var exception : SatoriException:
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

func get_exception() -> SatoriException:
	return _ex as SatoriException

func _to_string():
	if is_exception():
		return get_exception()._to_string()
	return "SatoriAsyncResult<>"

static func _safe_ret(p_obj, p_type : GDScript):
	if is_instance_of(p_obj, p_type):
		return p_obj
	elif p_obj is SatoriException:
		return p_type.new(p_obj)
	return p_type.new(SatoriException.new())

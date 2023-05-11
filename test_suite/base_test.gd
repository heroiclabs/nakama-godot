extends Node

class Log:

	enum {ERROR, INFO, DEBUG}

	static func _s(lvl):
		if lvl == ERROR:
			return "ERROR"
		elif lvl == INFO:
			return "INFO"
		elif lvl == DEBUG:
			return "DEBUG"
		return "WTF"

	static func __log(lvl, msg, data):
		print("======= %s: %s" % [_s(lvl), msg])
		if not data.is_empty():
			var json = JSON.new()
			print(json.stringify(data, "    ", true))

	static func error(msg, data={}):
		__log(ERROR, msg, data)

	static func info(msg, data={}):
		__log(INFO, msg, data)

	static func debug(msg, data={}):
		__log(DEBUG, msg, data)

const REAL_ASSERT = false

var _success = false
var _start_time = 0
var _quit = false
var _disabled = false
var __me = ""

# Override this to specify test initialization (called on _ready if not disabled)
# You can run your whole test here, and call done() when finished
func setup():
	pass

# Override this to do cleanup, make assertions at the end of the test (called on _exit_tree)
# NOTE: You can still fail here if you like with fail() or by failing an assertion
func teardown():
	pass

func _init():
	__me = get_script()
	while __me.get_base_script() != null:
		__me = __me.get_base_script()

func _ready():
	if _disabled:
		set_process(false)
		set_physics_process(false)
		set_process_input(false)
		set_process_unhandled_input(false)
		set_process_unhandled_key_input(false)
		done()
		Log.info("SKIP: %s" % __get_source(self))
		return
	_start_time = Time.get_ticks_usec()
	Log.info("RUNNING: %s" % __get_source(self))
	setup()

func _exit_tree():
	if _disabled:
		return

	teardown()
	Log.info("%s: %s" % ["SUCCESS" if _success else "!!!!!!!!!!!!!!!!!!! FAILURE", __get_source(self)])

func __get_source(who):
	if who == null or who.get_script() == null:
		return "Unknown source: %s" % str(who)
	return who.get_script().resource_path

func __get_caller():
	for s in get_stack():
		if __me.resource_path != s.source:
			return s
	return null

func __get_assertion():
	var stack = get_stack()
	stack.reverse()
	for s in stack:
		if __me.resource_path == s.source:
			return s
	return null

func __assert(v1, v2):
	if not (v1 == v2):
		Log.error("Assert Failed", {"caller": __get_caller(), "assertion": __get_assertion(), "full_stack": get_stack()})
		print_tree_pretty()
		_quit = true
	if REAL_ASSERT:
		assert(v1 == v2)
	if v1 == v2:
		return false
	return true

func assert_time(max_time):
	__assert(max_time > float(Time.get_ticks_usec() - _start_time) / 1000.0 / 1000.0, true)

### Returns true if the assertion failed, so you can do:
### if assert_cond(cond):
###   return # Assertion failed!
func assert_cond(cond):
	return __assert(cond, true)

func assert_false(cond):
	return __assert(cond, false)

func assert_equal(v1, v2):
	return __assert(v1, v2)

func done():
	_success = true
	_quit = true

func fail():
	_success = false
	_quit = true
	__assert(false, true)

func disable():
	_disabled = true

func is_disabled():
	return _disabled

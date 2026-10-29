extends Node

const BaseTest := preload("res://base_test.gd")

var current: BaseTest = null
var tests: Array[String] = []
var frame_time := 0.0
var fixed_time := 0.0
var dirs: Array[String] = ["tests"]

func _ready() -> void:
	while not dirs.is_empty():
		var d: String = dirs.pop_front()
		_expand(d, dirs)
	print("Running %d tests:\n%s" % [tests.size(), tests])

func _process(delta: float) -> void:
	frame_time += delta
	_check_end()

func _physics_process(delta: float) -> void:
	fixed_time += delta
	_check_end()

func _check_end() -> void:
	if current == null:
		if tests.size() == 0:
			_end_tests()
			return
		var path: String = tests.pop_front()
		var script: GDScript = load(path)
		current = script.new()
		add_child(current)
	elif current._quit:
		if not current._success:
			_end_tests()
		current.queue_free()
		current = null

func _end_tests() -> void:
	print("======= TESTS END")
	set_process(false)
	set_physics_process(false)
	await get_tree().create_timer(1.0).timeout
	get_tree().call_deferred("quit")

func _expand(p_name: String, r_dirs: Array[String]) -> void:
	var dir := DirAccess.open("res://")
	if dir.change_dir(p_name) != OK:
		print("Unable to chdir into: %s" % p_name)
		return
	dir.list_dir_begin()
	var f := dir.get_next()
	while f != "":
		if dir.current_is_dir():
			r_dirs.append("%s/%s" % [p_name, f])
		if f.ends_with("_test.gd"):
			tests.append("%s/%s" % [p_name, f])
		f = dir.get_next()
	dir.list_dir_end()

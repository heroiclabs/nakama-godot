extends SceneTree

func _init() -> void:
	var script: Script = get_script()
	var me := ProjectSettings.localize_path(ProjectSettings.globalize_path(script.resource_path))
	var dir := ProjectSettings.localize_path(me.get_base_dir())

	if dir != "res://":
		print("Must be run with the script dir as the res:// path")
		print("Current path: ", ProjectSettings.globalize_path(dir))
		print("res:// path: ", ProjectSettings.globalize_path("res://"))
		quit()
		return
	var tester: GDScript = load("res://tester.gd")
	var n: Node = tester.new()
	root.add_child(n)
	current_scene = n

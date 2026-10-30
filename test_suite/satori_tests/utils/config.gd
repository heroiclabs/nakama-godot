extends Node

var HOST = ""
var API_KEY = "apikey"
var TIMEOUT = 5

func _ready():
	var parsed = null
	var f = FileAccess.open("res://settings.json", FileAccess.READ)
	if f:
		var json = JSON.new()
		if json.parse(f.get_as_text()) == OK:
			parsed = json.get_data()
	if typeof(parsed) == TYPE_DICTIONARY:
		for k in parsed:
			match k:
				"HOST": HOST = parsed[k]
				"API_KEY": API_KEY = parsed[k]
				"TIMEOUT": TIMEOUT = parsed[k]
	# The environment wins, so an API key need not be written into the tracked settings.json.
	if OS.get_environment("SATORI_HOST") != "": HOST = OS.get_environment("SATORI_HOST")
	if OS.get_environment("SATORI_API_KEY") != "": API_KEY = OS.get_environment("SATORI_API_KEY")
	if HOST == "":
		push_error("No Satori server: set SATORI_HOST, or HOST in settings.json")

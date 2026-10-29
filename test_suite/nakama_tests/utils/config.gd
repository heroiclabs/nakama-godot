extends Node

var HOST = "127.0.0.1"
var PORT = 7350
var SCHEME = "http"
var SERVER_KEY = "defaultkey"

func _ready():
	var f = FileAccess.open("res://settings.json", FileAccess.READ)
	if not f:
		return
	var json = JSON.new()
	var error = json.parse(f.get_as_text())
	var parsed = json.get_data()
	if error != OK or typeof(parsed) != TYPE_DICTIONARY:
		return
	for k in parsed:
		match k:
			"HOST": HOST = parsed[k]
			"PORT": PORT = parsed[k]
			"SCHEME": SCHEME = parsed[k]
			"SERVER_KEY": SERVER_KEY = parsed[k]

extends Node

var HOST = "127.0.0.1"
var PORT = 7450
var SCHEME = "http"
var API_KEY = "apikey"
var TIMEOUT = 5

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
			"API_KEY": API_KEY = parsed[k]
			"TIMEOUT": TIMEOUT = parsed[k]

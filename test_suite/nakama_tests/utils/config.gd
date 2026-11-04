extends Node

var HOST := "127.0.0.1"
var PORT := 7350
var SCHEME := "http"
var SERVER_KEY := "defaultkey"
# Nakama's default runtime.http_key.
var HTTP_KEY := "defaulthttpkey"

func _ready() -> void:
	var f := FileAccess.open("res://settings.json", FileAccess.READ)
	if not f:
		return
	var json := JSON.new()
	var error := json.parse(f.get_as_text())
	var parsed: Variant = json.get_data()
	if error != OK or typeof(parsed) != TYPE_DICTIONARY:
		return
	var settings: Dictionary = parsed
	for k: String in settings:
		match k:
			"HOST": HOST = settings[k]
			"PORT": PORT = settings[k]
			"SCHEME": SCHEME = settings[k]
			"SERVER_KEY": SERVER_KEY = settings[k]
			"HTTP_KEY": HTTP_KEY = settings[k]

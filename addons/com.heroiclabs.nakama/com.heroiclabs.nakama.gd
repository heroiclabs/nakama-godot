@tool
extends EditorPlugin

const NAKAMA_AUTOLOAD_NAME := "Nakama"
const NAKAMA_AUTOLOAD_PATH := "res://addons/com.heroiclabs.nakama/Nakama.gd"

func _enter_tree() -> void:
	_initialize_autoloads()
	
func _exit_tree() -> void:
	_remove_autoloads()

func _initialize_autoloads() -> void:
	add_autoload_singleton(NAKAMA_AUTOLOAD_NAME, NAKAMA_AUTOLOAD_PATH)
	
func _remove_autoloads() -> void:
	remove_autoload_singleton(NAKAMA_AUTOLOAD_NAME)

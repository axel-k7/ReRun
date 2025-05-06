extends Node


func _on_new_game_button_pressed() -> void:
	Globals.main.emit_signal("new_game")

func _on_load_button_pressed() -> void:
	Globals.main.emit_signal("load_game")

func _on_settings_button_pressed() -> void:
	Globals.main.emit_signal("settings")

func _on_exit_button_pressed() -> void:
	Globals.main.emit_signal("exit")

extends Node

@onready var options = $OptionsMenu

func _on_new_game_button_pressed() -> void:
	Globals.main.emit_signal("new_game")

func _on_load_button_pressed() -> void:
	Globals.main.emit_signal("load_game")

func _on_settings_button_pressed() -> void:
	Globals.main.emit_signal("settings")

func _on_exit_button_pressed() -> void:
	Globals.main.emit_signal("exit")

func _on_fullscreen_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif !toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

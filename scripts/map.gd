extends Node

func _ready() -> void:
	Globals.emit_signal("map_loaded")

extends Node

@export var has_boss: bool = false
var boss_spawn: Marker3D

func _ready() -> void:
	if has_boss:
		boss_spawn = $BossSpawn
	Globals.emit_signal("map_loaded")

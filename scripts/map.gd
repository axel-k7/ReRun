extends Node

@export var has_boss: bool = false
var boss_spawn: Marker3D

func _ready() -> void:
	if has_boss:
		boss_spawn = $BossSpawn
	Globals.system_message(self.name)
	Globals.emit_signal("map_loaded")

extends Node

@export var has_boss: bool = false
@onready var boss_spawn = $BossSpawn

func _ready() -> void:
	Globals.emit_signal("map_loaded")

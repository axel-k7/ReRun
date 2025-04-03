extends Node

@onready var battle_scene_preload = preload("res://scenes/ui/battle_scene_tb.tscn")
var battle_scene
var allies: Array[Object]
var enemies: Array[Object]
var battle_paused: bool = false
var battle_active: bool = false

func _ready():
	battle_scene = battle_scene_preload.instantiate()
	self.add_child(battle_scene)

func start_battle(allies: Array[Object], enemies: Array[Object]):
	battle_scene.start_battle(allies, enemies)

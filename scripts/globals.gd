extends Node

@onready var target_interactables: Array[Object] = []
@onready var player: CharacterBody3D
@onready var can_move: bool = true
@onready var can_interact: bool = true
@onready var can_rotate_camera: bool = true
@onready var can_player_attack: bool = true
const gravity = 60

func add_interact(body):
	var interact_scene =  preload("res://scenes/items/interact_area.tscn")
	var interact_area = interact_scene.instantiate()
	(body).add_child(interact_area)

func player_controls(option: bool):
	can_move = option
	can_interact = option
	can_rotate_camera = option
	can_player_attack = option

func damage(target: Object, amount: int):
	target.on_damaged(amount)

func damage_flash(target):
	target.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.2).timeout
	target.modulate = Color(1, 1, 1)
	
func save_inventory_file(data: Array):
	var config_file: ConfigFile = ConfigFile.new()
	print(data)
	config_file.set_value("player", "inventory", data)
	config_file.save("res://data/player_data.cfg")

func load_inventory():
	if player != null:
		var config_file = ConfigFile.new()
		var error_check = config_file.load("res://data/player_data.cfg")
		if error_check != OK:
			return
	
		var loaded_inventory = config_file.get_value("player", "inventory")
		player.inventory = loaded_inventory

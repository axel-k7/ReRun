extends Node

@onready var target_interactables: Array[Object] = []
@onready var player: CharacterBody3D
@onready var can_move: bool = true
@onready var can_interact: bool = true
@onready var can_rotate_camera: bool = true
@onready var can_player_attack: bool = true
@onready var main: Node3D
const gravity = 60

var config_data: Dictionary = {
	"current_map": "",
	"player_spawn_position": Vector3()
}

func _ready() -> void:
	load_config_file()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		save_config_file()
		await get_tree().create_timer(0.5).timeout #wait for data to save
		get_tree().quit()

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
	
func save_inventory_data(data: Array):
	var config_file: ConfigFile = ConfigFile.new()
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

func save_config_file():
	save_config_variables()
	var config_file = ConfigFile.new()
	var error_check = config_file.load("res://data/world_data.cfg")
	if error_check != OK:
		return
	for config_item in config_data.keys():
		config_file.set_value("world", str(config_item), config_data[config_item])
		print(config_item, " set as: ", config_data[config_item])
	config_file.save("res://data/world_data.cfg")

func save_config_variables():
	config_data["current_map"] = main.map_holder.get_child(0).name
	config_data["player_spawn_position"] = player.global_position

func load_config_file():
	var config_file = ConfigFile.new()
	var error_check = config_file.load("res://data/world_data.cfg")
	if error_check != OK:
		return
	for config_item in config_data.keys():
		config_data[config_item] = config_file.get_value("world", str(config_item))
	

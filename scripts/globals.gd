extends Node

@onready var interactables: Array[Node]
var target_interactable: Object

@onready var player: CharacterBody3D
@onready var can_move: bool = false
@onready var can_interact: bool = false
@onready var can_rotate_camera: bool = false
@onready var can_player_attack: bool = false
@onready var main: Node3D
const gravity = 60
var paused: bool = false

var config_data: Dictionary = {
	"current_map": "",
	"player_spawn_position": Vector3()
}

signal map_loading
signal map_loaded

func _ready() -> void:
	load_config_file()
	map_loaded.connect(on_map_loaded)
	map_loading.connect(on_map_loading)

func add_interact(body):
	var interact_scene =  preload("res://scenes/items/interact_area.tscn")
	var interact_area: Area3D = interact_scene.instantiate()
	body.add_child(interact_area)
	body.add_to_group("interactables")
	
#function below would run in process for more accurate interact-range-checks, due to performance issues its instead limited to situational checks
func check_closest_interactable():
	interactables = get_tree().get_nodes_in_group("interactables")
	var index = 0
	for i in interactables:
		if interactables[index] == null:
			interactables.remove_at(index)
		index += 1
	interactables.sort_custom(sort_closest)
	print("closest interactable: ", interactables[0])

func sort_closest(object1, object2):
	return object1.global_position.distance_to(player.global_position) < object2.global_position.distance_to(player.global_position)

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
	config_data["current_map"] = main.map_container.get_child(0).name
	config_data["player_spawn_position"] = player.global_position

func load_config_file():
	var config_file = ConfigFile.new()
	var error_check = config_file.load("res://data/world_data.cfg")
	if error_check != OK:
		return
	for config_item in config_data.keys():
		config_data[config_item] = config_file.get_value("world", str(config_item))

func on_map_loading():
	print("CHANGING MAP")
	player_controls(false)
	main.emit_signal("loading_start")

func on_map_loaded():
	await get_tree().create_timer(1.5).timeout
	check_closest_interactable()
	player_controls(true)
	main.emit_signal("loading_finished")

func system_message(message: String):
	var sys_msg_label = main.ui_container.get_node("SystemMessage")
	sys_msg_label.text = message
	var tween = create_tween()
	tween.tween_property(sys_msg_label, "modulate:a", 1, 0.5)
	tween.tween_property(sys_msg_label, "modulate:a", 0, 1).set_delay(1)
	await tween.finished
	tween.stop()
	tween.tween_callback(queue_free)

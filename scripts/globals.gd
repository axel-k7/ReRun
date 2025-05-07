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
var game_started: bool = false

var world_config_data: Dictionary = {
	"current_map": "",
}
var player_config_data: Dictionary = {
	"inventory": "",
	"spawn_position": "",
	"max_hp": "",
	"hp": "",
	"max_mp": "",
	"mp": "",
	"attacks": "",
}

signal map_loading
signal map_loaded

func _ready() -> void:
	load_config_file("world")
	map_loaded.connect(on_map_loaded)
	map_loading.connect(on_map_loading)

func add_interact(body, forced):
	var interact_scene =  preload("res://scenes/items/interact_area.tscn")
	var interact_area: Area3D = interact_scene.instantiate()
	body.add_child(interact_area)
	body.add_to_group("interactables")
	if forced:
		interact_area.forced_interaction = true
	
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

func save_config_file(reset):
	if !reset:
		save_config_variables()
	elif reset:
		reset_config_variables()
	var world_config_file = ConfigFile.new()
	var player_config_file = ConfigFile.new()
	var world_error_check = world_config_file.load("res://data/world_data.cfg")
	var player_error_check = world_config_file.load("res://data/world_data.cfg")
	if world_error_check != OK || player_error_check != OK:
		return
	for config_item in world_config_data.keys():
		world_config_file.set_value("world", str(config_item), world_config_data[config_item])
		print(config_item, " set as: ", world_config_data[config_item])
	for config_item in player_config_data.keys():
		player_config_file.set_value("player", str(config_item), player_config_data[config_item])
		print(config_item, " set as: ", player_config_data[config_item])
	world_config_file.save("res://data/world_data.cfg")
	player_config_file.save("res://data/player_data.cfg")

func save_config_variables():
	world_config_data["current_map"] = main.map_container.get_child(0).name
	player_config_data["inventory"] = player.inventory
	player_config_data["spawn_position"] = player.global_position
	player_config_data["max_hp"] = player.max_hp
	player_config_data["hp"] = player.hp
	player_config_data["max_mp"] = player.max_mp
	player_config_data["mp"] = player.mp
	player_config_data["attacks"] = player.attacks

func reset_config_variables():
	world_config_data["current_map"] = "throne_room"
	player_config_data["inventory"] = []
	player_config_data["spawn_position"] = ""
	player_config_data["max_hp"] = 100
	player_config_data["hp"] = 100
	player_config_data["max_mp"] = 100
	player_config_data["mp"] = 100
	player_config_data["attacks"] = []

func load_config_file(file_name: String):
	var config_file = ConfigFile.new()
	var error_check = config_file.load("res://data/" + file_name + "_data.cfg")
	if error_check != OK:
		return
	if file_name == "world":
		for config_item in world_config_data.keys():
			world_config_data[config_item] = config_file.get_value("world", str(config_item))
	elif file_name == "player":
		for config_item in player_config_data.keys():
			player_config_data[config_item] = config_file.get_value("player", str(config_item))

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

func set_player_intro_stats(powerful: bool):
	if player != null:
		if powerful == true:
			can_player_attack = false
			player.max_hp = 500
			player.hp = 500
			player.max_mp = 250
			player.mp = 250
			player.attacks.append([ "Sword of Justice", 50, 15, "instance", 1, false])
			player.attacks.append([ "Fireball", 20, 5, "instance", 1, false])
		elif powerful == false:
			can_player_attack = false
			player.max_hp = 20
			player.hp = 20
			player.max_mp = 10
			player.mp = 10
			player.attacks = [
				[ "Slash", 5, 3, "local", 1, false],
			]

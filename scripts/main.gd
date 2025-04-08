extends Node3D

@onready var map_holder = $MapHolder

@onready var loading_screen_scene = preload("res://scenes/ui/loading_screen.tscn")
var loading_screen: Object

signal loading_start
signal loading_finished

func _ready():
	#await get_tree().create_timer(2).timeout REPLACE WITH AN AWAIT FOR READY CHECK FROM GLOBALS
	loading_start.connect(on_loading_start)
	loading_finished.connect(on_loading_finished)
	
	Globals.main = self
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	load_map()
	spawn_player()

func spawn_player():
	var player_scene =  preload("res://scenes/player/player.tscn")
	var player = player_scene.instantiate()
	self.add_child(player)
	print(Globals.config_data["player_spawn_position"])
	player.global_position = Globals.config_data["player_spawn_position"]
	Globals.player = player

func load_map():
	var map_to_load = load(str("res://scenes/maps/", Globals.config_data["current_map"], ".tscn"))
	var map = map_to_load.instantiate()
	
	await get_tree().create_timer(0.5).timeout #wait for loading screen to appear
	if map_holder.get_children() != []: #if a map is already loaded: remove it
		var loaded_map = map_holder.get_child(0)
		loaded_map.queue_free()
		
	map_holder.add_child(map)
	Globals.config_data["current_map"] = "test_map_2"

func on_loading_start():
	loading_screen = loading_screen_scene.instantiate()
	self.add_child(loading_screen)

func on_loading_finished():
	if loading_screen == null:
		return
	loading_screen.emit_signal("finished_loading")

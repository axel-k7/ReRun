extends Node3D

@onready var map_holder = $MapHolder

func _ready():
	#await get_tree().create_timer(2).timeout REPLACE WITH AN AWAIT FOR READY CHECK FROM GLOBALS
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
	
	if map_holder.get_children() != []: #if a map is already loaded: remove it
		var loaded_map = map_holder.get_child(0)
		loaded_map.queue_free()
		
	map_holder.add_child(map)
	Globals.config_data["current_map"] = "test_map_2"

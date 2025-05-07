extends Node3D

@onready var ui_container: CanvasLayer = $UiContainer
@onready var menu: Control = $UiContainer/Menu
@onready var map_container = $MapContainer
@onready var npc_container = $NPCContainer
var map

@onready var loading_screen_scene = preload("res://scenes/ui/loading_screen.tscn")
var loading_screen: Object
@onready var ability_menu_scene = preload("res://scenes/ui/ability_selector.tscn")
var ability_menu: Object
@onready var main_menu_scene = preload("res://scenes/ui/main_menu.tscn")
var main_menu: Object
@onready var narrator_scene = preload("res://scenes/ui/narrator_message.tscn")
var narrator: Object

signal loading_start
signal loading_active
signal loading_finished
signal new_game
signal load_game
signal settings
signal exit
signal narrator_finished

func _ready():
	set_up_main_menu()
	loading_start.connect(on_loading_start)
	loading_finished.connect(on_loading_finished)
	new_game.connect(on_new_game)
	load_game.connect(on_load_game)
	settings.connect(on_settings)
	exit.connect(on_exit)
	Globals.main = self

func set_up_main_menu():
	main_menu = main_menu_scene.instantiate()
	ui_container.add_child(main_menu)

func set_up_ability_menu():
	ability_menu = ability_menu_scene.instantiate()
	ui_container.add_child(ability_menu)
	ability_menu.visible = false

func spawn_player():
	Globals.load_config_file("player")
	var player_scene =  load("res://scenes/player/player.tscn")
	var player = player_scene.instantiate()
	self.add_child(player)
	Globals.player = player
	match typeof(Globals.player_config_data["spawn_position"]):
		TYPE_VECTOR3: player.global_position = Globals.player_config_data["spawn_position"]
		TYPE_STRING: Globals.player.global_position = map.player_spawn_pos #spawn player at map spawn point if no data

func load_map():
	emit_signal("loading_start")
	BattleManagerTb.enemies.clear() #any allies need to be outside of the map scene for this to function properly
	var map_to_load = load(str("res://scenes/maps/", Globals.world_config_data["current_map"], ".tscn"))
	map = map_to_load.instantiate()
	await loading_active
	if map_container.get_children() != []: #if a map is already loaded: remove it
		Globals.player_config_data["spawn_position"] = "" #wipe saved spawn position
		var loaded_map = map_container.get_child(0)
		loaded_map.queue_free()
	map_container.add_child(map)
	Globals.world_config_data["current_map"] = "test_map_2"
	map.spawn_npcs()
	await get_tree().create_timer(1).timeout #artificial delay
	emit_signal("loading_finished")

func reset_game():
	Globals.game_started = false
	for child in map_container.get_children():
		child.queue_free()
	for child in npc_container.get_children():
		child.queue_free()
	Globals.player.queue_free()
	Globals.main.set_up_main_menu()
	Globals.main.emit_signal("loading_finished")

func start_game():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	DialogueManager.emit_signal("loading_complete")
	load_map()
	set_up_ability_menu()
	await loading_finished
	main_menu.queue_free()
	spawn_player()
	Globals.game_started = true
	Globals.paused = false

func on_loading_start():
	loading_screen = loading_screen_scene.instantiate()
	ui_container.add_child(loading_screen)

func on_loading_finished():
	if loading_screen == null:
		return
	loading_screen.emit_signal("finished_loading")

func on_new_game():
	Globals.save_config_file(true)
	start_game()
	intro_sequence()

func on_load_game():
	Globals.load_config_file("world")
	Globals.load_config_file("player") #for debugging
	start_game()
	#if !Globals.world_config_data["current_map"] == "throne_room":
	#	Globals.load_config_file("player")
	#	start_game() #player must have completed the first map to save & load their game
	#else: 
	#	Globals.system_message("No save file available")

func on_settings():
	pass

func on_exit():
	get_tree().quit()

func _input(event):
	if Input.is_action_just_pressed("menu") && Globals.game_started:
		toggle_menu()

func intro_sequence():
	Globals.game_started = false
	Globals.paused = true
	var lines: Array[String] = [
		"You are the Hero of humanity, sent on a mission to defeat the Demon King and put an end to their tyranny.",
		"After countless of hard fought battles, you and your party of adventurers finally arrive at the Demon King's chamber."
	]
	narrator = narrator_scene.instantiate()
	await loading_finished
	ui_container.add_child(narrator)
	narrator.narrate(lines, "res://vfx/view.png")
	await narrator_finished
	Globals.paused = false
	Globals.game_started = true
	Globals.player.emit_signal("intro_talk_start")
	Globals.set_player_intro_stats(true)

func toggle_menu():
	if Globals.paused == false:
		Globals.paused = true
		menu.emit_signal("activate")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Globals.paused == true:
		Globals.paused = false
		menu.emit_signal("deactivate")
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

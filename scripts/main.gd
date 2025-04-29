extends Node3D

@onready var ui_container: CanvasLayer = $UiContainer
@onready var menu: Control = $UiContainer/Menu
@onready var map_container = $MapContainer
var map

@onready var loading_screen_scene = preload("res://scenes/ui/loading_screen.tscn")
var loading_screen: Object
@onready var ability_menu_scene = preload("res://scenes/ui/ability_selector.tscn")
var ability_menu: Object

signal loading_start
signal loading_finished

func _ready():
	#await get_tree().create_timer(2).timeout REPLACE WITH AN AWAIT FOR READY CHECK FROM GLOBALS
	loading_start.connect(on_loading_start)
	loading_finished.connect(on_loading_finished)
	Globals.main = self
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	DialogueManager.emit_signal("loading_complete")
	load_map()
	set_up_ability_menu()
	spawn_player()

func set_up_ability_menu():
	ability_menu = ability_menu_scene.instantiate()
	ui_container.add_child(ability_menu)
	ability_menu.visible = false

func spawn_player():
	var player_scene =  load("res://scenes/player/player.tscn")
	var player = player_scene.instantiate()
	self.add_child(player)
	print(Globals.config_data["player_spawn_position"])
	player.global_position = Globals.config_data["player_spawn_position"]
	Globals.player = player
	Globals.load_inventory()

func spawn_boss(boss_name: String):
	var boss_scene = load("res://scenes/NPC/" + boss_name + ".tscn")
	var boss = boss_scene.instantiate()
	self.add_child(boss)
	boss.global_position = map.boss_spawn.global_position

func load_map():
	BattleManagerTb.enemies.clear() #any allies need to be outside of the map scene for this to function properly
	var map_to_load = load(str("res://scenes/maps/", Globals.config_data["current_map"], ".tscn"))
	map = map_to_load.instantiate()
	
	await get_tree().create_timer(0.5).timeout #wait for loading screen to appear
	if map_container.get_children() != []: #if a map is already loaded: remove it
		var loaded_map = map_container.get_child(0)
		loaded_map.queue_free()
		
	map_container.add_child(map)
	Globals.config_data["current_map"] = "test_map_2"
	
	if map.has_boss:
		spawn_boss("boss")

func on_loading_start():
	loading_screen = loading_screen_scene.instantiate()
	ui_container.add_child(loading_screen)

func on_loading_finished():
	if loading_screen == null:
		return
	loading_screen.emit_signal("finished_loading")
	

func _input(event):
	if Input.is_action_just_pressed("menu"):
		toggle_menu()

func toggle_menu():
	if Globals.paused == false:
		Globals.paused = true
		menu.emit_signal("activate")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Globals.paused == true:
		Globals.paused = false
		menu.emit_signal("deactivate")
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

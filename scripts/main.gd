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
signal intro_sequence_defeat
signal battle_start
signal battle_end

func _ready():
	set_up_main_menu()
	loading_start.connect(on_loading_start)
	loading_finished.connect(on_loading_finished)
	intro_sequence_defeat.connect(on_intro_defeat)
	new_game.connect(on_new_game)
	load_game.connect(on_load_game)
	settings.connect(on_settings)
	exit.connect(on_exit)
	Globals.main = self

func set_up_main_menu():
	main_menu = main_menu_scene.instantiate()
	ui_container.add_child(main_menu)
	if loading_screen != null:
		loading_screen.emit_signal("finished_loading")

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
	Globals.apply_player_data()
	Globals.player.level_up_check() #to make the exp threshold correct

func load_map(map_name: String):
	emit_signal("loading_start")
	if Globals.player != null:
		Globals.player_controls(false)
	Globals.world_config_data["current_map"] = map_name
	BattleManagerTb.enemies.clear() #any allies need to be outside of the map scene for this to function properly
	var map_to_load = load(str("res://scenes/maps/", Globals.world_config_data["current_map"], ".tscn"))
	map = map_to_load.instantiate()
	await loading_active
	if map_container.get_children() != []: #if a map is already loaded: remove it
		Globals.player_config_data["position"] = Vector3(0, 0, 0) #wipe saved spawn position
		var loaded_map = map_container.get_child(0)
		loaded_map.queue_free()
	map_container.add_child(map)
	if Globals.player != null:
		if Globals.player_config_data["position"] == Vector3(0, 0, 0):
			Globals.player.global_position = map.player_spawn_pos
		else: Globals.player.set("global_position", Globals.player_config_data["position"])
	map.spawn_npcs()
	await get_tree().create_timer(1).timeout #artificial delay
	emit_signal("loading_finished")
	if Globals.player != null && !DialogueManager.dialogue_active && !Globals.cutscene_active:
		Globals.player_controls(true)
		if map.map_name == "Throne Room":
			Globals.can_player_attack = false

func reset_game():
	Globals.game_started = false
	for child in map_container.get_children():
		child.queue_free()
	for child in npc_container.get_children():
		child.queue_free()
	BattleManagerTb.allies.clear()
	BattleManagerTb.enemies.clear()
	Globals.player.queue_free()
	set_up_main_menu()

func start_game():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DialogueManager.emit_signal("loading_complete")
	load_map(Globals.world_config_data["current_map"])
	set_up_ability_menu()
	spawn_player()
	Globals.game_started = true
	Globals.paused = false
	await loading_finished
	main_menu.queue_free()

func on_loading_start():
	loading_screen = loading_screen_scene.instantiate()
	ui_container.add_child(loading_screen)

func on_loading_finished():
	if loading_screen == null:
		return
	loading_screen.emit_signal("finished_loading")
	if map.map_name == "Throne Room":
			Globals.can_player_attack = false

func on_new_game():
	Globals.save_config_file(true)
	start_game()
	intro_sequence()

func on_load_game():
	Globals.load_config_file("world")
	Globals.load_config_file("player")
	if Globals.world_config_data["new_save"] == false:
		start_game()
	else: 
		Globals.system_message("No save file available")

func on_settings():
	main_menu.options.visible = !main_menu.options.visible

func on_exit():
	get_tree().quit()

func _input(_event):
	if Input.is_action_just_pressed("menu") && Globals.game_started && !BattleManagerTb.battle_active && !DialogueManager.dialogue_active && !Globals.cutscene_active:
		toggle_menu()

func narrate(lines, image_path, darken_on_line):
	narrator = narrator_scene.instantiate()
	ui_container.add_child(narrator)
	narrator.narrate(lines, image_path, darken_on_line)

func intro_sequence():
	Globals.game_started = false
	Globals.paused = true
	Globals.player_controls(false)
	var lines: Array[String] = [
		"You are the Hero of humanity, sent on a mission to defeat the Demon King and put an end to their tyranny.",
		"After countless of hard fought battles, you finally arrive at the Demon King's chamber."
	]
	await loading_finished
	narrate(lines, "intro_view", -1)
	await narrator_finished
	Globals.paused = false
	Globals.game_started = true
	Globals.player.emit_signal("intro_talk_start")
	Globals.set_player_intro_stats(true)

func on_intro_defeat():
	load_map("fields_of_defeat")
	Globals.player.move_speed = 7.0
	var lines: Array[String] = [
		"Some time later.",
		"With the hero dead, humanity could no longer hold out against demonkind.",
		"One by one, cities, landmarks, every trace of humanity would face destruction by the demons.",
		"Was this truly the end for humankind?",
		"...",
		'A voice reaches out to you: \n "Wont you rise, once more?"'
	]
	await loading_finished
	narrate(lines, "intro_defeat_view", 4)
	await narrator_finished
	Globals.set_player_intro_stats(false)
	lines = [
		"...",
	]
	Globals.player.speech_audio_player.stream = Globals.player.dialogue_sfx
	DialogueManager.start_dialogue(lines, Globals.player, true)
	Globals.intro_completed = true

func toggle_menu():
	if !Globals.paused:
		Globals.paused = true
		menu.emit_signal("activate")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Globals.paused:
		Globals.paused = false
		menu.emit_signal("deactivate")
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

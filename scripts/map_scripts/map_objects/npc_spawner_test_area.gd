extends Node3D

@onready var options = $CanvasLayer/OptionContainer
@onready var npc_spawn_buttons = $CanvasLayer/NPCButtonContainer
@onready var npc_option_buttons = $CanvasLayer/NPCOptionsContainer
@onready var player_stat_container = $CanvasLayer/PlayerStatContainer
@export var interact_radius: float = 3.0
var npcs: Array
var npc: Object

signal options_selected

func _ready():
	Globals.add_interact(self, false)
	options.visible = false
	npc_spawn_buttons.visible = false
	npc_option_buttons.visible = false
	player_stat_container.visible = false
	var dir = DirAccess.open("res://scenes/NPC/characters/")
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tscn"):
			npcs.append(file_name)
		elif file_name.ends_with(".tmp"):
			pass
		file_name = dir.get_next()
	for npc_file in npcs:
		var button = Button.new()
		button.text = npc_file
		npc_spawn_buttons.add_child(button)
		button.connect("pressed", on_spawn_button_pressed.bind(npc_file))
	
	for data_type in Globals.player_config_data.keys():
		match typeof(Globals.player_config_data[data_type]):
			TYPE_INT:
				var data_label = Label.new()
				player_stat_container.add_child(data_label)
				data_label.text = str(data_type) + ": "
			
				var data_field = LineEdit.new()
				player_stat_container.add_child(data_field)
				data_field.placeholder_text = str(data_type)
				data_field.text = str(Globals.player_config_data[data_type])
				data_field.connect("text_changed", on_stat_changed.bind(data_field))
		
		#player_config_data[data_type] = player.get(data_type)

func interact_action():
	options.visible = true
	Globals.player_controls(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func exit_menu():
	Globals.player_controls(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func on_spawn_button_pressed(filename: String):
	var npc_scene = load("res://scenes/NPC/characters/" + filename)
	npc = npc_scene.instantiate()
	npc.global_position = Vector3(Globals.main.npc_container.get_children().size()*5, 5, 0)
	npc_spawn_buttons.visible = false
	npc_option_buttons.visible = true

func _on_enemy_button_toggled(toggled_on):
	if !toggled_on:
		npc.side = "enemy"
	elif toggled_on:
		npc.side = "ally"

func _on_npc_finished_button_pressed():
	npc_option_buttons.visible = false
	Globals.main.npc_container.add_child(npc)
	Globals.system_message("Spawned: " + npc.Cname)
	exit_menu()

func on_stat_changed(new_text, stat_holder):
	Globals.player_config_data[stat_holder.placeholder_text] = int(stat_holder.text)

func _on_stats_finished_button_pressed():
	Globals.apply_player_data()
	player_stat_container.visible = false
	exit_menu()

func _on_spawn_button_pressed():
	options.visible = false
	Globals.system_message("Select NPC to spawn")
	npc_spawn_buttons.visible = true

func _on_stat_button_pressed():
	options.visible = false
	player_stat_container.visible = true

func _on_batle_button_pressed():
	options.visible = false
	BattleManagerTb.start_battle(BattleManagerTb.allies, BattleManagerTb.enemies)

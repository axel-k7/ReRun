extends Node3D

@export var interact_radius: float = 3.0
var npcs: Array

func _ready():
	$Control.visible = false
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
		$Control.add_child(button)
		button.connect("pressed", on_spawn_button_pressed.bind(npc_file))

func interact_action():
	Globals.system_message("Select NPC to spawn")
	Globals.player_controls(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Control.visible = true

func on_spawn_button_pressed(filename: String):
	var npc_scene = load("res://scenes/NPC/characters/" + filename)
	var npc = npc_scene.instantiate()
	Globals.main.npc_container.add_child(npc)
	Globals.system_message("Spawned: " + npc.name)
	Globals.player_controls(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Control.visible = false
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

extends Node

@export var interact_radius: float = 3.0
var choice_screen_scene = preload("res://scenes/ui/choice_screen.tscn")

func _ready():
	Globals.add_interact(self, false)

func interact_action():
	var choice_screen = choice_screen_scene.instantiate()
	Globals.main.ui_container.add_child(choice_screen)
	choice_screen.visible = false
	var lines: Array[String] = [
		"I suppose it's time for a little rest.",
		"The voice I heard, what does it mean for me to do?",
		"All that is left for me in this world is revenge.",
		"...",
		"Is this really the path I want to follow?",
	]
	Globals.main.narrate(lines, "none", 4)
	await Globals.main.narrator_finished
	Globals.player_controls(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	choice_screen.visible = true

extends Node

@export var type: String = "interactable"

var lines: Array = [
	"Line 1",
	"Line 2",
	"Line 3"
]

func _ready():
	Globals.add_interact(self)

func interact_action():
	DialogueManager.start_dialogue(lines)

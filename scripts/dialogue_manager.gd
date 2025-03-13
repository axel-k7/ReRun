extends Node

@onready var dialogue_scene = preload("res://scenes/ui/dialogue.tscn")
var dialogue

func _ready():
	dialogue = dialogue_scene.instantiate()
	self.add_child(dialogue)

func start_dialogue(lines: Array):
	dialogue.update_text(lines)

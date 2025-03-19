extends Node

@onready var dialogue_scene = preload("res://scenes/ui/dialogue.tscn")
var dialogue

func _ready():
	dialogue = dialogue_scene.instantiate()
	self.add_child(dialogue)
	dialogue.dialogue_over.connect(dialogue._on_dialogue_over)

func start_dialogue(lines: Array, target: Object):
	dialogue.update_text(lines, target)

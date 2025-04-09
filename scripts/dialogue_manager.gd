extends Node

@onready var dialogue_scene = preload("res://scenes/ui/dialogue.tscn")
var dialogue_active: bool = false
var current_dialogue_target
var dialogue

signal dialogue_over

func _ready():
	dialogue_over.connect(on_dialogue_over)
	dialogue = dialogue_scene.instantiate()
	self.add_child(dialogue)
	dialogue.dialogue_over.connect(dialogue._on_dialogue_over)

func start_dialogue(lines: Array, target: Object, continue_after: bool):
	current_dialogue_target = target
	if target.dialogue_finished == false:
		if dialogue_active == false:
			dialogue_active = true
			print("dialogue started with: ", target.name)
			if BattleManagerTb.battle_active == true:
				BattleManagerTb.battle_paused = true
			dialogue.set_up_dialogue(target)
			dialogue.update_text(lines, target, continue_after)
		elif dialogue_active == true:
			dialogue.update_text(lines, target, continue_after)
	else: return

func on_dialogue_over():
	dialogue_active = false

extends Node

@onready var dialogue_scene = preload("res://scenes/ui/dialogue.tscn")
var dialogue_active: bool = false
var current_dialogue_target
var dialogue

signal loading_complete
signal dialogue_over

func _ready() -> void:
	dialogue_over.connect(on_dialogue_over)
	loading_complete.connect(set_up_dialogue)

func set_up_dialogue():
	dialogue = dialogue_scene.instantiate()
	Globals.main.ui_container.add_child(dialogue)
	dialogue.dialogue_over.connect(dialogue._on_dialogue_over)

func start_dialogue(lines: Array, target: Object, continue_after: bool):
	current_dialogue_target = target
	if !target.dialogue_finished:
		if !dialogue_active:
			dialogue_active = true
			if BattleManagerTb.battle_active:
				BattleManagerTb.battle_paused = true
			Globals.can_interact = false
			Globals.player.camera.look_at(target.global_position)
			dialogue.set_up_dialogue(target)
			dialogue.update_text(lines, target, continue_after)
		elif dialogue_active:
			dialogue.update_text(lines, target, continue_after)
	else: return

func on_dialogue_over():
	Globals.player.camera.rotation = Vector3.ZERO
	dialogue_active = false

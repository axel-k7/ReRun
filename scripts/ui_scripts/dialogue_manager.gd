extends Node

@onready var dialogue_scene = preload("res://scenes/ui/dialogue.tscn")
var dialogue_active: bool = false
var movement_after_saved: bool = false
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

func start_dialogue(lines: Array, target: Object, movement_after: bool):
	current_dialogue_target = target
	if !target.dialogue_finished:
		if !dialogue_active:
			dialogue_active = true
			if BattleManagerTb.battle_active:
				BattleManagerTb.battle_paused = true
				Globals.main.ui_container.visible = true
			Globals.can_interact = false
			if !Globals.player == null && BattleManagerTb.battle_active == false: 
				Globals.player.camera.look_at(target.global_position)
			dialogue.set_up_dialogue(target)
			dialogue.update_text(lines, target, movement_after)
			movement_after_saved = movement_after
		elif dialogue_active:
			dialogue.update_text(lines, target, movement_after_saved)
	else: return

func on_dialogue_over():
	Globals.player.camera.transform.basis = Basis()
	dialogue_active = false

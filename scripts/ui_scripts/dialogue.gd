extends Node

@onready var text_label: Label = $DialogueContainer/VBoxContainer/TextContainer/Text
@onready var name_label: Label = $DialogueContainer/VBoxContainer/Name
@onready var container: HSplitContainer = $DialogueContainer
@onready var character_portrait: TextureRect = $DialogueContainer/TextureRect
@onready var background: ColorRect = $ColorRect
@onready var letter_timer: Timer = $letterTimer

signal dialogue_over

var line_index = 0

func _ready():
	self.visible = false

func set_up_dialogue(target: Object):
	self.visible = true
	DialogueManager.dialogue_active = true
	Globals.player_controls(false)
	name_label.text = target.Cname
	character_portrait.texture = target.image

func update_text(lines: Array, target: Object, movement_after: bool):
	text_label.visible_characters = 0
	Globals.can_interact = false
	if line_index < lines.size():
		text_label.text = lines[line_index]
		for letter_index in lines[line_index].length():
			text_label.visible_characters += 1
			if !target.speech_audio_player == null:
				target.speech_audio_player.play()
			letter_timer.start()
			await letter_timer.timeout
	
	line_index += 1
	Globals.can_interact = true
	if line_index > lines.size():
		self.visible = false
		Globals.player_controls(movement_after)
		dialogue_over.emit(target)
		text_label.text = ""
		line_index = 0
		
func _on_dialogue_over(target: Object):
	if target.has_method("dialogue_over"):
		DialogueManager.dialogue_active = false
		DialogueManager.emit_signal("dialogue_over")
		target.dialogue_over()
	else: return

extends Node

@onready var text_label: Label = $DialogueContainer/VBoxContainer/Text
@onready var name_label: Label = $DialogueContainer/VBoxContainer/Name
@onready var letter_timer: Timer = $letterTimer

signal dialogue_over

var line_index = 0

func _ready():
	self.visible = false
	self.position = Vector2(-get_viewport().get_visible_rect().size.x/4, get_viewport().get_visible_rect().size.y/2-self.size.y)

func set_up_dialogue(target):
	self.visible = true
	DialogueManager.dialogue_active = true
	Globals.player_controls(false)
	name_label.text = target.Cname

func update_text(lines: Array, target: Object, continue_after: bool):
	print("current dialogue target: ", target.name)
	text_label.visible_characters = 0
	if line_index < lines.size():
		text_label.text = lines[line_index]
		for letter_index in lines[line_index].length():
			text_label.visible_characters += 1
			target.audio.play()
			letter_timer.start()
			await letter_timer.timeout
	
	line_index += 1
	Globals.can_interact = true
	if line_index > lines.size():
		dialogue_over.emit(target)
		self.visible = false
		Globals.player_controls(continue_after)
		text_label.text = ""
		line_index = 0
		
func _on_dialogue_over(target: Object):
	if target.has_method("dialogue_over") == true:
		print("dialogue over with: ", target.name)
		DialogueManager.dialogue_active = false
		target.dialogue_over()
	else: return

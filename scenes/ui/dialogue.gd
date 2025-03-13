extends Node

@onready var text_label: Label = $HSplitContainer/VBoxContainer/Text
@onready var name_label: Label = $HSplitContainer/VBoxContainer/Name
@onready var letter_timer: Timer = $letterTimer
var line_index = 0
var letter_index = 0

func _ready():
	text_label.autowrap_mode = 1

func update_text(lines: Array, target: Object):
	self.visible = true
	Globals.can_move = false
	Globals.can_interact = false
	name_label.text = target.Cname
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
		self.visible = false
		Globals.can_move = true
		text_label.text = ""
		line_index = 0
		

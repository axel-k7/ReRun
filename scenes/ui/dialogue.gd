extends Node

@onready var label: Label = $Label
@onready var letter_timer: Timer = $letterTimer
var line_index = 0
var letter_index = 0

func update_text(lines: Array):
	self.visible = true
	Globals.can_move = false
	label.visible_characters = 0
	if line_index < lines.size():
		label.text = lines[line_index]
		for letter_index in lines[line_index].length():
			label.visible_characters += 1
			letter_timer.start()
			await letter_timer.timeout
	
	line_index += 1
	if line_index > lines.size():
		self.visible = false
		Globals.can_move = true
		label.text = ""
		line_index = 0
		

extends Control

@onready var message: Label = $Label
@onready var wait_timer: Timer = $Timer
@onready var background: TextureRect = $Background
@onready var next_icon: TextureRect = $MarginContainer/Icon
var gallery_path: String
var lines: Array[String] = []
var line_index = 0
var can_continue: bool = false
var time: float = 0
var dark_on_line

func _process(delta):
	if can_continue == true:
		time += delta
		next_icon.modulate.a = sin(time)

func narrate(given_lines: Array[String], image_name: String, darken_on_line: int):
	dark_on_line = darken_on_line
	if dark_on_line == 1:
		darken_background()
	Globals.cutscene_active = true
	Globals.paused = true
	if image_name != "none":
		var image = load("res://vfx/narration_graphics/" + image_name + ".png")
		background.texture = image
	next_icon.modulate.a = 0
	background.size.y = get_viewport_rect().size.y
	background.position = Vector2(0,0)
	message.size = get_viewport_rect().size/2
	lines = given_lines
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_text()
	wait()
	var tween = get_tree().create_tween()
	tween.tween_property(background, "position", Vector2(-background.size.x+get_viewport_rect().size.x, 0), 10)
	await tween.finished
	tween.stop()
	tween.tween_callback(free)

func darken_background():
	var tween = get_tree().create_tween()
	tween.tween_property($ColorRect, "color", Color.BLACK, 1.5)
	await tween.finished
	tween.stop()
	tween.tween_callback(free)

func _input(_event):
	if Input.is_action_pressed("interact") && can_continue:
		next_icon.modulate.a = 0
		line_index += 1
		if dark_on_line != -1 && line_index == dark_on_line-1:
			darken_background()
		update_text()
		wait()

func update_text():
	if line_index < lines.size():
		can_continue = false
		message.text = lines[line_index]
	else: deactivate()

func wait():
	wait_timer.start()
	await wait_timer.timeout
	can_continue = true
	time = 0

func deactivate():
	var tween = get_tree().create_tween()
	tween.tween_property(background, "modulate:a", 0, 1)
	await tween.finished
	tween.stop()
	tween.tween_callback(free)
	Globals.main.emit_signal("narrator_finished")
	Globals.cutscene_active = false
	Globals.paused = false
	self.queue_free()

extends Control

@onready var message: Label = $Label
@onready var wait_timer: Timer = $Timer
@onready var background: TextureRect = $TextureRect
var gallery_path: String
var lines: Array[String] = []
var line_index = 0
var can_continue: bool = false

func narrate(given_lines: Array[String], image_path: String):
	var image = load(image_path)
	background.texture = image
	background.size.y = get_viewport_rect().size.y
	background.position = Vector2(0,0)
	message.size = get_viewport_rect().size/2
	lines = given_lines
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	update_text()
	wait()
	var tween = get_tree().create_tween()
	tween.tween_property(background, "position", Vector2(-background.size.x+get_viewport_rect().size.x, 0), 10)
	await tween.finished
	tween.stop()
	tween.tween_callback(queue_free)

func _input(event):
	if Input.is_action_pressed("interact") && can_continue:
		line_index += 1
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

func deactivate():
	var tween = get_tree().create_tween()
	tween.tween_property(background, "modulate:a", 0, 1)
	await tween.finished
	tween.stop()
	tween.tween_callback(queue_free)
	Globals.main.emit_signal("narrator_finished")
	self.queue_free()

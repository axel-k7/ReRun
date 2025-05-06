extends Node

@onready var background: ColorRect = $ColorRect

signal finished_loading

func _ready() -> void:
	background.modulate.a = 0
	finished_loading.connect(on_finished_loading)
	fade_screen()

func fade_screen():
	var tween = create_tween()
	tween.tween_property(background, "modulate:a", 1, 0.5)

func on_finished_loading():
	var tween = create_tween()
	tween.tween_property(background, "modulate:a", 0, 1)
	await tween.finished
	self.queue_free()

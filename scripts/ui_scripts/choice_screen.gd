extends Control

var lines: Array[String]

func _on_yes_button_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Globals.player.emit_signal("rampage")
	Globals.main.load_map("forest")
	self.queue_free()

func _on_no_button_pressed():
	self.visible = false
	lines = [
		"Then let's end this here."
	]
	DialogueManager.start_dialogue(lines, Globals.player, false)
	await DialogueManager.dialogue_over
	get_tree().quit()

func _on_timer_timeout():
	$TestAreaButton.visible = true

func _on_test_area_button_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Globals.main.load_map("test_area")
	self.queue_free()

extends Map

func reset_function():
	toggle_boss_door(false)
	#because the only way to trigger a map reset when this map is active is by dying, the intro sequence will be continued through here
	Globals.main.emit_signal("intro_sequence_defeat")


func _on_boundary_body_entered(body):
	if body.name == "player":
		Globals.main.emit_signal("intro_sequence_defeat")

extends Map

var realtime_combat_triggered: bool = false


func _on_combat_trigger_body_entered(body):
	if body.name == "player" && !realtime_combat_triggered:
		Globals.can_player_attack = true
		realtime_combat_triggered = true
		Globals.system_message("LMB - Attack \n RMB - Block \n Q - Ability Menu \n E - Ability")

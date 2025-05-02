extends NPC

func get_variables():
	weapon = $Claw
	attacks = []
	speech_audio_player = $dialogue_sfx
	attack_audio_player = $attack_sfx
	attack_animation = $attack_animation
	body_animation = $body_animation
	attack_idle_timer = $attack_timer
	raycast = $RayCast3D
	self.add_to_group(side)
	get_weapon_info()

func select_attack():
	attack_type = "weapon"

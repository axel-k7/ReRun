extends NPC

func interact_action():
	speech_audio_player.stream = dialogue_sfx
	DialogueManager.start_dialogue(lines, self, false)
	if DialogueManager.dialogue.line_index == lines.size()-1 && !BattleManagerTb.enemies.has(self):
		BattleManagerTb.enemies.append(self)

func dialogue_over_function():
	if !BattleManagerTb.battle_active:
		BattleManagerTb.start_battle(BattleManagerTb.allies, BattleManagerTb.enemies)

func get_variables():
	weapon = $Spear
	attacks = [
		[ "Spear Lunge", 25, 1, "local", 2, 2, false],
		[ "Fireball", 15, 3, "instance", -1, 1, false],
		[ "Inferno", 50, 15, "instance", -1, 1, true],
	]
	speech_audio_player = $dialogue_sfx
	attack_audio_player = $attack_sfx
	attack_animation = $attack_animation
	body_animation = $body_animation
	attack_idle_timer = $attack_timer
	stun_timer = $stun_timer
	raycast = $RayCast3D
	self.add_to_group(side)
	get_weapon_info()

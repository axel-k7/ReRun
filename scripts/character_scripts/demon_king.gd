extends NPC

func get_variables():
	weapon = $greatsword
	speech_audio_player = $dialogue_sfx
	attack_audio_player = $attack_sfx
	attack_animation = $attack_animation
	body_animation = $body_animation
	attack_idle_timer = $attack_timer
	raycast = $RayCast3D
	self.add_to_group(side)
	get_weapon_info()
	attacks = [
		[ "Death Slash", 500, 1, "local", 1, false],
		[ "Stomp", 500, 1, "local", 1, false],
	]

func interact_action():
	DialogueManager.start_dialogue(lines, self, false)

func dialogue_over():
	DialogueManager.emit_signal("dialogue_over")
	if dialogue_index == 1:
		BattleManagerTb.enemies.append(self)
		BattleManagerTb.start_battle(BattleManagerTb.allies, BattleManagerTb.enemies)
	if dialogue_index == 2 && BattleManagerTb.battle_active:
		BattleManagerTb.battle_scene.end_battle("")
	if dialogue_index == 3 && !BattleManagerTb.battle_active:
		can_move = true
		stationary = false
		Globals.main.enable_realtime()
	dialogue_index += 1
	if dialogue_index > dialogue_amount:
		dialogue_finished = true

func on_damaged(amount: int):
	hp -= amount
	damaged_index += 1
	if damaged_index == 1:
		lines = [
			"Attacking in turns, huh.",
			"Truly, you are no better than a rat.",
			"I will not stand for this any longer!",
			"Fight me, coward!"
		]
		DialogueManager.start_dialogue(lines, self, false)

func tb_attack(target: Object, _side: Array): #side is for custom npcs in need of special targetting
	if target.name == "Hero" && _side.size() > 1:
		target = _side[randi_range(0, _side.size()-1)]
		tb_attack(target, _side)
		print("stopped")
		return
	print("continued")
	var chosen_attack = randi_range(0, attacks.size()-1)
	var attack = attacks[chosen_attack]
	var atk_name = attack[0]
	var dmg = attack[1]
	var cost = attack[2]
	BattleManagerTb.battle_scene.action_message(self.Cname + " used " + atk_name + " on " + target.name + "!")
	Globals.damage(target, dmg)

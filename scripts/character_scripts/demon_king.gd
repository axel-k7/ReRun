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
		[ "Death Slash", 300, 1, "local", 1, false],
		[ "Stomp", 300, 1, "local", 1, false],
	]

func interact_action():
	DialogueManager.start_dialogue(lines, self, false)
	Globals.main.map.toggle_boss_door(true)

func dialogue_over():
	dialogue_index += 1
	DialogueManager.emit_signal("dialogue_over")
	if dialogue_index == 1:
		BattleManagerTb.enemies.append(self)
		BattleManagerTb.start_battle(BattleManagerTb.allies, BattleManagerTb.enemies)
	elif dialogue_index == 2 && BattleManagerTb.battle_active:
		BattleManagerTb.battle_scene.end_battle("")
		lines = [
			"DIE!!"
		]
		await get_tree().create_timer(2).timeout
		DialogueManager.start_dialogue(lines, self, true)
	elif dialogue_index == 3:
		can_attack = true
		can_move = true
		stationary = false
		Globals.player.move_speed = 3.0
		Globals.can_player_attack = false
	if dialogue_index >= dialogue_amount:
		dialogue_finished = true

func on_damaged(amount: int):
	hp -= amount
	damaged_index += 1
	if damaged_index == 2:
		lines = [
			"Taking turns attacking? Shameless.",
			"Truly, you are no better than a rat.",
			"Face me in real combat, coward!"
		]
		DialogueManager.start_dialogue(lines, self, false)

func select_attack():
	var random_num = randi_range(1, 4)
	if random_num <= 3:
		attack_type = "weapon"
	elif random_num > 3:
		attack_type = "ability"

func tb_attack(target: Object, _side: Array):
	if target.name == "Hero" && _side.size() > 1: #target any party member that isnt the player first
		target = _side[randi_range(0, _side.size()-1)]
		tb_attack(target, _side)
		return
	var chosen_attack = randi_range(0, attacks.size()-1)
	var attack = attacks[chosen_attack]
	var atk_name = attack[0]
	var dmg = attack[1]
	var cost = attack[2]
	BattleManagerTb.battle_scene.action_message(self.Cname + " used " + atk_name + " on " + target.name + "!")
	Globals.damage(target, dmg)

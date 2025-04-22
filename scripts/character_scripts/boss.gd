extends "res://scripts/character_scripts/NPC.gd"

var actions_taken: int = 0
var times_damaged: int = 0
var dialogue_index: int = 0
var line_index: int = 0

func _ready() -> void:
	get_variables()
	BattleManagerTb.allies.append(self)
	audio.stream = dialogue_sfx
	self.add_to_group("NPC")
	update_lines()

func get_variables():
	max_hp = 500
	hp = max_hp
	max_mp = 100000
	mp = max_mp
	attacks = [
		["Mega Crush", 15, 3]
	]
	
	weapon = $Sword
	audio = $AudioStreamPlayer3D
	raycast = $RayCast3D
	attack_animation = $attack_animation
	attack_idle_timer = $attack_timer
	
	self.add_to_group(side)
	get_weapon_info()

func movement(_delta: float):
	pass

func update_lines():
	dialogue_index += 1
	if dialogue_index == 1:
		lines = [
			"boss line 1:1",
			"boss line 1:2",
			"boss line 1:3"
		]
	elif dialogue_index == 2:
		lines = [
			"boss line 2:1",
			"boss line 2:2",
			"boss line 2:3"
		]

func tb_attack(target: Object, side: Array):
	if BattleManagerTb.allies.has(self):
		if actions_taken > 2:
			for party_member in side:
				if party_member.name == "hero":
					target = party_member
		if actions_taken == 2:
			attacks.append(["Inferno", 50, 10])
		if actions_taken == 3:
			attacks.clear()
			attacks.append(["Ego", 10000, 0]) 
	var chosen_attack = randi_range(0, attacks.size()-1)
	var attack = attacks[chosen_attack]
	var atk_name = attack[0]
	var dmg = attack[1]
	var cost = attack[2]
	
	Globals.damage(target, dmg)
	actions_taken += 1

func on_damaged(amount: int):
	hp -= amount
	times_damaged += 1
	if times_damaged == 6 && BattleManagerTb.allies.has(self):
		DialogueManager.start_dialogue(lines, self, false)
	if hp <= 0:
		die()

func dialogue_over():
	if dialogue_index == 1:
		BattleManagerTb.battle_scene.end_battle("victory")
		await battle_over
		Globals.player_controls(false)
		BattleManagerTb.allies.clear()
		BattleManagerTb.allies.append(Globals.player)
		BattleManagerTb.enemies.append(self)
		update_lines()
		DialogueManager.start_dialogue(lines, self, false)
	elif dialogue_index == 2:
		BattleManagerTb.start_battle(BattleManagerTb.allies, BattleManagerTb.enemies)

func die():
	Globals.player.exp += exp_given
	await get_tree().create_timer(2).timeout
	self.queue_free()

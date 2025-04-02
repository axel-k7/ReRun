extends "res://scripts/character_scripts/NPC.gd"

var actions_taken: int = 0

func _ready() -> void:
	BattleManagerTb.allies.append(self)
	audio.stream = dialogue_sfx
	self.add_to_group("NPC")
	
	max_hp = 5000
	hp = max_hp
	max_mp = 100000
	mp = max_mp
	attacks = [
		["Mega Crush", 15, 3],
	]

func movement(delta: float):
	pass

func tb_attack(target: Object, side: Array):
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
	
	if actions_taken > 1:
		for party_member in side:
			if party_member.name == "Hero":
				target = party_member
	
	Globals.damage(target, dmg)
	print(self.name, " used ", atk_name, " (", dmg, " DMG)", " on ", target.name, " for ", cost, " MP")
	actions_taken += 1

func on_damaged(amount: int):
	hp -= amount
	print(self.name, " took ", amount, " damage")
	print(self.name, " current hp: ", hp) 
	if hp <= 0:
		die()
	
func die():
	Globals.player.exp += exp_given
	#ragdoll()
	await get_tree().create_timer(2).timeout
	self.queue_free()

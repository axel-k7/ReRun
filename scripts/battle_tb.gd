extends Node

@onready var tb_preset_chr_scene = preload("res://scenes/ui/tb_preset_character.tscn")
@onready var attack_button = $BattleSceneTB_UI/UI_container/action_container/attack_button
@onready var guard_button = $BattleSceneTB_UI/UI_container/action_container/guard_button
@onready var item_button = $BattleSceneTB_UI/UI_container/action_container/item_button
@onready var player_hp_label: Label = $BattleSceneTB_UI/UI_container/stat_container/hp
@onready var player_mp_label: Label = $BattleSceneTB_UI/UI_container/stat_container/mp
@onready var atk_container = $BattleSceneTB_UI/Attack_container
@onready var atk_option_scene = preload("res://scenes/ui/tb_attack_preset.tscn")
@onready var camera = $BattleSceneTB_camera
@onready var allyNode = $Allies
@onready var enemyNode = $Enemies

var is_player_turn: bool
var turns: int
var selected_target
var action_index: int
var selecting_action: bool = false
signal action_taken

var enemies: Array[Object]
var allies: Array[Object]

func _ready():
	self.visible = false
	atk_container.visible = false
	set_process(false)

func _process(delta: float):
	player_hp_label.text = str(Globals.player.hp) + "/" + str(Globals.player.max_hp)
	player_mp_label.text = str(Globals.player.mp) + "/" + str(Globals.player.max_mp)
	if is_player_turn == true:
		var enemyIndex = 0
		var enemyAmount = enemies.size()
		selected_target = enemies[enemyIndex]
		if Input.is_action_pressed("right"):
			if enemyIndex < enemyAmount:
				enemyIndex += 1
			elif enemyIndex == enemyAmount:
				enemyIndex = 0
		if Input.is_action_pressed("left"):
			if enemyIndex < enemyAmount:
				enemyIndex -= 1
			elif enemyIndex == enemyAmount:
				enemyIndex = enemyAmount

func start_battle(ally_array: Array, enemy_array: Array):
	Globals.player_controls(false)
	self.visible = true
	Globals.player.camera.current = false
	camera.make_current()
	set_process(true)
	
	set_up_characters(ally_array, "ally")
	for ally in allyNode.get_children():
		allies.append(ally)
	set_up_characters(enemy_array, "enemy")
	for enemy in enemyNode.get_children():
		enemies.append(enemy)
	is_player_turn = true
	BattleManagerTb.battle_active = true
	turn_handler()

func end_battle(result: String):
	await get_tree().create_timer(2).timeout
	Globals.player_controls(true)
	self.visible = false
	Globals.player.camera.current = true
	BattleManagerTb.battle_active = false
	
	for child in allyNode.get_children():
		child.queue_free()
	for child in enemyNode.get_children():
		child.queue_free()
	BattleManagerTb.enemies.clear()
	set_process(false)
	
	if result == "defeat":
		Globals.player.global_position = Vector3(0, 0, 0)
		print("battle result: ", result)
	elif result == "victory":
		print("battle result: ", result)

func set_up_characters(characters, side: String):
	var characterIndex = 0
	for character in characters:
		var tb_character = tb_preset_chr_scene.instantiate()
		if side == "ally":
			allyNode.add_child(tb_character)
		elif side == "enemy":
			enemyNode.add_child(tb_character)
		tb_character.set_up_self(character, side, characterIndex)
		tb_character.die.connect(remove_from_party.bind(tb_character, side))
		characterIndex += 1

func remove_from_party(character, side):
	if side == "ally":
		allies.erase(character)
	elif side == "enemy":
		enemies.erase(character)


func turn_handler():
	if is_player_turn == true:
		turns = allies.size()
		if turns == 0:
			end_battle("defeat")
		action_index = 0
	elif is_player_turn == false:
		turns = enemies.size()
		if turns == 0:
			end_battle("victory")
		action_index = 0
		enemy_action()

func display_attacks(character: Object):
	selecting_action = true
	atk_container.visible = true
	atk_container.size.y = 40*character.attacks.size()
	for attack in character.attacks:
		var atk_option = atk_option_scene.instantiate()
		var atk_name = attack[0]
		var dmg = attack[1]
		var cost = attack[2]
		atk_container.add_child(atk_option)
		var atk_label_container = atk_option.get_child(0)
		atk_option.name = atk_name
		atk_label_container.get_child(0).text = atk_name
		atk_label_container.get_child(1).text = str(dmg) + " DMG"
		atk_label_container.get_child(2).text = str(cost) + " MP"
		atk_option.size = atk_label_container.size
		
		atk_option.pressed.connect(_atk_option_pressed.bind(character, atk_name, dmg, cost))

func _atk_option_pressed(attacker: Object, atk_name: String, damage: int, cost: int):
	Globals.damage(selected_target, damage)
	attacker.mp -= cost
	print(attacker.name, " used ", atk_name, "(", damage, " DMG)", " on ", selected_target.name, " for ", cost, " MP")
	emit_signal("action_taken")

func _on_attack_button_pressed():
	if is_player_turn == true && selecting_action == false:
		do_action("attack")

func _on_guard_button_pressed():
	if is_player_turn == true:
		do_action("guard")

func _on_item_button_pressed():
	if is_player_turn == true && selecting_action == false:
		do_action("item")
	

func do_action(action: String):
	if action == "attack":
		var acting_chr
		if is_player_turn == true:
			acting_chr = BattleManagerTb.allies[action_index]
			display_attacks(acting_chr)
		elif is_player_turn == false:
			acting_chr = BattleManagerTb.enemies[action_index]
			enemy_attack(acting_chr)
	await action_taken
	atk_container.visible = false
	for child in atk_container.get_children():
		child.queue_free()
	turns -= 1
	action_index += 1
	selecting_action = false
	print("turns left: ", turns)
	if turns <= 0 && is_player_turn == true:
		is_player_turn = false
		turn_handler()
	elif turns <= 0 && is_player_turn == false:
		is_player_turn = true
		turn_handler()

func enemy_action():
	if is_player_turn == false:
		print("enemy taking action")
		var wait_time: float = 1 + randf()
		await get_tree().create_timer(wait_time).timeout
		for turn_index in turns:
			var random_ally_index = randi_range(0, allies.size()-1)
			selected_target = allies[random_ally_index]
			do_action("attack")
		emit_signal("action_taken")

func enemy_attack(enemy):
	var chosen_attack = randi_range(0, enemy.attacks.size()-1)
	var attack = enemy.attacks[chosen_attack]
	var atk_name = attack[0]
	var dmg = attack[1]
	var cost = attack[2]
	
	Globals.damage(selected_target, dmg)
	print(enemy.name, " used ", atk_name, " (", dmg, " DMG)", " on ", selected_target.name, " for ", cost, " MP")
	

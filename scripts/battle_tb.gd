extends Node

@onready var tb_preset_chr_scene = preload("res://scenes/ui/tb_preset_character.tscn")
@onready var target_marker = $Select_marker
@onready var target_marker_anim = $Select_marker/AnimationPlayer
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

var acting_chr: Object
var is_player_acting: bool = false
var is_ally_turn: bool
var turns: int
var selected_target
var action_index: int
var selecting_action: bool = false
signal action_taken

var enemies: Array[Object]
var allies: Array[Object]
var acting_side: Array

var enemyIndex = 0
var enemyAmount

func _ready():
	target_marker_anim.play("rotate")
	self.visible = false
	atk_container.visible = false
	set_process(false)

func _process(delta: float):
	player_hp_label.text = str(Globals.player.hp) + "/" + str(Globals.player.max_hp)
	player_mp_label.text = str(Globals.player.mp) + "/" + str(Globals.player.max_mp)
	
	
	if is_player_acting == true:
		player_select_target()
		enemyAmount = enemies.size()-1
		if Input.is_action_just_pressed("right"):
			if enemyIndex < enemyAmount:
				enemyIndex += 1
			elif enemyIndex == enemyAmount:
				enemyIndex = 0
		if Input.is_action_just_pressed("left"):
			if enemyIndex <= enemyAmount && enemyIndex != 0:
				enemyIndex -= 1
			elif enemyIndex == 0:
				enemyIndex = enemyAmount

func player_select_target():
	target_marker.visible = true
	selected_target = enemies[enemyIndex]
	target_marker.position = selected_target.position
	var target_sprite_size: float = selected_target.sprite.texture.get_height()
	target_marker.scale.y = target_sprite_size/250
	target_marker.scale.x = target_sprite_size/250
	target_marker

func start_battle(ally_array: Array, enemy_array: Array):
	Globals.player_controls(false)
	self.visible = true
	target_marker.visible = false
	Globals.player.camera.current = false
	camera.make_current()
	set_process(true)
	
	set_up_characters(ally_array, "ally")
	for ally in allyNode.get_children():
		allies.append(ally)
	set_up_characters(enemy_array, "enemy")
	for enemy in enemyNode.get_children():
		enemies.append(enemy)
	is_ally_turn = true
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

func turn_handler():
	action_index = 0
	if is_ally_turn == true:
		turns = allies.size()
	elif is_ally_turn == false:
		turns = enemies.size()
	action_handler()

func action_handler():
	if is_ally_turn == true:
		acting_chr = BattleManagerTb.allies[action_index]
	elif is_ally_turn == false:
		acting_chr = BattleManagerTb.enemies[action_index]
	
	if acting_chr.is_in_group("NPC") == true:
		is_player_acting = false
		NPC_action()
	elif acting_chr.is_in_group("NPC") == false:
		is_player_acting = true
	print(acting_chr.name, " taking action")
	
	await action_taken
	atk_container.visible = false
	for child in atk_container.get_children():
		child.queue_free()
	turns -= 1
	action_index += 1
	selecting_action = false
	print("turns left: ", turns)
	if turns <= 0 && is_ally_turn == true:
		is_ally_turn = false
		turn_handler()
	elif turns <= 0 && is_ally_turn == false:
		is_ally_turn = true
		turn_handler()
	else: 
		if allies.size() > 0 && enemies.size() > 0:
			action_handler()
		elif enemies.size() <= 0:
			end_battle("victory")
		elif allies.size() <= 0:
			end_battle("defeat")

func do_action(action: String):
	if action == "attack":
		if acting_chr.is_in_group("NPC") == true:
			if is_ally_turn == true:
				acting_chr.tb_attack(selected_target, enemies)
			elif is_ally_turn == false:
				acting_chr.tb_attack(selected_target, allies)
		if acting_chr.is_in_group("NPC") == false:
			display_attacks(acting_chr)

func NPC_action():
	var random_character_index
	var wait_time: float = 1 + randf()
	await get_tree().create_timer(wait_time).timeout
	if is_ally_turn == true:
		random_character_index = randi_range(0, enemies.size()-1)
		selected_target = enemies[random_character_index]
	elif is_ally_turn == false:
		random_character_index = randi_range(0, allies.size()-1)
		selected_target = allies[random_character_index]
	do_action("attack")
	emit_signal("action_taken")

func remove_from_party(character, side):
	var character_index = 0
	if side == "ally":
		for ally in allies:
			if ally == character:
				allies.remove_at(character_index)
				BattleManagerTb.allies.remove_at(character_index)
			character_index += 1
	elif side == "enemy":
		for enemy in enemies:
			if enemy == character:
				enemies.remove_at(character_index)
				BattleManagerTb.enemies.remove_at(character_index)
			character_index += 1

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
	enemyIndex = 0
	is_player_acting = false
	target_marker.visible = false

func _on_attack_button_pressed():
	if is_player_acting == true && selecting_action == false:
		do_action("attack")

func _on_guard_button_pressed():
	if is_player_acting == true:
		do_action("guard")

func _on_item_button_pressed():
	if is_player_acting == true && selecting_action == false:
		do_action("item")
	

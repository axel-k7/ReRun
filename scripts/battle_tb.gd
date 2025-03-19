extends Node

@onready var tb_preset_scene = preload("res://scenes/ui/tb_preset_character.tscn")
@onready var attack_button = $BattleSceneTB_UI/UI_container/action_container/attack_button
@onready var guard_button = $BattleSceneTB_UI/UI_container/action_container/guard_button
@onready var item_button = $BattleSceneTB_UI/UI_container/action_container/item_button
@onready var hpLabel: Label = $BattleSceneTB_UI/UI_container/stat_container/hp
@onready var mpLabel: Label = $BattleSceneTB_UI/UI_container/stat_container/mp
@onready var camera = $BattleSceneTB_camera
@onready var allyNode = $Allies
@onready var enemyNode = $Enemies

var is_player_turn: bool = true
var turns: int = 1
var selected_target

func _ready():
	self.visible = false

func start_battle(allies: Array, enemies: Array):
	Globals.player_controls(false)
	self.visible = true
	Globals.player.camera.current = false
	camera.make_current()
	set_up_allies(allies)
	set_up_enemies(enemies)
	is_player_turn = true
	turns = allies.size()
	
	await get_tree().create_timer(3).timeout
	end_battle("defeat")

func end_battle(result: String):
	Globals.player_controls(true)
	self.visible = false
	Globals.player.camera.current = true
	for child in allyNode.get_children():
		child.queue_free()
	for child in enemyNode.get_children():
		child.queue_free()
	
	if result == "defeat":
		Globals.player.global_position = Vector3(0, 0, 0)
		print("battle result: ", result)
	elif result == "victory":
		print("battle result: ", result)

func set_up_allies(allies):
	var tb_character = tb_preset_scene.instantiate()
	for allyIndex in allies.size():
		allyNode.add_child(tb_character)
		tb_character.get_child(0).texture = allies[allyIndex].tb_sprite
		tb_character.name = allies[allyIndex].name

func set_up_enemies(enemies):
	var tb_character = tb_preset_scene.instantiate()
	for enemyIndex in enemies.size():
		allyNode.add_child(tb_character)
		tb_character.get_child(0).texture = enemies[enemyIndex].tb_sprite
		tb_character.name = enemies[enemyIndex].name

func damage(target: Object, amount: int):
	target.hp -= amount

func turn_handler():
	if is_player_turn == true:
		var enemyIndex = 0
		selected_target = BattleManagerTb.enemies[enemyIndex]
		if Input.is_action_pressed("right"):
			if enemyIndex < BattleManagerTb.enemies.size():
				enemyIndex += 1
			elif enemyIndex == BattleManagerTb.enemies.size():
				enemyIndex = 0
		if Input.is_action_pressed("left"):
			if enemyIndex < BattleManagerTb.enemies.size():
				enemyIndex -= 1
			elif enemyIndex == BattleManagerTb.enemies.size():
				enemyIndex = BattleManagerTb.enemies.size()
		for turnIndex in turns:
			pass
	elif is_player_turn == false:
		pass


func _on_attack_button_pressed():
	if is_player_turn == true:
		pass

func _on_guard_button_pressed():
	if is_player_turn == true:
		pass

func _on_item_button_pressed():
	if is_player_turn == true:
		pass

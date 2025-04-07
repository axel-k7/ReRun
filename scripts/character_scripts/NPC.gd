extends CharacterBody3D

@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var attack_timer: Timer = $attack_timer
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var weapon = $Sword
@export var Cname: String = "name"
@export var image: CompressedTexture2D = preload("res://vfx/smiley.png")
@export var dialogue_sfx: AudioStream = preload("res://sfx/hah.wav")
@export var hurt_sfx: AudioStream = preload("res://sfx/hurt_preset.wav")
@export var lines: Array[String] = [
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod temp",
	"Line 2",
	"Line 3"
]
@export var tb_sprite_enemy: CompressedTexture2D = preload("res://vfx/tb_preset.png")
@export var tb_sprite_ally: CompressedTexture2D = preload("res://vfx/tb_preset.png")
@export var interact_distance: int = 50

@export var move_speed: float = 3
var target_velocity = Vector3.ZERO
var fleeing: bool = false
var attacking: bool = true
var direction: Vector3 = Vector3.FORWARD
var can_move: bool = true
var attack_ready: bool = true

@export var exp_given: float = 50
var max_hp = 30
var hp = max_hp
var max_mp = 100
var mp = max_mp
@export var attacks: Array[Array] = [
		#Attack name (string), Damage(int), MP cost(int), -> NOT IMPLEMENTED  -> ||damage type(string), description(string)||
		[ "Lunge", 7, 2 ],
		[ "Bite", 3, 0 ]
	]

func _ready():
	BattleManagerTb.enemies.append(self)
	Globals.add_interact(self)
	audio.stream = dialogue_sfx
	self.add_to_group("NPC")

func _physics_process(delta: float):
	if can_move == true:
		movement(delta)

func interact_action():
	DialogueManager.start_dialogue(lines, self, false)
	can_move = false

func dialogue_over():
	if BattleManagerTb.battle_active == false:
		BattleManagerTb.start_battle(BattleManagerTb.allies, BattleManagerTb.enemies)
		can_move = true
	elif BattleManagerTb.battle_active == true:
		BattleManagerTb.battle_paused = false

func movement(delta: float):
	update_target_position(Globals.player.global_position)
	if fleeing == false && attacking == false || fleeing == true && attacking == true:
		neutral_movement(delta)
	elif fleeing == true && attacking == false:
		flee(delta)
	elif attacking == true && fleeing == false:
		fight_formation(delta)
	
	if not is_on_floor():
		velocity.y -= Globals.gravity * delta
	else:
		velocity.y = 0
	
	move_and_slide()

func update_target_position(position):
	nav_agent.target_position = position
	
func neutral_movement(delta):
	velocity = (nav_agent.get_next_path_position() - self.global_position).normalized() * move_speed

func flee(delta: float):
	look_at(Globals.player.global_position)
	if self.global_position.distance_to(Globals.player.position) <= 10:
		velocity = -(nav_agent.get_next_path_position() - self.global_position).normalized() * move_speed*1.5
	else: 
		velocity.x = 0
		velocity.z = 0

func fight_formation(delta: float):
	look_at(Globals.player.global_position)
	var distance_to_player = self.global_position.distance_to(Globals.player.position)
	target_velocity = transform.basis * direction * move_speed
	if distance_to_player > 5:
		velocity = (nav_agent.get_next_path_position() - self.global_position).normalized() * move_speed*1.5
	elif distance_to_player < 5 && distance_to_player > 3:
		velocity.x = 0
		velocity.z = 0
		
		if attack_ready == true:
			fight()
	elif distance_to_player < 3:
		velocity = -(nav_agent.get_next_path_position() - self.global_position).normalized() * move_speed/1.5

func fight():
	attack_ready = false
	animation.play("attack")
	attack_timer.start()
	await attack_timer.timeout
	attack_ready = true
	
func tb_attack(target: Object, side: Array): #side is for custom npcs in need of special targetting
	var chosen_attack = randi_range(0, attacks.size()-1)
	var attack = attacks[chosen_attack]
	var atk_name = attack[0]
	var dmg = attack[1]
	var cost = attack[2]
	
	Globals.damage(target, dmg)
	print(self.name, " used ", atk_name, " (", dmg, " DMG)", " on ", target.name, " for ", cost, " MP")

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


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "attack":
		weapon.empty_targets()

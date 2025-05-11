extends Character
class_name NPC

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var attack_particles: GPUParticles3D = $attack_particles
@onready var atk_particle_timer: Timer = $attack_particles/attack_particle_timer
@export var has_interaction: bool = false
@export var force_interaction: bool = false
@export var interact_radius: float = 2.0
@export var side: String = "enemy"
@export var stationary: bool = false
@export var exp_given: float = 50
@export var neutral_distance: float = 3
@export var flee_distance: float = 2
@export var always_aggro: bool = false
@export var can_drop_item: bool = false
@export var item_to_drop: PackedScene = preload("res://scenes/items/item_scenes/potion.tscn")

var fleeing: bool = false #for use in functions to be added:
var can_attack: bool = true # movement functions while not in combat
var can_move: bool = true
var direction: Vector3 = Vector3.FORWARD
var attack_type
var damaged_index: int = 0
var aggrod: bool = false

func _ready():
	get_variables()
	#BattleManagerTb.enemies.append(self)
	if has_interaction:
		Globals.add_interact(self, force_interaction)
	speech_audio_player.stream = dialogue_sfx
	self.add_to_group("NPC")

func get_variables():
	weapon = $Spear
	speech_audio_player = $dialogue_sfx
	attack_audio_player = $attack_sfx
	attack_animation = $attack_animation
	body_animation = $body_animation
	attack_idle_timer = $attack_timer
	stun_timer = $stun_timer
	raycast = $RayCast3D
	self.add_to_group(side)
	get_weapon_info()

func _physics_process(delta: float):
	if can_move && !BattleManagerTb.battle_active && !Globals.paused && !Globals.player == null:
		movement(delta)
	elif stationary && !Globals.player == null && !dead:
		look_at(Globals.player.global_position)

func movement(delta: float):
	if !aggrod || stationary: 
		velocity.x = 0
		velocity.z = 0
	if aggrod && !stationary || always_aggro && !stationary:
		update_target_position(Globals.player.global_position)
		fight_formation()
	if not is_on_floor():
		velocity.y -= Globals.gravity * delta
	else:
		velocity.y = 0
	
	move_and_slide()

func update_target_position(target_pos):
	nav_agent.target_position = target_pos

func fight_formation():
	var distance_to_player = self.global_position.distance_to(Globals.player.position)
	if self.global_position != Globals.player.global_position:
		look_at(Vector3(Globals.player.global_position.x, self.position.y, Globals.player.global_position.z))
	target_velocity = transform.basis * direction * move_speed
	if distance_to_player > neutral_distance:
		velocity = (nav_agent.get_next_path_position() - self.global_position).normalized() * move_speed*1.5
	elif distance_to_player < neutral_distance && distance_to_player > flee_distance:
		velocity.x = 0
		velocity.z = 0
		if attack_ready && can_attack:
			fight()
	elif distance_to_player < flee_distance:
		velocity = -(nav_agent.get_next_path_position() - self.global_position).normalized() * move_speed/1.5

func fight():
	if attack_ready:
		attack_ready = false
		select_attack()
		if wep_atk_index == 1:
			attack_particles.emitting = true
			atk_particle_timer.start()
			await atk_particle_timer.timeout
		do_attack(attack_type)

func select_attack():
	attack_type = randi_range(0, 100)
	if attack_type <= 10:
		attack_type = "ability"
		selected_ability = randi_range(0, attacks.size()-2)
	elif attack_type > 10:
		attack_type = "weapon"
	else:#elif attack_type == 3:
		attack_type = "projectile"
	

func tb_attack(target: Object, _side: Array): #side is for custom npcs in need of special targetting
	var chosen_attack = randi_range(0, attacks.size()-1)
	var attack = attacks[chosen_attack]
	var atk_name = attack[0]
	var dmg = attack[1]
	var cost = attack[2]
	BattleManagerTb.battle_scene.action_message(self.Cname + " used " + atk_name + " on " + target.name + "!")
	Globals.damage(target, dmg)

func stun(duration):
	can_move = false
	stun_timer.start(duration)
	await stun_timer.timeout
	if !dead:
		can_move = true

func drop_item():
	var item = item_to_drop.instantiate()
	Globals.main.map.add_child(item)
	item.global_position = self.global_position

func die():
	var drop_chance = randi_range(1, 10)
	if drop_chance > 7 && can_drop_item:
		drop_item()
	dead = true
	Globals.player.experience += exp_given
	Globals.player.emit_signal("exp_gained")
	self.rotate(Vector3(1, 0, 0), 0.5)
	death_effect()
	can_move = false
	can_attack = false
	await get_tree().create_timer(5).timeout
	self.queue_free()
	

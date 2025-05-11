extends Character

@export var sensitivity = 1000

@onready var pivot = $CameraPivot
@onready var camera = $CameraPivot/SpringArm3D/Camera3D
@onready var interact_marker = $PlayerInteractMarker
@onready var parry_timer = $ParryTimer
@onready var parry_cd_timer = $ParryCooldownTimer
@onready var stamina_regen_timer: Timer = $StaminaRegenTimer
@onready var base_move_speed = move_speed

var closest_interactable: Object
var sprint_multiplier: float = 1.5
var sprinting: bool = false
var recovering_stamina: bool = false
var enemies_aggrod: Array[Object] = []
var parrying: bool = false
var can_parry: bool = true
var possible_attacks: Array[Array] = [
	[ "Slash", 20, 5, "local", 1, 2.5, false],
	[ "Beam", 15, 10, "instance", 1, -1, false],
	[ "Inferno", 50, 50, "instance", 1, -1, true],
	[ "Sweep", 20, 2, "local", 2, 2, false],
]

signal intro_talk_start
signal inventory_updated
signal exp_gained
signal rampage

func _ready():
	get_variables()
	intro_talk_start.connect(intro_dialogue)
	exp_gained.connect(level_up_check)
	rampage.connect(start_rampage)
	block.connect(on_block)
	BattleManagerTb.allies.append(self)
	speech_audio_player.stream = dialogue_sfx

func _physics_process(delta):
	if !Globals.paused:
		movement_handler(delta)
		stamina_handler(delta)

func get_variables():
	raycast = $RayCast3D
	attack_animation = $AttackAnimationPlayer
	attack_idle_timer = $AttackIdleTimer
	stun_timer = $StunTimer
	speech_audio_player = $AudioStreamPlayer3D
	weapon = $Sword
	hurt_sfx
	self.add_to_group("ally")
	get_weapon_info()

func movement_handler(delta):
	if Globals.can_move:
		movement_inputs(delta)
		if !is_on_floor():
			velocity.y -= Globals.gravity * delta
		else:
			velocity.y = 0
		
		velocity.x = target_velocity.x
		velocity.z = target_velocity.z
		move_and_slide()

func movement_inputs(delta):
	var direction = Vector3.ZERO
	
	if !sprinting && !blocking:
		move_speed = base_move_speed
	if Input.is_action_pressed("sprint") && velocity != Vector3(0, 0, 0): 
		if stamina > 0:
			move_speed = base_move_speed*sprint_multiplier
			stamina -= delta*15
			sprinting = true
		else: sprinting = false
		recovering_stamina = false
		stamina_regen_timer.stop()
	
	var inputMap = {
	"forward": Vector3.FORWARD,
	"back": Vector3.BACK,
	"left": Vector3.LEFT,
	"right": Vector3.RIGHT,
	}
	for action in inputMap.keys():
		if Input.is_action_pressed(action):
			direction += inputMap[action]
		
	direction = direction.normalized()
	target_velocity = transform.basis * direction * move_speed

func _input(event):
	if !Globals.paused:
		camera_rotation(event)
		interact_input()
		attack_input()
	release_inputs()

func camera_rotation(event):
	if event is InputEventMouseMotion && Globals.can_rotate_camera:
		rotation.y -= event.relative.x / sensitivity
		pivot.rotation.x -= event.relative.y / sensitivity
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func interact_input():
	if Globals.interactables.size() > 0:
		if Globals.interactables[0] == null:
			return
		var interaction_target = Globals.interactables[0]
		if self.global_position.distance_to(interaction_target.global_position) < interaction_target.interact_radius && !DialogueManager.dialogue_active:
			if interaction_target.is_in_group("NPC"):
				if interaction_target.dead:
					return
			interact_marker.visible = true
			interact_marker.global_position = interaction_target.global_position
			interact_marker.look_at(camera.global_position)
			if Input.is_action_just_pressed("interact") && Globals.can_interact:
				interaction_target.interact_action()
				interact_marker.visible = false
		elif DialogueManager.dialogue_active && Globals.can_interact:
			if Input.is_action_just_pressed("interact"):
				DialogueManager.current_dialogue_target.interact_action()
		else: interact_marker.visible = false
	elif DialogueManager.dialogue_active && Globals.can_interact:
		if Input.is_action_just_pressed("interact"):
			DialogueManager.current_dialogue_target.interact_action()
	else: interact_marker.visible = false

func get_item(item_index, item_name, use): #call with either name or index for positional or first instance removal
	var item_scene: PackedScene
	if item_index == null:
		inventory.erase(item_name)
		item_scene = load("res://scenes/items/item_scenes/" + item_name + ".tscn")
	elif item_name == null:
		inventory.remove_at(item_index)
		item_scene = load("res://scenes/items/item_scenes/" + inventory[item_index] + ".tscn")
	var item: RigidBody3D = item_scene.instantiate()
	get_parent().add_child(item)
	item.global_position = self.global_position + Vector3(2, 0, 2)
	
	if use:
		item.interact_radius = 0
		item.use_item()
	emit_signal("inventory_updated")

func attack_input():
	if Globals.can_player_attack && attack_ready && !blocking:
		if Input.is_action_just_pressed("attack"):
			do_attack("weapon")
		if Input.is_action_just_pressed("ability"):
			do_attack("ability")
		if Input.is_action_just_pressed("ability_menu"):
			Globals.main.ability_menu.activate()
		if Input.is_action_just_released("ability_menu"):
			Globals.main.ability_menu.deactivate()
		if Input.is_action_just_pressed("block") && stamina > 0:
			do_block()

func do_block():
	attack_animation.play("block")
	stamina_regen_timer.stop()
	move_speed = base_move_speed/2
	blocking = true
	if can_parry:
		can_parry = false
		parrying = true
		parry_timer.start()
		await parry_timer.timeout
		parrying = false
		parry_cd_timer.start()
		await parry_cd_timer.timeout
		can_parry = true

func release_inputs():
	if Input.is_action_just_released("block") && attack_ready:
		blocking = false
		stamina_regen_timer.start()
		attack_animation.play("RESET")
	if Input.is_action_just_released("sprint"):
		sprinting = false
		stamina_regen_timer.start()

func stamina_handler(delta):
	if blocking:
		stamina_regen_timer.stop()
	
	if stamina < 100 && recovering_stamina && !blocking && !Globals.paused:
		stamina += delta*50
	stamina = clamp(stamina, 0, 100)

func stun(duration):
	Globals.player_controls(false)
	stun_timer.start(duration)
	await stun_timer.timeout
	Globals.player_controls(true)

func die():
	Globals.paused = true
	Globals.main.map.emit_signal("reset_map")

func level_up_check():
	exp_thold = 100 * level/2
	experience = clamp(experience, 0, exp_thold)
	if experience >= exp_thold && level < 50:
		level += 1
		experience = 0
		max_hp = 50 + level * 20 #could make the calculations for this an exponential function
		max_mp = 20 + level * 10
		if level % 5 == 0 && attacks.size() < 4:
			add_random_ability()
	exp_thold = 100 * level/2

func add_random_ability():
	var ability = possible_attacks[randi_range(0, possible_attacks.size()-1)]
	if !attacks.has(ability):
		attacks.append(ability)
		Globals.system_message("New ability unlocked: " + ability[0])
	else: add_random_ability()

func start_rampage():
	var tween = create_tween()
	tween.tween_property(camera.attributes, "dof_blur_amount", 1, 600)
	await tween.finished
	get_tree().quit()
	

func _on_enemy_range_body_entered(body: Node3D) -> void:
	if !body.is_in_group("NPC"):
		return
	else: 
		if body.side == "enemy":
			if !BattleManagerTb.enemies.has(body):
				BattleManagerTb.enemies.append(body)
			if "aggrod" in body && !body.aggrod:
				body.aggrod = true
				enemies_aggrod.append(body)
			if enemies_aggrod.size() > 0:
				Globals.in_combat = true
		elif body.side == "ally":
			if !BattleManagerTb.allies.has(body):
				BattleManagerTb.allies.append(body)

func _on_enemy_range_body_exited(body: Node3D) -> void:
	if !body.is_in_group("NPC") || !body.side == "enemy":
		return
	else: 
		if BattleManagerTb.enemies.has(body):
			BattleManagerTb.enemies.erase(body)
		if "aggrod" in body && body.aggrod:
			body.aggrod = false
			enemies_aggrod.erase(body)
		if enemies_aggrod.size() == 0:
			Globals.in_combat = false

func intro_dialogue():
	var intro_lines: Array[String] = [
		"Just a few more steps and all of this will finally be over...",
	]
	DialogueManager.start_dialogue(intro_lines, self, true)
	Globals.can_player_attack = false

func dialogue_over():
	pass

func interact_action():
	speech_audio_player.stream = dialogue_sfx
	intro_dialogue()

func _on_stamina_regen_timer_timeout() -> void:
	recovering_stamina = true

extends CharacterBody3D

@export var playerSpeed = 7
@export var playerGravity = 60
@export var sensitivity = 1000

@onready var camera = $CameraPivot/Camera3D
@onready var raycast = $CameraPivot/Camera3D/RayCast3D
@onready var attack_animation = $AttackAnimationPlayer
@onready var attack_idle_timer = $AttackIdleTimer
@onready var interact_marker = $PlayerInteractMarker
var targetVelocity = Vector3.ZERO

var raycast_end_pos: Vector3
var closest_interactable: Object

const anim_reset_time: float = 1.0
var attack_anim_name: String
var wep_atk_index: int = 1
var is_attacking: bool = false

@onready var weapon: Object = $Sword
var weapon_info: Dictionary = {
	"weapon_name": null,
	"attack_type": null,
	"attack_chain": null,
	"will_raycast": null,
}

var inventory: Array
var experience: float = 0
var level: int = 1
@export var tb_sprite_ally: CompressedTexture2D = preload("res://vfx/tb_preset.png")
@export var tb_sprite_enemy: CompressedTexture2D = preload("res://vfx/tb_preset.png")
@export var hurt_sfx: AudioStream = preload("res://sfx/hurt_preset.wav")
var max_hp = 150
var hp = max_hp
var max_mp = 100
var mp = max_mp
var attacks: Array[Array] = [
		#Attack name (string), Damage(int), MP cost(int), Local or instanced (string), Attack chain length (int), raycast (bool) -> NOT IMPLEMENTED  -> ||damage type(string), description(string)||
		[ "Slash", 5, 1, "local", 2, false],
		[ "Beam", 10, 5, "instance", 1, false],
		[ "Inferno", 50, 15, "instance", 1, true]
	]
var selected_ability: int = 2

signal attack_anim_started
signal ability_active
signal ability_menu_activate
signal ability_menu_deactivate
signal inventory_updated
signal battle_over

func _ready():
	inventory_updated.connect(on_inventory_updated)
	ability_menu_activate.connect(Globals.main.ability_menu.on_activate)
	ability_menu_deactivate.connect(Globals.main.ability_menu.on_deactivate)
	Globals.load_inventory()
	get_weapon_info()

func _physics_process(delta):
	movement_handler(delta)
	interact_input()
	drop_input()
	attack_input(delta)

func movement_handler(delta):
	if Globals.can_move == true:
		movement_inputs(delta)
		
		if not is_on_floor():
			velocity.y -= playerGravity * delta
		else:
			velocity.y = 0
		
		velocity.x = targetVelocity.x
		velocity.z = targetVelocity.z
		move_and_slide()

func movement_inputs(_delta):
	var direction = Vector3.ZERO
	
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
	targetVelocity = transform.basis * direction * playerSpeed

func do_raycast():
	raycast.force_raycast_update()
	if raycast.get_collision_point() != null:
		raycast_end_pos = raycast.get_collision_point()
	else: raycast_end_pos = raycast.target_position

func _input(event):
	if event is InputEventMouseMotion && Globals.can_rotate_camera == true:
		rotation.y -= event.relative.x / sensitivity
		
		$CameraPivot.rotation.x -= event.relative.y / sensitivity
		$CameraPivot.rotation.x = clamp($CameraPivot.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	if Input.is_action_just_pressed("mouse_lock"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func interactable_check():
	if Globals.target_interactables.size() == 0:
		pass
	elif Globals.target_interactables.size() > 0:
		for interactable in Globals.target_interactables:
			var self_pos = self.global_position
			var new_pos = interactable.global_position
			if closest_interactable == null:
				closest_interactable = Globals.target_interactables[0]
			elif closest_interactable != null:
				if self_pos.distance_to(new_pos) <= self_pos.distance_to(closest_interactable.global_position):
					closest_interactable = interactable
					print("closest interactable: ", closest_interactable.name)

func interact_input():
	if Globals.interactables.size() > 0:
		if Globals.interactables[0] == null:
			return
		var interaction_target = Globals.interactables[0]
		if self.global_position.distance_to(interaction_target.global_position) < interaction_target.interact_radius && DialogueManager.dialogue_active == false:
			interact_marker.visible = true
			interact_marker.global_position = interaction_target.global_position
			interact_marker.look_at(camera.global_position)
			if Input.is_action_just_pressed("interact") && Globals.can_interact == true:
				interaction_target.interact_action()
				interact_marker.visible = false
		elif DialogueManager.dialogue_active == true:
			if Input.is_action_just_pressed("interact"):
				DialogueManager.current_dialogue_target.interact_action()
		else: interact_marker.visible = false
	else: interact_marker.visible = false
		

func drop_input():
	if Input.is_action_just_pressed("drop_item") && inventory.size() > 0:
		var item_scene: PackedScene = load("res://scenes/items/item_scenes/" + inventory[0] + ".tscn")
		inventory.remove_at(0)
		var item_to_drop: RigidBody3D = item_scene.instantiate()
		get_parent().add_child(item_to_drop)
		item_to_drop.global_position = self.global_position
		emit_signal("inventory_updated")

func get_weapon_info():
	for i in weapon_info:
		weapon_info[i] = null
	weapon_info["weapon_name"] = weapon.weapon_name
	weapon_info["attack_type"] = weapon.attack_type
	weapon_info["attack_chain"] = weapon.attack_chain
	weapon_info["will_raycast"] = weapon.will_raycast
	
var reset_timer: float

func attack_input(delta: float):
	reset_timer += delta
	if Input.is_action_just_pressed("attack") && Globals.can_player_attack == true:
		do_attack("weapon")
	if Input.is_action_just_pressed("ability") && Globals.can_player_attack == true:
		do_attack("ability")
	if Input.is_action_just_pressed("ability_menu") && Globals.can_player_attack == true:
		emit_signal("ability_menu_activate")
	if Input.is_action_just_released("ability_menu"):
		emit_signal("ability_menu_deactivate")
	
func do_attack(type: String):
	Globals.can_player_attack = false
	var attack_name: String
	var attack_type: String
	var attack_chain: int
	var raycasting: bool = false
	
	if type == "weapon":
		attack_name = weapon_info["weapon_name"]
		attack_type = weapon_info["attack_type"]
		attack_chain = weapon_info["attack_chain"]
		raycasting = weapon_info["will_raycast"]
		attack_anim_name = attack_name + "_attack" + str(wep_atk_index) + "_animation"
	elif type == "ability":
		var ability = attacks[selected_ability]
		attack_name = ability[0].to_lower()
		attack_type = ability[3]
		attack_chain = ability[4]
		raycasting = ability[5]
		attack_anim_name = attack_name + "_attack_animation"
	
	if attack_type == "local":
		reset_timer = 0
		attack_animation.play(attack_anim_name)
		wep_atk_index += 1
		if wep_atk_index > attack_chain:
			wep_atk_index = 1
	if attack_type == "instance":
		var attack_scene = load("res://scenes/player/attacks/" + attack_name + ".tscn")
		var attack = attack_scene.instantiate()
		if raycasting == false:
			self.add_child(attack)
		elif raycasting == true:
			get_tree().get_root().add_child(attack)
			do_raycast()
			attack.global_position = raycast_end_pos
			
		await ability_active
		attack_animation.play(attack_anim_name)
		
func on_damaged(amount: int):
	hp -= amount

func die():
	pass

func _on_attack_animation_player_animation_finished(anim_name: StringName):
	if anim_name == attack_anim_name:
		Globals.can_player_attack = true
		weapon.empty_targets()
		is_attack_idle()

func is_attack_idle():
	var attack_check: int = wep_atk_index
	attack_idle_timer.start(anim_reset_time)
	await attack_idle_timer.timeout
	if Globals.can_player_attack == true && attack_check == wep_atk_index:
		wep_atk_index = 1
		if attack_animation.get_animation_list().has(str(attack_anim_name, "_to_idle")):
			attack_animation.play(str(attack_anim_name, "_to_idle"))
	else: print("new attack happened")

func on_inventory_updated():
	print(inventory)
	#Globals.save_inventory_data(inventory)


func _on_attack_animation_player_animation_started(anim_name: StringName) -> void:
	emit_signal("attack_anim_started")

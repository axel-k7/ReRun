extends CharacterBody3D

@export var playerSpeed = 7
@export var playerGravity = 60
@export var sensitivity = 1000

@onready var camera = $CameraPivot/Camera3D
@onready var raycast = $CameraPivot/Camera3D/RayCast3D
@onready var animation = $AnimationPlayer
@onready var attack_cooldown = $attack_cooldown
var targetVelocity = Vector3.ZERO

var raycast_end_pos: Vector3
var closest_interactable: Object

var curr_anim: String
var attack_anim_name: String

@onready var weapon: Object = $Sword
var inventory: Array
var exp: float = 0
var level: int = 1
@export var tb_sprite_ally: CompressedTexture2D = preload("res://vfx/tb_preset.png")
@export var tb_sprite_enemy: CompressedTexture2D = preload("res://vfx/tb_preset.png")
@export var hurt_sfx: AudioStream = preload("res://sfx/hurt_preset.wav")
var max_hp = 150
var hp = max_hp
var max_mp = 100
var mp = max_mp
var attacks: Array[Array] = [
		#Attack name (string), Damage(int), MP cost(int), 3D attack scene (if needed), -> NOT IMPLEMENTED  -> ||damage type(string), description(string)||
		[ "Slash", 5, 1 ],
		[ "Fireball", 10, 3],
		[ "Beam", 10, 5, preload("res://scenes/player/attacks/beam.tscn")],
		[ "Inferno", 50, 15, preload("res://scenes/player/attacks/inferno.tscn")]
	]

signal inventory_updated

func _ready():
	Globals.load_inventory()
	pass#BattleManagerTb.allies.append(self)

func _physics_process(delta):
	movement_handler(delta)
	interact_input()
	drop_input()
	attack_input()

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

func do_raycast(distance: int):
	raycast.force_raycast_update()
	if raycast.get_collision_point() != null:
		raycast_end_pos = raycast.get_collision_point()
		print(raycast_end_pos)
	else: raycast_end_pos = raycast.target_position

func _input(event):
	if event is InputEventMouseMotion && Globals.can_rotate_camera == true:
		rotation.y -= event.relative.x / sensitivity
		
		$CameraPivot.rotation.x -= event.relative.y / sensitivity
		$CameraPivot.rotation.x = clamp($CameraPivot.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	if Input.is_action_just_pressed("mouseLock"):
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
	#interactable_check() BAD CODE
	if Input.is_action_just_pressed("interact") && Globals.target_interactables.size() > 0 && Globals.can_interact == true:
		#closest_interactable.interact_action()
		Globals.target_interactables[0].interact_action()

func drop_input():
	if Input.is_action_just_pressed("drop_item") && inventory.size() > 0:
		var item_scene: PackedScene = load("res://scenes/items/item_scenes/" + inventory[0] + ".tscn")
		inventory.remove_at(0)
		var item_to_drop = item_scene.instantiate()
		get_parent().add_child(item_to_drop)
		item_to_drop.global_position = self.global_position

func attack_input():
	if Input.is_action_just_pressed("attack") && Globals.can_player_attack == true:
		attack("Inferno", "instance", true)

func attack(selected_attack: String, attack_type: String, raycast: bool):
	for attack_info in attacks:
		if attack_info[0] == selected_attack:
			if attack_type == "instance":
				var attack = attack_info[3].instantiate()
				if raycast == false:
					self.add_child(attack)
				
				elif raycast == true:
					get_tree().get_root().add_child(attack)
					do_raycast(500)
					attack.global_position = raycast_end_pos
				attack.get_stats(attack_info[1])
				self.mp -= attack_info[2]
				
			elif attack_type == "local":
				attack_anim_name = attack_info[0] + "_animation"
				animation.play(attack_anim_name)
				self.mp -= attack_info[2]

func on_damaged(amount: int):
	print("ow")

func die():
	pass


func _on_animation_player_animation_finished(anim_name: StringName):
	if anim_name == attack_anim_name:
		weapon.empty_targets()

func _on_inventory_updated():
	Globals.save_inventory_file(inventory)

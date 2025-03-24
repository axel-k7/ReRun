extends CharacterBody3D

@export var playerSpeed = 7
@export var playerGravity = 60
@export var sensitivity = 1000

@onready var camera = $CameraPivot/Camera3D
@onready var animation = $AnimationPlayer

var targetVelocity = Vector3.ZERO
var inventory: Array

var exp: float = 0
var level: int = 1

@export var tb_sprite: CompressedTexture2D = preload("res://vfx/tb_preset.png")
@export var hurt_sfx: AudioStream = preload("res://sfx/hurt_preset.wav")
var max_hp = 150
var hp = max_hp
var max_mp = 100
var mp = max_mp
var attacks: Array[Array] = [
		#Attack name (string), Damage(int), MP cost(int), 3D attack scene (if needed), -> NOT IMPLEMENTED  -> ||damage type(string), description(string)||
		[ "Slash", 5, 1 ],
		[ "Fireball", 10, 3],
		[ "Beam", 10, 5, preload("res://scenes/player/attacks/beam.tscn")]
	]

func _ready():
	BattleManagerTb.allies.append(self)

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

func interact_input():
	if Input.is_action_just_pressed("interact") && Globals.targetInteractables.size() > 0 && Globals.can_interact == true:
		Globals.targetInteractables[0].interact_action()

func drop_input():
	if Input.is_action_just_pressed("drop_item") && inventory.size() > 0:
		var item_scene: PackedScene = load("res://scenes/items/item_scenes/" + inventory[0] + ".tscn")
		inventory.remove_at(0)
		var item_to_drop = item_scene.instantiate()
		get_parent().add_child(item_to_drop)
		item_to_drop.global_position = self.global_position

func attack_input():
	if Input.is_action_just_pressed("attack") && Globals.can_player_attack == true:
		attack("Beam")
	
func attack(selected_attack: String):
	for attack_info in attacks:
		if attack_info[0] == selected_attack:
			var attack = attack_info[3].instantiate()
			self.add_child(attack)
			attack.get_stats(attack_info[1])
			self.mp -= attack_info[2]

func die():
	pass

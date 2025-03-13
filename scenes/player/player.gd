extends CharacterBody3D

@export var playerSpeed = 7
@export var playerGravity = 60
@export var sensitivity = 1000

@onready var cam = $CameraPivot/Camera3D

var targetVelocity = Vector3.ZERO

var inventory: Array

func _ready():
	cam.current = is_multiplayer_authority() 

func _physics_process(delta):
	movement_handler(delta)
	interact_input()
	drop_input()


func _input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / sensitivity
		
		$CameraPivot.rotation.x -= event.relative.y / sensitivity
		$CameraPivot.rotation.x = clamp($CameraPivot.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	if Input.is_action_just_pressed("mouseLock"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


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
	"move_forward": Vector3.FORWARD,
	"move_back": Vector3.BACK,
	"move_left": Vector3.LEFT,
	"move_right": Vector3.RIGHT,
	}
	for action in inputMap.keys():
		if Input.is_action_pressed(action):
			direction += inputMap[action]
		
	direction = direction.normalized()
	targetVelocity = transform.basis * direction * playerSpeed

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

extends "res://scripts/character_scripts/character.gd"

@export var sensitivity = 1000

@onready var camera = $CameraPivot/Camera3D
@onready var interact_marker = $PlayerInteractMarker

var closest_interactable: Object

signal attack_anim_started
signal ability_menu_activate
signal ability_menu_deactivate
signal inventory_updated

func _ready():
	get_variables()
	inventory_updated.connect(on_inventory_updated)
	ability_menu_activate.connect(Globals.main.ability_menu.on_activate)
	ability_menu_deactivate.connect(Globals.main.ability_menu.on_deactivate)
	Globals.load_inventory()

func _physics_process(delta):
	movement_handler(delta)

func get_variables():
	raycast = $CameraPivot/Camera3D/RayCast3D
	attack_animation = $AttackAnimationPlayer
	attack_idle_timer = $AttackIdleTimer
	weapon = $Sword
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
	target_velocity = transform.basis * direction * move_speed


func _input(event):
	mouse_movement(event)
	toggle_mouse()
	interact_input()
	drop_input()
	attack_input()

func mouse_movement(event):
	if event is InputEventMouseMotion && Globals.can_rotate_camera:
		rotation.y -= event.relative.x / sensitivity
		$CameraPivot.rotation.x -= event.relative.y / sensitivity
		$CameraPivot.rotation.x = clamp($CameraPivot.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func toggle_mouse():
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
		if self.global_position.distance_to(interaction_target.global_position) < interaction_target.interact_radius && !DialogueManager.dialogue_active:
			interact_marker.visible = true
			interact_marker.global_position = interaction_target.global_position
			interact_marker.look_at(camera.global_position)
			if Input.is_action_just_pressed("interact") && Globals.can_interact:
				interaction_target.interact_action()
				interact_marker.visible = false
		elif DialogueManager.dialogue_active:
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


func attack_input():
	if Globals.can_player_attack && attack_ready:
		if Input.is_action_just_pressed("attack"):
			do_attack("weapon")
		if Input.is_action_just_pressed("ability"):
			do_attack("ability")
		if Input.is_action_just_pressed("ability_menu"):
			emit_signal("ability_menu_activate")
		if Input.is_action_just_released("ability_menu"):
			emit_signal("ability_menu_deactivate")

func on_damaged(amount: int):
	hp -= amount

func die():
	pass

func on_inventory_updated():
	print(inventory)
	#Globals.save_inventory_data(inventory)

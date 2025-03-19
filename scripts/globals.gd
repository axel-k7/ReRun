extends Node

@onready var targetInteractables: Array[Object] = []
@onready var player: CharacterBody3D
@onready var can_move: bool = true
@onready var can_interact: bool = true
@onready var can_rotate_camera: bool = true

func add_interact(body):
	var interact_scene =  preload("res://scenes/items/interact_area.tscn")
	var interact_area = interact_scene.instantiate()
	(body).add_child(interact_area)

func player_controls(option: bool):
	can_move = option
	can_interact = option
	can_rotate_camera = option

func damage(target: Object, amount: int):
	target.on_damaged(amount)
	damage_flash(target)

func damage_flash(target):
	target.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.2).timeout
	target.modulate = Color(1, 1, 1)

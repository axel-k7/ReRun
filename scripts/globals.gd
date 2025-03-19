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

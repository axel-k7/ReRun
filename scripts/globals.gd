extends Node

@onready var targetInteractable: Object
@onready var player: CharacterBody3D
@onready var can_move: bool = true

func add_interact(body):
	var interact_scene =  preload("res://scenes/items/interact_area.tscn")
	var interact_area = interact_scene.instantiate()
	(body).add_child(interact_area)

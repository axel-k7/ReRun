extends Node

@onready var interactable = get_parent()
@onready var interact_area = $Area3D/CollisionShape3D
@onready var test_mesh = $Area3D/MeshInstance3D

func _ready() -> void:
	interact_area.shape.radius = interactable.interact_distance
	test_mesh.mesh.radius = interactable.interact_distance
	test_mesh.mesh.height = interactable.interact_distance*2

func _on_area_3d_body_entered(body):
	if body.name == "player":
		Globals.check_closest_interactable()

func _on_area_3d_body_exited(body):
	if body.name == "player":
		Globals.check_closest_interactable()

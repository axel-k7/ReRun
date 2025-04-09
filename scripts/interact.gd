extends Node

@onready var interactable = get_parent()
@onready var interact_area = $CollisionShape3D
@onready var test_mesh = $MeshInstance3D

func _ready() -> void:
	interact_area.shape.radius = interactable.interact_distance/2
	test_mesh.mesh.radius = interactable.interact_distance/2
	test_mesh.mesh.height = interactable.interact_distance

func _on_body_entered(body: Node3D) -> void:
	if body.name == "player":
		Globals.check_closest_interactable()


func _on_body_exited(body: Node3D) -> void:
	if body.name == "player":
		Globals.check_closest_interactable()

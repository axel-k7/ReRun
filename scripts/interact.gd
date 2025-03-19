extends Node

@onready var interactable = get_parent()

func _on_area_3d_body_entered(body):
	if body.name == "player":
		Globals.targetInteractables.append(interactable)
		print("interactables in range: ", Globals.targetInteractables)

func _on_area_3d_body_exited(body):
	if body.name == "player":
		Globals.targetInteractables.erase(interactable)
		print("interactables in range: ", Globals.targetInteractables)

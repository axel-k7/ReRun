extends Node

@onready var interactable = get_parent()

func _on_area_3d_body_entered(body):
	if body.name == "player":
		Globals.target_interactables.append(interactable)
		print("interactables in range: ", Globals.target_interactables)

func _on_area_3d_body_exited(body):
	if body.name == "player":
		Globals.target_interactables.erase(interactable)
		print("interactables in range: ", Globals.target_interactables)

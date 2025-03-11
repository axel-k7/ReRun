extends Node

func _on_area_3d_body_entered(body):
	if body.name == "player":
		Globals.targetInteractable = get_parent()
		print("target item = ", Globals.targetInteractable)

func _on_area_3d_body_exited(body):
	if body.name == "player":
		Globals.targetInteractable = null
		print("target item = ", Globals.targetInteractable)

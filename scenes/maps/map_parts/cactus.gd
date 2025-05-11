extends StaticBody3D

func _on_area_3d_body_entered(body):
	if body.name == "player":
		Globals.damage(body, 5)

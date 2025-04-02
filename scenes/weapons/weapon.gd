extends Area3D

var targets_hit: Array = []
@export var damage: int = 5
@export var wielder: String = "ally"

func _on_body_entered(body: Node3D):
	if body.is_in_group("NPC") && wielder == "ally" && targets_hit.has(body) == false:
		print("hit: ", body.name)
		Globals.damage(body, damage)
		targets_hit.append(body)
	if body.name == "player" && wielder == "enemy" && targets_hit.has(body) == false:
		print("hit: ", body.name)
		Globals.damage(body, damage)
		targets_hit.append(body)

func empty_targets():
	targets_hit.clear()

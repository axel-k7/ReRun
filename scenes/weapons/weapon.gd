extends Area3D

var targets_hit: Array = []
@export var damage: int = 5

func _on_body_entered(body: Node3D):
	if body.is_in_group("NPC") && targets_hit.has(body) != true:
		print("hit: ", body.name)
		Globals.damage(body, damage)
		targets_hit.append(body)
	elif body.is_in_group("NPC"): print(body.name, " was already hit by ", self.name)

func empty_targets():
	targets_hit.clear()

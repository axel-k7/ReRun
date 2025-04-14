extends Area3D

var targets_hit: Array = []

@export var weapon_name: String = "sword"
@export var attack_type: String = "local"
@export var attack_chain: int = 1
@export var will_raycast: bool = false

@export var damage: int = 5
@export var wielder: String = "ally"

func _on_body_entered(body: Node3D):
	if body.is_in_group("NPC") && wielder == "ally" && !targets_hit.has(body):
		print("hit: ", body.name)
		Globals.damage(body, damage)
		targets_hit.append(body)
	if body.name == "player" && wielder == "enemy" && !targets_hit.has(body):
		print("hit: ", body.name)
		Globals.damage(body, damage)
		targets_hit.append(body)

func empty_targets():
	targets_hit.clear()

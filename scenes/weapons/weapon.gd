extends Area3D

var targets_hit: Array = []
var ability_multiplier: float = 1.0

@onready var attack_sfx: AudioStreamPlayer3D = $AudioStreamPlayer3D
@export var weapon_name: String = "sword"
@export var attack_type: String = "local"
@export var attack_chain: int = 1
@export var will_raycast: bool = false
@export var emit_sfx: bool = false
@export var damage: int = 5
@export var wielder: String = "ally"

func _process(delta):
	if !emit_sfx:
		pass
	elif emit_sfx:
		emit_sfx = false
		attack_sfx.play()

func _on_body_entered(body: Node3D):
	if body.is_in_group("NPC") && wielder == "ally" && !targets_hit.has(body):
		print("hit: ", body.name)
		Globals.damage(body, damage*ability_multiplier)
		targets_hit.append(body)
	if body.name == "player" && wielder == "enemy" && !targets_hit.has(body):
		print("hit: ", body.name)
		Globals.damage(body, damage*ability_multiplier)
		targets_hit.append(body)

func empty_targets():
	targets_hit.clear()

extends Area3D

@onready var timer = $Timer
var up_time: float = 1.5
var targets_hit: Array = []
var damage: int

func _ready():
	timer.wait_time = up_time

func _on_body_entered(body: Node3D):
	if body.is_in_group("NPC") && targets_hit.has(body) != true:
		print("hit: ", body.name)
		Globals.damage(body, damage)
		targets_hit.append(body)
	elif body.is_in_group("NPC"): print(body.name, " was already hit by ", self.name)

func _on_timer_timeout():
	self.queue_free()

func get_stats(dmg: int):
	damage = dmg

extends Area3D

@onready var timer = $Timer
@onready var mesh: Mesh = $MeshInstance3D.mesh
var up_time: float = 1.5
var targets_hit: Array = []
var damage: int

signal activate

func _ready() -> void:
	self.monitoring = false
	mesh.material.albedo_color = Color(0.3, 0.8, 0.9, 0.6)

func _process(delta: float) -> void:
	if Input.is_action_just_released("attack"):
		emit_signal("activate")
	
func _on_activate() -> void:
	mesh.material.albedo_color = Color(0.8, 0.25, 0, 0.98)
	self.monitoring = true
	timer.start()
	
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

extends Area3D

@onready var timer = $Timer
@onready var mesh: Mesh = $MeshInstance3D.mesh
var activated: bool = false
var host: Object
var up_time: float = 1.5
var targets_hit: Array = []
var damage: int

signal activate

func _ready() -> void:
	self.monitoring = false
	mesh.material.albedo_color = Color(0.3, 0.8, 0.9, 0.6)
	await get_tree().create_timer(0.8).timeout
	if host.is_in_group("NPC"):
		emit_signal("activate")
		host.emit_signal("ability_activate")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("ability") && !host.is_in_group("NPC") && !activated:
		activated = true
		emit_signal("activate")
		host.emit_signal("ability_activate")

func _on_activate() -> void:
	mesh.material.albedo_color = Color(0.8, 0.25, 0, 0.98)
	self.monitoring = true
	timer.start()
	
func _on_body_entered(body: Node3D):
	if host.is_in_group("enemy") && body.is_in_group("ally") && !targets_hit.has(body):
		Globals.damage(body, damage)
		targets_hit.append(body)
	elif host.is_in_group("ally") && body.is_in_group("enemy") && !targets_hit.has(body):
		Globals.damage(body, damage)
		targets_hit.append(body)

func _on_timer_timeout():
	host.attack_ready = true
	self.queue_free()

func get_stats(dmg: int):
	damage = dmg

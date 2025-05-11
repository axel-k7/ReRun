extends Area3D

var targets_hit: Array = []
var ability_multiplier: float = 1.0

@onready var weapon_sfx: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var parry_particles: GPUParticles3D = $GPUParticles3D
@export var weapon_name: String = "sword"
@export var attack_type: String = "local"
@export var attack_chain: int = 1
@export var will_raycast: bool = false
@export var emit_sfx: bool = false
@export var damage: int = 5
@export var wielder: String = "ally"
var attack_sfx: AudioStream
#var parry_sfx: AudioStream = preload("res://sfx/parry.ogg")
var block_sfx: AudioStream = preload("res://sfx/block.ogg")

func _ready():
	attack_sfx = load("res://sfx/" + weapon_name + ".ogg")

func _process(_delta):
	if !emit_sfx:
		pass
	elif emit_sfx:
		emit_sfx = false
		weapon_sfx.stream = attack_sfx
		weapon_sfx.play()

func _on_body_entered(body: Node3D):
	if !targets_hit.has(body):
		if body.is_in_group("NPC") && wielder == "ally" || body.name == "player" && wielder == "enemy":
			print("hit: ", body.Cname)
			Globals.damage(body, damage*ability_multiplier)
			targets_hit.append(body)
			if body.blocking:
				if body.parrying:
					get_parent().stun(2.5)
					body.emit_signal("block", true)
				else: 
					get_parent().stun(0.8)
					body.emit_signal("block", false)

func block(parry: bool):
	if !parry:
		weapon_sfx.stream = block_sfx
		weapon_sfx.play()
	elif parry:
		#weapon_sfx.stream = parry_sfx
		weapon_sfx.play()
		parry_particles.emitting = true

func empty_targets():
	targets_hit.clear()

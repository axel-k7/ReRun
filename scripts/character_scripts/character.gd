extends CharacterBody3D
class_name Character

@export var Cname: String = "name"
@export var image: CompressedTexture2D = preload("res://vfx/character_sprites/missing.png")
@export var custom_gravity = 60
@export var move_speed: float = 7.0
@export var tb_sprite_ally: CompressedTexture2D = preload("res://vfx/tb_preset.png")
@export var tb_sprite_enemy: CompressedTexture2D = preload("res://vfx/tb_preset.png")
@export var hurt_sfx: AudioStream = preload("res://sfx/hurt_preset.wav")
@export var death_vfx_scene: PackedScene = preload("res://scenes/effects/poof.tscn")
@export var dialogue_sfx: AudioStream = preload("res://sfx/hah.wav")
@export var lines: Array[String] = [
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod temp",
	"Line 2",
	"Line 3"
]
@export var dialogue_amount: int = 1
var dialogue_index: int = 0
var dialogue_finished: bool = false

var speech_audio_player: AudioStreamPlayer3D
var attack_audio_player: AudioStreamPlayer3D
var body_animation: AnimationPlayer
var attack_animation: AnimationPlayer
var attack_idle_timer: Timer
var weapon: Object
var stun_timer: Timer
var target_velocity = Vector3.ZERO
var raycast: RayCast3D
var raycast_end_pos: Vector3

const anim_reset_time: float = 1.0
var attack_anim_name: String

var wep_atk_index: int = 1
var attack_ready: bool = true
var weapon_info: Dictionary = {
	"weapon_name": null,
	"attack_type": null,
	"attack_chain": null,
	"will_raycast": null,
}

var inventory: Array
var experience: float = 0
var level: int = 1

@export var max_hp = 150
@export var max_mp = 100
@export var defense = 1.0
@onready var hp = max_hp
@onready var mp = max_mp
var stamina: float = 100.0
var blocking: bool = false
var guard_multiplier: float = 1.0
var attacks: Array[Array] = [
		#Attack name (string), Damage(int), MP cost(int), Local or instanced (string), Attack chain length (int), ability multiplier for local (float), raycast (bool) -> NOT IMPLEMENTED  -> ||damage type(string), description(string)||
		[ "Slash", 5, 1, "local", 2, 2.5, false],
		[ "Beam", 10, 3, "instance", 1, null, false],
		[ "Inferno", 50, 15, "instance", null, 1, true],
	]
var selected_ability: int = 0

signal ability_activate
signal battle_over

func get_weapon_info():
	for i in weapon_info:
		weapon_info[i] = null
		weapon_info["weapon_name"] = weapon.weapon_name
		weapon_info["attack_type"] = weapon.attack_type
		weapon_info["attack_chain"] = weapon.attack_chain
		weapon_info["will_raycast"] = weapon.will_raycast
	
func do_attack(type: String):
	attack_ready = false
	var attack_name: String
	var attack_type: String
	var attack_chain: int
	var ability_multiplier: float = 1.0
	var raycasting: bool = false
	
	if type == "weapon":
		attack_name = weapon_info["weapon_name"]
		attack_type = weapon_info["attack_type"]
		attack_chain = weapon_info["attack_chain"]
		raycasting = weapon_info["will_raycast"]
	elif type == "ability":
		var ability = attacks[selected_ability]
		attack_name = ability[0].to_lower()
		attack_type = ability[3]
		attack_chain = ability[4]
		ability_multiplier = ability[5]
		raycasting = ability[6]
	
	if wep_atk_index > attack_chain:
			wep_atk_index = 1
	attack_anim_name = attack_name + "_attack" + str(wep_atk_index) + "_animation"
	
	if attack_type == "local":
		attack_animation.play(attack_anim_name)
		weapon.ability_multiplier = ability_multiplier
		wep_atk_index += 1
	
	elif attack_type == "instance" || attack_type == "projectile":
		var attack_scene = load("res://scenes/attacks/" + attack_name + ".tscn")
		if attack_scene == null:
			return
		var attack = attack_scene.instantiate()
		if !raycasting:
			self.add_child(attack)
		elif raycasting && attack_type == "instance":
			get_tree().get_root().add_child(attack)
			do_raycast()
			attack.global_position = raycast_end_pos
		attack.host = self
			
		await ability_activate
		if attack_animation.has_animation(attack_anim_name):
			attack_animation.play(attack_anim_name)

func _on_attack_animation_player_animation_finished(anim_name: StringName):
	if anim_name == attack_anim_name:
		attack_ready = true
		weapon.empty_targets()
		weapon.ability_multiplier = 1.0
		is_attack_idle()

func is_attack_idle():
	var attack_check: int = wep_atk_index
	attack_idle_timer.start(anim_reset_time)
	await attack_idle_timer.timeout
	if attack_ready && attack_check == wep_atk_index:
		wep_atk_index = 1
		attack_animation.play("RESET")

func do_raycast():
	raycast.force_raycast_update()
	if raycast.get_collision_point() != null:
		raycast_end_pos = raycast.get_collision_point()
	else: raycast_end_pos = raycast.target_position

func interact_action():
	print("interaction not found")
	return

func dialogue_over():
	dialogue_index += 1
	dialogue_over_function()
	if BattleManagerTb.battle_active:
		BattleManagerTb.battle_paused = false
		Globals.main.ui_container.visible = false
	if dialogue_index >= dialogue_amount:
		dialogue_finished = true

func dialogue_over_function():
	pass #defined in subscripts

func stun():
	pass #defined in player.gd and NPC.gd respectively

func on_damaged(amount: int):
	if !blocking:
		hp -= (amount * guard_multiplier) * defense
		guard_multiplier = 1.0
	elif blocking:
		stamina -= amount*5
		if stamina <= 0:
			stun()
			hp -= amount/2
	if hp <= 0:
		die()

func die():
	death_effect()

func death_effect():
	var effect = death_vfx_scene.instantiate()
	self.add_child(effect)
	effect.emitting = true

extends Node

@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D
@export var Cname: String = "name"
@export var image: CompressedTexture2D = preload("res://vfx/smiley.png")
@export var dialogue_sfx: AudioStream = preload("res://sfx/hah.wav")
@export var hurt_sfx: AudioStream = preload("res://sfx/hurt_preset.wav")
@export var lines: Array[String] = [
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod temp",
	"Line 2",
	"Line 3"
]
@export var tb_sprite: CompressedTexture2D = preload("res://vfx/tb_preset.png")
@export var exp_given: float = 50

var max_hp = 30
var hp = max_hp
var max_mp = 100
var mp = max_mp
var attacks: Array[Array] = [
		#Attack name (string), Damage(int), MP cost(int), -> NOT IMPLEMENTED  -> ||damage type(string), description(string)||
		[ "Lunge", 7, 2 ],
		[ "Bite", 3, 0 ]
	]

func _ready():
	Globals.add_interact(self)
	audio.stream = dialogue_sfx
	self.add_to_group("NPC")

func interact_action():
	DialogueManager.start_dialogue(lines, self, false)

func dialogue_over():
	BattleManagerTb.enemies.append(self)
	BattleManagerTb.start_battle(BattleManagerTb.allies, BattleManagerTb.enemies)

func on_damaged(amount: int):
	hp -= amount
	print(self.name, " took ", amount, " damage")
	print(self.name, " current hp: ", hp) 
	if hp <= 0:
		die()
	
func die():
	Globals.player.exp += exp_given
	#ragdoll()
	await get_tree().create_timer(2).timeout
	self.queue_free()

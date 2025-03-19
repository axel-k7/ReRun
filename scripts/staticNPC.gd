extends Node

@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D
@export var Cname: String = "name"
@export var image: CompressedTexture2D = preload("res://vfx/smiley.png")
@export var lines: Array[String] = [
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod temp",
	"Line 2",
	"Line 3"
]
@export var sfx: AudioStream = preload("res://sfx/splat.wav")

func _ready():
	Globals.add_interact(self)
	audio.stream = sfx

func interact_action():
	DialogueManager.start_dialogue(lines, self)

func dialogue_over():
	BattleManagerTb.start_battle(BattleManagerTb.allies, BattleManagerTb.allies)

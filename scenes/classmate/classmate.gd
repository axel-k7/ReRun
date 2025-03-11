extends Node

@export var type: String = "interactable"

func _ready():
	Globals.add_interact(self)

func interact_action():
	print("poop")

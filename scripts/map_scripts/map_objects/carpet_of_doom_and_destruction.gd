extends Node

@export var interact_radius: float = 3.0

func _ready():
	Globals.add_interact(self, false)

func interact_action():
	pass

extends Node

@export var type: String = "interactable"
@export var item: String = "item"

func _ready():
	Globals.add_interact(self)

func interact_action():
	Globals.player.inventory.append(str(Globals.targetInteractable.item))
	print(Globals.player.inventory)
	Globals.targetInteractable.queue_free()

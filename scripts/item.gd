extends Node

@export var type: String = "interactable"
@export var item: String = "item"

func _ready():
	Globals.add_interact(self)

func interact_action():
	Globals.player.inventory.append(self.item)
	Globals.player.emit_signal("inventory_updated")
	Globals.target_interactables[0].queue_free()

extends Node

@export var type: String = "interactable"
@export var item: String = "item"
@export var interact_distance: int = 500

func _ready():
	Globals.add_interact(self)

func interact_action():
	Globals.player.inventory.append(self.item)
	Globals.player.emit_signal("inventory_updated")
	self.queue_free()

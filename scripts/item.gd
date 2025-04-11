extends RigidBody3D

@export var type: String = "interactable"
@export var item: String = "item"
@export var interact_radius: float = 1.0

func _ready():
	Globals.add_interact(self)

func interact_action():
	Globals.player.inventory.append(self.item)
	Globals.player.emit_signal("inventory_updated")
	self.queue_free()

extends RigidBody3D
class_name Item

@export var type: String = "interactable"
@export var item: String = "item"
@export var interact_radius: float = 3.0
@export var has_interact: bool = true
var mesh

func _ready():
	if has_interact:
		Globals.add_interact(self)

func interact_action():
	Globals.player.inventory.append(self.item)
	Globals.player.emit_signal("inventory_updated")
	self.queue_free()

func use_item(): #Defined in item sub-scripts
	pass

func despawn():
	if mesh != TYPE_ARRAY:
		var tween = create_tween()
		tween.tween_property(mesh, "modulate:a", 1, 0.5)
		tween.tween_property(mesh, "modulate:a", 0, 1).set_delay(1)
		await tween.finished
		tween.stop()
		tween.tween_callback(queue_free)
	else:
		pass

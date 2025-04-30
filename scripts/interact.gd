extends Area3D

@onready var interactable: Object
@onready var interact_area: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	interactable = get_parent()
	if interactable == null: return
	var new_shape = SphereShape3D.new()
	new_shape.radius = interactable.interact_radius
	interact_area.shape = new_shape

func _on_body_entered(body: Node3D) -> void:
	if body.name == "player":
		Globals.check_closest_interactable()


func _on_body_exited(body: Node3D) -> void:
	if body.name == "player":
		Globals.check_closest_interactable()

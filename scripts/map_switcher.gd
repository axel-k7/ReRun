extends StaticBody3D

@export var target_map_name: String = "test_map_1"

func _ready() -> void:
	Globals.add_interact(self)

func interact_action():
	Globals.config_data["current_map"] = target_map_name
	Globals.main.load_map()

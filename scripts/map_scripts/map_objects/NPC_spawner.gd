extends Marker3D

@export var NPC: PackedScene
@export var NPC_variables: Dictionary = {
	"has_interaction": false,
	"force_interaction": false,
	"interact_radius": 0.0,
	"side": "enemy",
	"can_drop_item": false,
	"item_to_drop": preload("res://scenes/items/item_scenes/potion.tscn"),
	"stationary": false,
	"always_aggro": false,
}

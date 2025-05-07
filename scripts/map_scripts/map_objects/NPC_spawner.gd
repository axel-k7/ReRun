extends Marker3D

@export var NPC: PackedScene
@export var NPC_variables: Dictionary = {
	"has_interaction": false,
	"force_interaction": false,
	"interact_radius": 0.0,
	"side": "enemy",
	"stationary": false,
}

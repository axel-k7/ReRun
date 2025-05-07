extends Node
class_name Map

@export var map_name: String = "Map"
@export var boss_door: Node
@onready var npc_spawners: Array[Node] = $NPC_spawners.get_children()
@onready var player_spawn_pos= $Player_spawn_pos.global_position

func _ready() -> void:
	Globals.emit_signal("map_loaded")

func spawn_npcs():
	for spawned_enemy in get_tree().get_nodes_in_group("NPC"):
		spawned_enemy.queue_free()
	for spawner in npc_spawners:
		var npc = spawner.NPC.instantiate()
		for attribute in spawner.NPC_variables.keys():
			npc.set(attribute, spawner.NPC_variables[attribute])
		Globals.main.npc_container.add_child(npc)
		npc.global_position = spawner.global_position
		npc.rotation = spawner.rotation

func toggle_boss_door(active):
	if boss_door == null:
		return
	boss_door.visible = active
	boss_door.get_child(0).set_deferred("disabled", !active)

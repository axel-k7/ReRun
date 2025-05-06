extends Node
class_name Map

@onready var npc_spawners: Array[Node] = $NPC_spawners.get_children()
@onready var player_spawn_pos= $Player_spawn_pos.global_position

func _ready() -> void:
	Globals.system_message(self.name)
	Globals.emit_signal("map_loaded")

func spawn_npcs():
	for spawned_enemy in get_tree().get_nodes_in_group("NPC"):
		spawned_enemy.queue_free()
	for spawner in npc_spawners:
		var npc = spawner.NPC.instantiate()
		Globals.main.npc_container.add_child(npc)
		npc.global_position = spawner.global_position
		npc.rotation = spawner.rotation

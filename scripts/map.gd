extends Node

@onready var npc_spawners: Array[Node] = $NPC_spawners.get_children()

func _ready() -> void:
	Globals.system_message(self.name)
	Globals.emit_signal("map_loaded")

func spawn_npcs():
	for spawned_enemy in get_tree().get_nodes_in_group("NPC"):
		spawned_enemy.queue_free()
	for spawner in npc_spawners:
		var npc = spawner.NPC.instantiate()
		self.add_child(npc)

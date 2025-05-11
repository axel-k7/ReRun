extends Map

var map_completed: bool = false
signal map_complete

func _ready():
	Globals.emit_signal("map_loaded")
	reset_map.connect(on_reset_map)
	map_complete.connect(switch_map)
	Globals.system_message("Your hunt has begun, eliminate all enemies.")

func on_reset_map():
	Globals.player.global_position = player_spawn_pos
	var lines: Array[String] = ["Rise once more."]
	Globals.main.narrate(lines, "none", 1)
	await Globals.main.narrator_finished
	Globals.player.hp = Globals.player.max_hp
	Globals.player.mp = Globals.player.max_mp
	Globals.paused = false

func _physics_process(delta):
	if Globals.main.npc_container.get_children().size() == 0 && !map_completed:
		map_completed = true
		emit_signal("map_complete")

func switch_map():
	Globals.system_message("Hunt finished, but our work is never done.")
	await get_tree().create_timer(4).timeout
	get_random_map()

func get_random_map():
	var random_map = Globals.repeatable_maps[randi_range(0, Globals.repeatable_maps.size()-1)]
	if random_map == self.name:
		get_random_map()
	else: Globals.main.load_map(random_map)

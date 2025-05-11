extends Item

const heal_amount: float = 50.0

func use_item():
	Globals.player.hp += heal_amount
	Globals.player.mp += heal_amount/2
	Globals.player.hp = clamp(Globals.player.hp, 0, Globals.player.max_hp)
	Globals.player.mp = clamp(Globals.player.mp, 0, Globals.player.max_mp)
	#despawn
	await get_tree().create_timer(2).timeout
	self.queue_free()

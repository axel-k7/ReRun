extends Node

func _process(_delta: float) -> void:
	if Globals.player != null:
		$VBoxContainer/hpbar.value = Globals.player.hp*100/Globals.player.max_hp
		$VBoxContainer/hpbar/Label.text = str(Globals.player.hp)
		$VBoxContainer/mpbar.value = Globals.player.mp*100/Globals.player.max_mp
		$VBoxContainer/mpbar/Label.text = str(Globals.player.mp)
		$VBoxContainer/stmbar.value = Globals.player.stamina*100/100 #max stamina
		$expbar.value = Globals.player.experience*100/Globals.player.exp_thold
		$expbar/Label.text = str(roundi(Globals.player.experience*100/Globals.player.exp_thold)) + "%"
		$level.text = "Level " + str(Globals.player.level)
	
	if !BattleManagerTb.battle_active:
		self.visible = true
	elif BattleManagerTb.battle_active:
		self.visible = false

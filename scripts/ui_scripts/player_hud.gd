extends Node

@onready var hpbar: TextureProgressBar = $VBoxContainer/hpbar
@onready var mpbar: TextureProgressBar = $VBoxContainer/mpbar
@onready var stmbar: TextureProgressBar = $VBoxContainer/stmbar

func _process(delta: float) -> void:
	if Globals.player != null:
		hpbar.value = Globals.player.hp*100/Globals.player.max_hp
		mpbar.value = Globals.player.mp*100/Globals.player.max_mp
		stmbar.value = Globals.player.stamina*100/100 #max stamina
	
	if !BattleManagerTb.battle_active:
		self.visible = true
	elif BattleManagerTb.battle_active:
		self.visible = false

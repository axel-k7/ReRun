extends Node3D

func _ready():
	spawn_player()

func spawn_player():
	var player_scene =  preload("res://scenes/player/player.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	Globals.player = player

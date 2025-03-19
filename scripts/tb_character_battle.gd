extends Node2D

@onready var hp_bar = $hp_bar
@onready var sprite = $Sprite2D
@onready var sfx = $AudioStreamPlayer2D
var character: Object

signal die

func _process(delta: float):
	pass

func set_up_self(given_character: Object, side: String, party_index: int):
	character = given_character
	if side == "ally":
		self.global_position.y += 200
		self.global_position.x += 150*party_index
		hp_bar.position.y -= 100
	elif side == "enemy":
		self.global_position.y -= 200
		self.global_position.x += 150*party_index
		self.position.y += 100
	sprite.texture = character.tb_sprite
	self.name = character.name
	
	sfx.stream = character.hurt_sfx
	hp_bar.max_value = character.max_hp
	hp_bar.value = character.hp

func on_damaged(amount: int):
	character.hp -= amount
	hp_bar.value = character.hp
	sfx.play()
	if character.hp <= 0:
		self.rotate(1)
		emit_signal("die")
		character.die()

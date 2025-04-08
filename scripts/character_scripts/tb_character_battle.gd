extends Node2D

@onready var hp_bar = $hp_bar
@onready var sprite = $Sprite2D
@onready var sfx = $AudioStreamPlayer2D
var character: Object

signal die

func set_up_self(given_character: Object, side: String, party_index: int):
	character = given_character
	self.name = character.name + " TB"
	if side == "ally":
		sprite.texture = character.tb_sprite_ally
		self.global_position.y += 200
		self.global_position.x += 150*party_index
		hp_bar.position.y -= sprite.texture.get_height()/2 + 20
	elif side == "enemy":
		sprite.texture = character.tb_sprite_enemy
		self.global_position.y -= 200
		self.global_position.x += 150*party_index
		self.position.y += 100
		hp_bar.position.y -= sprite.texture.get_height()/2 + 20
	
	sfx.stream = character.hurt_sfx
	hp_bar.max_value = character.max_hp
	hp_bar.value = character.hp

func on_damaged(amount: int):
	character.on_damaged(amount)
	hp_bar.value = character.hp
	print("val ", hp_bar.value, " and ", character.hp)
	sfx.play()
	Globals.damage_flash(self)
	if character.hp <= 0:
		sprite.rotate(1)
		emit_signal("die")
		character.die()

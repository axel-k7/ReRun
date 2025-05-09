extends Control

var active: bool = false
@onready var ability_buttons: Array = [
	$ability1_Container,
	$ability2_Container,
	$ability3_Container,
	$ability4_Container
]

func _ready() -> void:
	self.visible = false
	self.size = get_viewport_rect().size
	for container in ability_buttons:
		container.size = get_viewport_rect().size/2
	ability_buttons[0].position = Vector2(0,0)
	ability_buttons[1].position = Vector2(0,get_viewport_rect().size.y/2)
	ability_buttons[2].position = Vector2(get_viewport_rect().size.x/2,0)
	ability_buttons[3].position = Vector2(get_viewport_rect().size.x/2,get_viewport_rect().size.y/2)

func activate():
	for i in ability_buttons.size():
		if i < Globals.player.attacks.size():
			ability_buttons[i].set_mouse_filter(MOUSE_FILTER_PASS)
			ability_buttons[i].visible = true
			var ability = Globals.player.attacks[i]
			ability_buttons[i].get_child(0).get_child(0).text = ability[0]
		else: 
			ability_buttons[i].set_mouse_filter(MOUSE_FILTER_IGNORE)
			ability_buttons[i].visible = false
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Globals.can_rotate_camera = false
	active = true
	self.visible = true

func deactivate():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Globals.can_rotate_camera = true
	active = false
	self.visible = false

func select_ability(number: int):
	if !active: pass
	elif active:
		Globals.player.selected_ability = number
		ability_buttons[number].get_child(0).modulate = Color(1, 1, 1, 1)

func deselect(number: int):
	ability_buttons[number].get_child(0).modulate = Color(1, 1, 1, 0.8)


func _on_ability_1_container_mouse_entered() -> void:
	select_ability(0)
func _on_ability_2_container_mouse_entered() -> void:
	select_ability(1)
func _on_ability_3_container_mouse_entered() -> void:
	select_ability(2)
func _on_ability_4_container_mouse_entered() -> void:
	select_ability(3)

func _on_ability_1_container_mouse_exited() -> void:
	deselect(0)
func _on_ability_2_container_mouse_exited() -> void:
	deselect(1)
func _on_ability_3_container_mouse_exited() -> void:
	deselect(2)
func _on_ability_4_container_mouse_exited() -> void:
	deselect(3)

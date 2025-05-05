extends Control

@onready var confirm_exit = $ConfirmExitRect
@onready var navbar = $ButtonNavBar
@onready var inv_container = $InventoryContainer
@onready var item_option_scene = preload("res://scenes/ui/item_option.tscn")
var toggle_time: float = 0.3

signal activate
signal deactivate

func _ready():
	activate.connect(on_activate)
	deactivate.connect(on_deactivate)
	#self.size = get_viewport_rect().size
	self.position.y += navbar.size.y

func on_activate():
	self.visible = true
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(0, 0), toggle_time)
	await tween.finished
	tween.stop()
	tween.tween_callback(queue_free)

func on_deactivate():
	confirm_exit.visible = false
	inv_container.visible = false
	for child in inv_container.get_children():
			child.queue_free()
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(0, navbar.size.y), toggle_time)
	await tween.finished
	self.visible = false
	tween.stop()
	tween.tween_callback(queue_free)

func _on_exit_button_pressed():
	if confirm_exit.visible == false:
		confirm_exit.visible = true
	elif confirm_exit.visible == true:
		confirm_exit.visible = false

func _on_save_button_pressed():
	Globals.save_config_file()
	Globals.system_message("Data Saved")

func _on_unstuck_button_pressed():
	if Globals.player == null:
		return
	Globals.player.global_position = Vector3(0, 10, 0)

func _on_confirm_exit_pressed():
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()

func _on_inventory_button_pressed() -> void:
	var item_y_limit = round(((get_viewport_rect().size.y/4)*3)/150)
	var item_index = 0
	if inv_container.visible == false:
		inv_container.visible = true
		for item in Globals.player.inventory:
			item_index += 1
			if item_index == item_y_limit:
				inv_container.columns += 1
			var item_option = item_option_scene.instantiate()
			inv_container.add_child(item_option)
			item_option.get_child(0).texture = load("res://vfx/item_sprites/" + item + ".png")
			item_option.get_child(1).text = item
			item_option.item_selected.connect(_inv_item_selected.bind(item_option, item))
	elif inv_container.visible == true:
		inv_container.visible = false
		for child in inv_container.get_children():
			child.queue_free()

func _inv_item_selected(index, item_option, item_name):
	item_option.queue_free()
	if index == 0:
		Globals.player.use_item(null, item_name)
	elif index == 1:
		Globals.player.drop_item(null, item_name)
	else: return

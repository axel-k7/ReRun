extends Control

@onready var confirm_exit = $ConfirmExitRect
@onready var navbar = $ButtonNavBar
var toggle_time: float = 0.3

signal activate
signal deactivate

func _ready():
	activate.connect(on_activate)
	deactivate.connect(on_deactivate)
	self.size = get_viewport_rect().size
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
	Globals.save_inventory_data(Globals.player.inventory)
	Globals.save_config_file()
	Globals.system_message("Data Saved")

func _on_unstuck_button_pressed():
	if Globals.player == null:
		return
	Globals.player.global_position = Vector3(0, 10, 0)

func _on_confirm_exit_pressed():
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()

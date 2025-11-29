extends Node2D

var required_keys = {
	KEY_L: false,
	KEY_I: false,
	KEY_M: false,
	KEY_B: false,
	KEY_O: false,
}

func _input(event: InputEvent):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://scenes/Main menu.tscn")
	if event is InputEventKey:
		if event.keycode in required_keys:
			required_keys[event.keycode] = event.pressed
			if _all_keys_pressed():
				get_tree().change_scene_to_file("res://levels/limbo_hard.tscn")

func _all_keys_pressed() -> bool:
	for pressed in required_keys.values():
		if pressed == false:
			return false
	return true

func _on_Pou_Pressed_connect() -> void:
	await get_tree().create_timer(1.0).timeout
	$Fade_All.play("Fade_All")

func _on_GE_Pressed_connect() -> void:
	await get_tree().create_timer(1.0).timeout
	$Fade_All.play("Fade_All")

func _on_Limbo_Pressed_connect() -> void:
	await get_tree().create_timer(1.0).timeout
	$Fade_All.play("Fade_All")

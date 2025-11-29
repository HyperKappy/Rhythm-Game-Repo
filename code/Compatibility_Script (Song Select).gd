extends Node2D

@onready var back_button: Button = $BackButton

var required_keys = {
	KEY_L: false,
	KEY_I: false,
	KEY_M: false,
	KEY_B: false,
	KEY_O: false,
}


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	

func _input(event: InputEvent):
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
	$Pou.z_index = 100
	await get_tree().create_timer(1.0).timeout
	$Fade_All.play("Fade_All")

func _on_GE_Pressed_connect() -> void:
	$GIVEN_ENOUGH.z_index = 100
	await get_tree().create_timer(1.0).timeout
	$Fade_All.play("Fade_All")

func _on_Limbo_Pressed_connect() -> void:
	$Isolation.z_index = 100
	await get_tree().create_timer(1.0).timeout
	$Fade_All.play("Fade_All")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main menu.tscn")

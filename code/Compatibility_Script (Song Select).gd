extends Node2D

func _input(_event):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()


func _on_Pou_Pressed_connect() -> void:
	await get_tree().create_timer(1.0).timeout
	$Fade_All.play("Fade_All")

func _on_GE_Pressed_connect() -> void:
	await get_tree().create_timer(1.0).timeout
	$Fade_All.play("Fade_All")

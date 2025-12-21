extends Node2D

func _on_GE_Pressed_connect():
	await get_tree().create_timer(1.0).timeout
	$Foreground/Fade_All.play("Fade_All")

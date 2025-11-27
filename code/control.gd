extends Control

func _input(ev):
	if Input.is_key_pressed(KEY_O):
		get_tree().change_scene_to_file("res://settings.tscn")

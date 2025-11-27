extends TextureButton

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

func _on_pressed():
	get_tree().change_scene_to_file("res://scenes/settings.tscn")
	print('pressed')

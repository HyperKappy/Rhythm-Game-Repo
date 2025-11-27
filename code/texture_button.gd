extends TextureButton

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

func pressed():
	get_tree().change_scene_to_file("res://scenes/songselect.tscn")
	print('pressed')

extends TextureButton



func _on_pressed() -> void:
	$Click_Animation.play("Schuiven")
	preload("res://scenes/Extras.tscn")
	preload("res://Resources/images/Extras_Menu.png")
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://scenes/Extras.tscn")

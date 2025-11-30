extends TextureButton



func _on_pressed() -> void:
	$Click_Animation.play("Schuiven")
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/Extras.tscn")

extends Node2D

#func _input(event: InputEvent) -> void:
#	if event is InputEventKey and event.pressed and not event.echo:
#		if event.keycode == KEY_1:
#			_start_guess()
#		if event.keycode == KEY_2:
#			_start_enough()

func _start_guess() -> void:
	get_tree().change_scene_to_file("res://levels/guess.tscn")
	
func _start_enough() -> void:
	get_tree().change_scene_to_file("res://levels/GIVEN_ENOUGH.tscn")

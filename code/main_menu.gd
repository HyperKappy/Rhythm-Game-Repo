extends Node2D


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			_start_temp1()
		if event.keycode == KEY_2:
			_start_temp2()
		if event.keycode == KEY_3:
			_start_temp3()
		if event.keycode == KEY_0:
			_start_test()


func _start_temp1() -> void:
	get_tree().change_scene_to_file("res://levels/temp1.tscn")
	
func _start_temp2() -> void:
	get_tree().change_scene_to_file("res://levels/temp2.tscn")

func _start_temp3() -> void:
	get_tree().change_scene_to_file("res://levels/temp3.tscn")
	
func _start_test() -> void:
	get_tree().change_scene_to_file("res://levels/test.tscn")
	

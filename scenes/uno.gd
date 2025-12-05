extends TextureButton

var pressed_state: bool = false

func _on_UNO_Pressed():
	$Select_Sound.play()
	$Low_Taper_Fade_UNO.stop(true)
	$Low_Taper_Fade_UNO.play("Center_On_Press")
	$UNO_Preview.stop()
	pressed_state = true
	await get_tree().create_timer(1.49).timeout
	get_tree().change_scene_to_file("res://levels/uno.tscn")

func _on_UNO_Button_Hovered():
	if pressed_state == false:
		$Low_Taper_Fade_UNO.play("hover_in")
		
		$UNO_Preview.play()
			

func _on_UNO_Button_Exited():
	if pressed_state == false:
		$Low_Taper_Fade_UNO.play("hover_out")
		$UNO_Preview.stop()


func _on_uno_preview_finished() -> void:
	if pressed_state == false:
		$UNO_Preview.play()

extends TextureButton

var pressed_state: bool = false


func _on_GE_pressed():
	$Select_Sound.play()
	$Low_Taper_Fade_GE.stop(true)
	$Low_Taper_Fade_GE.play("Center_On_Press")
	$GIVEN_ENOUGH_Preview.stop()
	pressed_state = true
	await get_tree().create_timer(1.49).timeout
	get_tree().change_scene_to_file("res://levels/GIVEN_ENOUGH.tscn")


func _on_GE_Button_Hovered():
	if pressed_state == false:
		$Low_Taper_Fade_GE.play("hover_in")
		$GIVEN_ENOUGH_Preview.play()

func _on_GE_Button_Exited():
	if pressed_state == false:
		$Low_Taper_Fade_GE.play("hover_out")
		$GIVEN_ENOUGH_Preview.stop()

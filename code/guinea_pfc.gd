extends TextureButton

var pressed_state: bool = false

func _on_GPFC_Pressed():
	$Select_Sound.play()
	$Low_Taper_Fade_GPFC.stop(true)
	$Low_Taper_Fade_GPFC.play("Center_On_Press")
	$GPFC_Preview.stop()
	pressed_state = true
	await get_tree().create_timer(1.49).timeout
	get_tree().change_scene_to_file("res://levels/gpfc.tscn")

func _on_GPFC_Button_Hovered():
	if pressed_state == false:
		$Low_Taper_Fade_GPFC.play("hover_in")
		
		$GPFC_Preview.play()
			

func _on_GPFC_Button_Exited():
	if pressed_state == false:
		$Low_Taper_Fade_GPFC.play("hover_out")
		$GPFC_Preview.stop()


func _on_GPFC_preview_finished() -> void:
	if pressed_state == false:
		$GPFC_Preview.play()

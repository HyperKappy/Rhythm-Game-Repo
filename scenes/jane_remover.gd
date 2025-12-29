extends TextureButton

var pressed_state: bool = false

func _on_JR_Pressed():
	$Select_Sound.play()
	$Low_Taper_Fade_JR.stop(true)
	$Low_Taper_Fade_JR.play("Center_On_Press")
	$JR_Preview.stop()
	pressed_state = true
	await get_tree().create_timer(1.49).timeout
	get_tree().change_scene_to_file("res://levels/jane.tscn")

func _on_JR_Button_Hovered():
	if pressed_state == false:
		$Low_Taper_Fade_JR.play("hover_in")
		
		$JR_Preview.play()
			

func _on_JR_Button_Exited():
	if pressed_state == false:
		$Low_Taper_Fade_JR.play("hover_out")
		$JR_Preview.stop()


func _on_JR_preview_finished() -> void:
	if pressed_state == false:
		$JR_Preview.play()

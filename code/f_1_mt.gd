extends TextureButton

var pressed_state: bool = false

func _on_F1_Pressed():
	$Select_Sound.play()
	$Low_Taper_Fade_F1.stop(true)
	$Low_Taper_Fade_F1.play("Center_On_Press")
	$F1_MT_Preview.stop()
	pressed_state = true
	await get_tree().create_timer(1.49).timeout
	get_tree().change_scene_to_file("res://levels/f1.tscn")

func _on_F1_Button_Hovered():
	if pressed_state == false:
		$Low_Taper_Fade_F1.play("hover_in")
		
		$F1_MT_Preview.play()
			

func _on_F1_Button_Exited():
	if pressed_state == false:
		$Low_Taper_Fade_F1.play("hover_out")
		$F1_MT_Preview.stop()


func _on_F1_preview_finished() -> void:
	if pressed_state == false:
		$F1_MT_Preview.play()

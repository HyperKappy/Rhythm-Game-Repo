extends TextureButton

var pressed_state: bool = false



func _on_Pou_Pressed():
	$Select_Sound.play()
	$Low_Taper_Fade_GU.stop(true)
	$Low_Taper_Fade_GU.play("Center_On_Press")
	$Guess_Preview.stop()
	pressed_state = true
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://levels/guess.tscn")


func _on_Pou_Button_Hovered():
	if pressed_state == false:
		$Low_Taper_Fade_GU.play("hover_in")
		$Guess_Preview.play()

func _on_Pou_Button_Exited():
	if pressed_state == false:
		$Low_Taper_Fade_GU.play("hover_out")
		$Guess_Preview.stop()

extends TextureButton

var pressed_state: bool = false

func _on_Pingpong_Pressed():
	$Select_Sound.play()
	$Low_Taper_Fade_PP.stop(true)
	$Low_Taper_Fade_PP.play("Center_On_Press")
	$Pingpong_Preview.stop()
	pressed_state = true
	await get_tree().create_timer(1.49).timeout
	get_tree().change_scene_to_file("res://levels/ping_pong.tscn")

func _on_Pingpong_Button_Hovered():
	if pressed_state == false:
		$Low_Taper_Fade_PP.play("hover_in")
		
		$Pingpong_Preview.play()
			

func _on_Pingpong_Button_Exited():
	if pressed_state == false:
		$Low_Taper_Fade_PP.play("hover_out")
		$Pingpong_Preview.stop()


func _on_Pingpong_preview_finished() -> void:
	if pressed_state == false:
		$Pingpong_Preview.play()

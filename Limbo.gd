extends TextureButton

var pressed_state: bool = false


#Change to actual song
func _on_Limbo_Pressed():
	$Select_Sound.play()
	$Low_Taper_Fade_LI.stop(true)
	$Low_Taper_Fade_LI.play("Center_On_Press")
	$Limbo_Preview.stop()
	pressed_state = true
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://levels/Limbo.tscn")

#Fade animations and previews are played by this
func _on_Limbo_Button_Hovered():
	if pressed_state == false:
		$Low_Taper_Fade_LI.play("hover_in")
		$Limbo_Preview.play()

func _on_Limbo_Button_Exited():
	if pressed_state == false:
		$Low_Taper_Fade_LI.play("hover_out")
		$Limbo_Preview.stop()

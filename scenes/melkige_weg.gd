extends TextureButton

var pressed_state: bool = false

func _on_MW_Pressed():
	$Select_Sound.play()
	$Low_Taper_Fade_MW.stop(true)
	$Low_Taper_Fade_MW.play("Center_On_Press")
	$MW_Preview.stop()
	pressed_state = true
	await get_tree().create_timer(1.49).timeout
	get_tree().change_scene_to_file("res://levels/melk.tscn")

func _on_MW_Button_Hovered():
	if pressed_state == false:
		$Low_Taper_Fade_MW.play("hover_in")
		
		$MW_Preview.play()
			

func _on_MW_Button_Exited():
	if pressed_state == false:
		$Low_Taper_Fade_MW.play("hover_out")
		$MW_Preview.stop()


func _on_MW_preview_finished() -> void:
	if pressed_state == false:
		$MW_Preview.play()

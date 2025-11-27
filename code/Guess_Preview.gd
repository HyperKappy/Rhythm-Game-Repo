extends AudioStreamPlayer

func _on_Pou_Button_Hovered():
	$Guess_Preview.play()

func _on_Pou_Button_Exited():
	$Guess_Preview.stop()

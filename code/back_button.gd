extends Button

func _ready():
	connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed():
	get_tree().change_scene_to_file("res://scenes/Main menu.tscn")

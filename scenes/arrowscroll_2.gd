extends Sprite2D

func _ready():
	$Scroll.play("Scroll")
	$Scroll.stop(false)
	await get_tree().create_timer(5.5).timeout
	$Scroll.speed_scale = 1
	$Scroll.play("Scroll")

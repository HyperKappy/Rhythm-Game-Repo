extends Sprite2D

@export var scroll_velocity: float = 1500.0 

func _ready() -> void:
	add_to_group("mines")
	pass

func _process(delta: float) -> void:
	position.y += scroll_velocity * delta

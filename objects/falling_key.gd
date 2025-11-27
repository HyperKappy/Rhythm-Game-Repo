extends Sprite2D

@export var scroll_velocity: float = 1500  # pixels per seconde
@export var lane_index: int = 0             # wordt door de spawner gezet

func _ready() -> void:
	add_to_group("notes")

func _process(delta: float) -> void:
	position.y += scroll_velocity * delta

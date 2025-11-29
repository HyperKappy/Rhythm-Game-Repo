extends Sprite2D

@export var scroll_velocity: float = 1000.0
@export var lane_index: int = 0

@export var body_width_factor: float = 1.0	# 1.0 = volle breedte

var duration_ms: float = 0.0

@onready var body_sprite: Sprite2D = $HoldBody
@onready var end_sprite: Sprite2D = $HoldEnd


var is_long_note: bool = true
var head_judged: bool = false
var head_hit_success: bool = false
var tail_judged: bool = false
var is_broken: bool = false



const HEAD_BASE_OFFSET: float = 0.0	
const TAIL_BASE_OFFSET_FROM_BOTTOM: float = 0.0	

func _ready() -> void:
	add_to_group("notes")
	add_to_group("long_notes")
	centered = true

	if body_sprite:
		body_sprite.centered = false
	if end_sprite:
		end_sprite.centered = false

	_update_length()

func _process(delta: float) -> void:
	position.y += scroll_velocity * delta

func setup(duration: float) -> void:
	duration_ms = max(duration, 0.0)
	_update_length()

func _update_length() -> void:
	if texture == null or body_sprite == null or end_sprite == null:
		return
	if body_sprite.texture == null or end_sprite.texture == null:
		return

	if duration_ms <= 0.0:
		body_sprite.visible = false
		end_sprite.visible = false
		return

	body_sprite.visible = true
	end_sprite.visible = true

	var duration_s: float = duration_ms / 1000.0
	var distance_pixels: float = scroll_velocity * duration_s

	var head_h: float = float(texture.get_height())
	var body_w: float = float(body_sprite.texture.get_width())
	var body_h: float = float(body_sprite.texture.get_height())
	var end_w: float = float(end_sprite.texture.get_width())
	var end_h: float = float(end_sprite.texture.get_height())


	var head_top_y: float = -head_h * 0.5
	var head_bottom_y: float = head_h * 0.5


	var head_base_y: float = head_top_y + HEAD_BASE_OFFSET


	var tail_base_y: float = head_base_y - distance_pixels


	var body_length: float = max(head_base_y - tail_base_y, 0.0)

	if body_h > 0.0:
		body_sprite.scale.y = body_length / body_h
	else:
		body_sprite.scale.y = 1.0

	body_sprite.scale.x = body_width_factor
	var body_scaled_width: float = body_w * body_width_factor

	var body_top_y: float = tail_base_y
	var body_bottom_y: float = head_base_y

	body_sprite.position = Vector2(
		-body_scaled_width * 0.5,
		body_top_y
	)



	var tail_pos_y: float = tail_base_y - end_h + TAIL_BASE_OFFSET_FROM_BOTTOM

	end_sprite.position = Vector2(
		-end_w * 0.5,
		tail_pos_y
	)
	end_sprite.scale = Vector2(1.0, 1.0)
	
func mark_head_result(result: String) -> void:
	if head_judged:
		return
	head_judged = true
	head_hit_success = (result != "MISS")

	if result == "MISS":
		_break_long_note()


func mark_tail_result(result: String) -> void:
	if tail_judged:
		return
	tail_judged = true

	if result == "MISS":
		_break_long_note()
	else:
		queue_free()


func _break_long_note() -> void:
	if is_broken:
		return

	is_broken = true

	modulate.a = 0.3

	remove_from_group("notes")

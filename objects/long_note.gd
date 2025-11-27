extends Sprite2D

@export var scroll_velocity: float = 1500.0
@export var lane_index: int = 0

@export var body_width_factor: float = 1.0	# 1.0 = volle breedte

var duration_ms: float = 0.0

@onready var body_sprite: Sprite2D = $HoldBody
@onready var end_sprite: Sprite2D = $HoldEnd

# long note state
var is_long_note: bool = true
var head_judged: bool = false
var head_hit_success: bool = false
var tail_judged: bool = false
var is_broken: bool = false


# We nemen de head (hitobject) als referentiepunt:
# root texture = note-holdhitobject-a.png (driehoek naar beneden, H=64)
# body = 128x32
# end  = note-holdend-a.png (driehoek naar boven, H=64)
#
# Voor nu gaan we uit van:
# - de "basis" van de head (waar de body aan vast moet zitten)
#   ligt een klein stukje onder de top van de texture.
const HEAD_BASE_OFFSET: float = 0.0	# pixels onder top van de head
# - de "basis" van de tail (waar de body aan vast moet zitten)
#   ligt een klein stukje boven de bottom van de texture.
const TAIL_BASE_OFFSET_FROM_BOTTOM: float = 0.0	# pixels boven onderkant tail

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

	# ----------------------------------------------------
	# 1. HEAD als uitgangspunt
	# ----------------------------------------------------
	# root is gecentreerd: loopt van -head_h/2 (top) tot +head_h/2 (bottom)
	var head_top_y: float = -head_h * 0.5
	var head_bottom_y: float = head_h * 0.5

	# De basis van de head (waar body aan vast moet) ligt
	# HEAD_BASE_OFFSET pixels onder de top.
	var head_base_y: float = head_top_y + HEAD_BASE_OFFSET

	# De totale afstand van head-basis naar tail-basis is distance_pixels:
	# head_base_y (onder)  -------- distance_pixels --------  tail_base_y (boven)
	var tail_base_y: float = head_base_y - distance_pixels

	# ----------------------------------------------------
	# 2. BODY exact tussen head-basis en tail-basis
	# ----------------------------------------------------
	var body_length: float = max(head_base_y - tail_base_y, 0.0)

	if body_h > 0.0:
		body_sprite.scale.y = body_length / body_h
	else:
		body_sprite.scale.y = 1.0

	body_sprite.scale.x = body_width_factor
	var body_scaled_width: float = body_w * body_width_factor

	# body loopt van tail_base_y (top) tot head_base_y (bottom)
	var body_top_y: float = tail_base_y
	var body_bottom_y: float = head_base_y

	body_sprite.position = Vector2(
		-body_scaled_width * 0.5,
		body_top_y
	)

	# ----------------------------------------------------
	# 3. TAIL zo plaatsen dat zijn "basis" op tail_base_y ligt
	# ----------------------------------------------------
	# Tail-texture loopt van 0 (top) tot end_h (bottom).
	# We willen dat de basis een stukje bóven de onderkant ligt,
	# dus: tail_base_y = tail_pos_y + end_h - TAIL_BASE_OFFSET_FROM_BOTTOM
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
		# volledig goed gespeeld → visual mag weg
		queue_free()


func _break_long_note() -> void:
	if is_broken:
		return

	is_broken = true

	# opacity omlaag (geldt voor head, body en tail tegelijk)
	modulate.a = 0.3

	# tail mag niet meer gehit worden: haal uit "notes"-group,
	# zodat _check_auto_misses & handle_hit_for_lane 'm negeren.
	remove_from_group("notes")

extends Sprite2D

@export var scroll_velocity: float = 1000.0
@export var lane_index: int = 0

# Kleine afstanden in pixels om de naden visueel mooi te maken
@export var head_to_body_gap: float = 0.0   # afstand tussen head-apex en begin van de body (omhoog)
@export var body_to_tail_gap: float = 0.0   # afstand tussen einde van de body en tail-apex (omhoog)

# duur in milliseconden (wordt gezet vanuit SongPlayer via spawner)
var duration_ms: float = 0.0

@onready var body_sprite: Sprite2D = $HoldBody
@onready var end_sprite: Sprite2D = $HoldEnd

# judgement-state
var head_result: String = ""
var tail_result: String = ""
var head_judged: bool = false
var tail_judged: bool = false
var is_broken: bool = false

var base_modulate: Color


func _ready() -> void:
	add_to_group("notes")
	add_to_group("long_notes")

	base_modulate = modulate

	_update_length()


func _process(delta: float) -> void:
	position.y += scroll_velocity * delta


func setup(duration: float) -> void:
	duration_ms = max(duration, 0.0)
	_update_length()


func _update_length() -> void:
	if body_sprite == null or end_sprite == null:
		return
	if body_sprite.texture == null or end_sprite.texture == null:
		return

	if duration_ms <= 0.0:
		body_sprite.visible = false
		end_sprite.visible = false
		return

	body_sprite.visible = true
	end_sprite.visible = true

	# 1) totale tijd → wereldafstand in pixels
	var duration_s: float = duration_ms / 1000.0
	var distance_world: float = scroll_velocity * duration_s

	# 2) omrekenen naar lokale units (root is geschaald door note_scale.y)
	var root_scale_y: float = scale.y
	if root_scale_y == 0.0:
		root_scale_y = 1.0
	var distance_local: float = distance_world / root_scale_y

	# 3) body-lengte in lokale ruimte
	var body_tex_h: float = float(body_sprite.texture.get_height())
	if body_tex_h <= 0.0:
		body_tex_h = 1.0

	var body_length: float = distance_local - head_to_body_gap - body_to_tail_gap
	if body_length < 0.0:
		body_length = 0.0

	# Coordinate systeem:
	# y neemt toe naar BENEDEN, maar we willen dat de hold OMHOOG groeit:
	# head (0), body en tail op NEGATIEVE y-waardes.
	var tail_top_y: float = -distance_local

	# body loopt van body_top_y tot body_bottom_y
	var body_top_y: float = tail_top_y + body_to_tail_gap
	var body_bottom_y: float = -head_to_body_gap

	# schalen zodat de body hoogte = body_length
	body_sprite.scale.y = body_length / body_tex_h
	body_sprite.position.y = body_top_y

	# tail-top op tail_top_y
	end_sprite.position.y = tail_top_y

	# X centreren
	var body_tex_w: float = float(body_sprite.texture.get_width())
	var end_tex_w: float = float(end_sprite.texture.get_width())

	body_sprite.position.x = -body_tex_w * 0.5
	end_sprite.position.x = -end_tex_w * 0.5



func mark_head_result(result: String) -> void:
	if head_judged:
		return

	head_judged = true
	head_result = result

	if result == "MISS":
		_break_hold()
		return
	# goede head → speler moet vasthouden


func mark_tail_result(result: String) -> void:
	if tail_judged:
		return

	tail_judged = true
	tail_result = result

	if is_broken:
		return

	if result == "MISS":
		_break_hold()
	else:
		queue_free()


func _break_hold() -> void:
	if is_broken:
		return

	is_broken = true

	var faded: Color = base_modulate
	faded.a = 0.3

	modulate = faded
	if body_sprite != null:
		body_sprite.modulate = faded
	if end_sprite != null:
		end_sprite.modulate = faded

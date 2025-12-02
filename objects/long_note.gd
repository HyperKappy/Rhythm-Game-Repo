extends Sprite2D

@export var scroll_velocity: float = 1000.0
@export var lane_index: int = 0

@export var head_to_body_gap: float = 0.0
@export var body_to_tail_gap: float = 0.0

var duration_ms: float = 0.0

@onready var body_sprite: Sprite2D = $HoldBody
@onready var end_sprite: Sprite2D = $HoldEnd

var head_result: String = ""
var tail_result: String = ""
var head_judged: bool = false
var tail_judged: bool = false
var is_broken: bool = false

var base_modulate: Color

var hold_visual_active: bool = false
var hold_clip_y: float = 1000000.0

var body_mat: ShaderMaterial = null
var end_mat: ShaderMaterial = null


func _ready() -> void:
	add_to_group("notes")
	add_to_group("long_notes")

	base_modulate = modulate

	_init_shaders()
	_update_length()


func _process(delta: float) -> void:
	position.y += scroll_velocity * delta


func setup(duration: float) -> void:
	duration_ms = max(duration, 0.0)
	_update_length()


func _init_shaders() -> void:
	var shader := Shader.new()
	shader.code = """
		shader_type canvas_item;

		// wereld-Y waar body én tail moeten stoppen
		uniform float cutoff_world_y = 1000000.0;
		// hoe donker iets mag zijn voordat we het als "achtergrond" zien
		uniform float alpha_cutoff = 0.1;

		varying float world_y;

		void vertex() {
			// wereldpositie van deze vertex
			vec4 wp = MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0);
			world_y = wp.y;
		}

		void fragment() {
			vec4 tex = texture(TEXTURE, UV);
			float brightness = (tex.r + tex.g + tex.b) / 3.0;

			// 1) zwarte / bijna zwarte pixels weggooien (achtergrond)
			if (brightness <= alpha_cutoff) {
				discard;
			}

			// 2) alles ONDER de cutoff (grotere y) weggooien
			if (world_y > cutoff_world_y) {
				discard;
			}

			// 3) witte vorm volledig opaak tekenen (met modulate-kleur)
			COLOR = vec4(tex.rgb, 1.0) * COLOR;
		}
	"""

	if body_sprite != null:
		body_mat = ShaderMaterial.new()
		body_mat.shader = shader
		body_sprite.material = body_mat

	if end_sprite != null:
		end_mat = ShaderMaterial.new()
		end_mat.shader = shader
		end_sprite.material = end_mat


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

	var duration_s: float = duration_ms / 1000.0
	var distance_world: float = scroll_velocity * duration_s

	var root_scale_y: float = scale.y
	if root_scale_y == 0.0:
		root_scale_y = 1.0
	var distance_local: float = distance_world / root_scale_y

	var body_tex_h: float = float(body_sprite.texture.get_height())
	if body_tex_h <= 0.0:
		body_tex_h = 1.0

	var body_length: float = distance_local - head_to_body_gap - body_to_tail_gap
	if body_length < 0.0:
		body_length = 0.0

	var tail_top_y: float = -distance_local

	var body_top_y: float = tail_top_y + body_to_tail_gap
	var body_bottom_y: float = -head_to_body_gap
	
	body_sprite.scale.y = body_length / body_tex_h
	body_sprite.position.y = body_top_y

	end_sprite.position.y = tail_top_y

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


func start_hold_visual(hit_world_y: float) -> void:
	hold_visual_active = true
	hold_clip_y = hit_world_y

	if body_mat != null:
		body_mat.set_shader_parameter("cutoff_world_y", hit_world_y)
	if end_mat != null:
		end_mat.set_shader_parameter("cutoff_world_y", hit_world_y)


func stop_hold_visual() -> void:
	hold_visual_active = false
	hold_clip_y = 1000000.0

	if body_mat != null:
		body_mat.set_shader_parameter("cutoff_world_y", 1000000.0)
	if end_mat != null:
		end_mat.set_shader_parameter("cutoff_world_y", 1000000.0)

	if end_sprite != null:
		end_sprite.visible = true
	if body_sprite != null:
		body_sprite.visible = true

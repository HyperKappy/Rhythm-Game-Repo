extends Node2D

@export var falling_key_scene: PackedScene = preload("res://objects/falling_key.tscn")
@export var long_note_scene: PackedScene = preload("res://objects/long_note.tscn")
@export var mine_scene: PackedScene = preload("res://objects/mine.tscn")

@export var scroll_velocity: float = 1000.0

@export var key_listener_paths: Array[NodePath]

@export var spawn_margin: float = 50.0

@export var note_scale: Vector2 = Vector2(1.4, 1.4)

@export var auto_spawn_min_interval: float = 0.1
@export var auto_spawn_max_interval: float = 0.5

var lane_x_positions: Array[float] = []
var lane_rotations: Array[float] = []
var spawn_y: float = 0.0

var auto_spawn_enabled: bool = false
var auto_spawn_timer: Timer


func _ready() -> void:
	randomize()
	_calculate_spawn_y()
	_init_lane_data()
	_init_auto_spawn_timer()


func _calculate_spawn_y() -> void:
	var viewport_rect := get_viewport().get_visible_rect()
	var camera := get_viewport().get_camera_2d()

	if camera:
		var top_screen_y := camera.global_position.y - viewport_rect.size.y * 0.5
		spawn_y = top_screen_y - spawn_margin
	else:
		spawn_y = -200.0

	print("Spawn Y ingesteld op:", spawn_y)


func _init_lane_data() -> void:
	lane_x_positions.clear()
	lane_rotations.clear()

	for path in key_listener_paths:
		var sprite := get_node(path) as Sprite2D
		if sprite == null:
			push_warning("Keylistener niet gevonden voor pad: " + str(path))
		else:
			var x: float = sprite.global_position.x
			var rot: float = sprite.global_rotation
			lane_x_positions.append(x)
			lane_rotations.append(rot)

	if lane_x_positions.is_empty():
		push_warning("Geen lane_x_positions ingesteld! Vul key_listener_paths in de Inspector.")


func _init_auto_spawn_timer() -> void:
	auto_spawn_timer = Timer.new()
	auto_spawn_timer.one_shot = true
	add_child(auto_spawn_timer)
	auto_spawn_timer.timeout.connect(_on_auto_spawn_timer_timeout)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("spawn_note"):
		spawn_random_note()
		
	if event.is_action_pressed("toggle_auto_spawn"):
		_toggle_auto_spawn()


func _toggle_auto_spawn() -> void:
	auto_spawn_enabled = !auto_spawn_enabled

	if auto_spawn_enabled:
		print("Auto-spawn: AAN")
		_start_auto_spawn_cycle()
	else:
		print("Auto-spawn: UIT")
		if auto_spawn_timer:
			auto_spawn_timer.stop()


func _start_auto_spawn_cycle() -> void:
	if not auto_spawn_enabled:
		return

	var interval := randf_range(auto_spawn_min_interval, auto_spawn_max_interval)
	auto_spawn_timer.wait_time = interval
	auto_spawn_timer.start()
	print("Volgende auto-spawn over", interval, "seconden")


func _on_auto_spawn_timer_timeout() -> void:
	if not auto_spawn_enabled:
		return

	spawn_random_note()
	_start_auto_spawn_cycle()


func spawn_random_note() -> void:
	if lane_x_positions.is_empty():
		push_warning("Geen lanes bekend, kan geen note spawnen.")
		return

	var lane_index: int = randi() % lane_x_positions.size()
	spawn_note_in_lane(lane_index)


func spawn_note_in_lane(lane_index: int) -> void:
	if falling_key_scene == null:
		push_warning("falling_key_scene niet ingesteld!")
		return

	if lane_index < 0 or lane_index >= lane_x_positions.size():
		push_warning("Ongeldige lane_index: " + str(lane_index))
		return

	var note := falling_key_scene.instantiate() as Sprite2D
	if note == null:
		push_warning("falling_key_scene is geen Sprite2D.")
		return

	var x: float = lane_x_positions[lane_index]
	var rot: float = lane_rotations[lane_index]

	note.global_position = Vector2(x, spawn_y)
	note.scale = note_scale
	note.global_rotation = rot

	note.scroll_velocity = scroll_velocity

	note.lane_index = lane_index

	get_parent().add_child(note)

	print("Note gespawned in lane", lane_index, "op x =", x, "y =", spawn_y, "rot =", rot)


func spawn_long_note(lane_index: int, duration_ms: float) -> void:
	if long_note_scene == null:
		return
	
	if lane_index < 0 or lane_index >= lane_x_positions.size():
		return
	
	var note := long_note_scene.instantiate() as Sprite2D
	if note == null:
		return
	
	var x: float = lane_x_positions[lane_index]
	
	note.global_position = Vector2(x, spawn_y)
	note.scale = note_scale
	note.rotation = 0.0
	
	note.scroll_velocity = scroll_velocity
	
	note.lane_index = lane_index
	
	if note.has_method("setup"):
		note.setup(duration_ms)
	
	get_parent().add_child(note)

func spawn_mine_in_lane(lane_index: int) -> void:
	if mine_scene == null:
		push_warning("mine_scene niet ingesteld!")
		return

	if lane_index < 0 or lane_index >= lane_x_positions.size():
		push_warning("Ongeldige lane_index voor mine: " + str(lane_index))
		return

	var mine := mine_scene.instantiate() as Sprite2D
	if mine == null:
		push_warning("mine_scene is geen Sprite2D.")
		return

	var x: float = lane_x_positions[lane_index]
	var rot: float = lane_rotations[lane_index]

	mine.global_position = Vector2(x, spawn_y)
	mine.scale = note_scale
	mine.global_rotation = rot


	get_parent().add_child(mine)

	print("Mine gespawned in lane", lane_index, "op x =", x, "y =", spawn_y)

extends Node

@export var pause_menu_scene: PackedScene = preload("res://scenes/pause_menu.tscn")

@export var chart_path: String = ""
@export var spawn_ahead_ms: float = 0.0  

@export var mines_chart_path: String = ""

var notes: Array = []
var note_index: int = 0

var mines: Array = []
var mine_index: int = 0

var intro_label: Label = null
var level_started: bool = false
var intro_overlay: Control = null

@onready var audio_player: AudioStreamPlayer = $AudioPlayer as AudioStreamPlayer
@onready var spawner: Node = $GameLevel/falling_key_spawner
@onready var judgement = $GameLevel/Judgement
@onready var ui_layer: CanvasLayer = $GameLevel/UILayer

var results_scene: PackedScene = preload("res://levels/results_screen.tscn")

@export var use_chart_audio_path: bool = true
@export var audio_stream: AudioStream = null


func _ready() -> void:
	_load_chart()
	_load_mines_chart()
	_setup_audio()

	_show_ready_go_intro()

	audio_player.finished.connect(_on_audio_finished)


func _process(delta: float) -> void:
	if !level_started:
		return
	
	if notes.is_empty() or audio_player == null or not audio_player.playing:
		return

	
	var song_time_ms: float = audio_player.get_playback_position() * 1000.0

	while note_index < notes.size():
		var note_data: Dictionary = notes[note_index]
		var note_time_ms: float = float(note_data.get("time", 0.0))

		
		if note_time_ms <= song_time_ms + spawn_ahead_ms:
			var lane_1_based: int = int(note_data.get("lane", 1))
			var lane_index: int = lane_1_based - 1  # 1..4 -> 0..3

			
			if note_data.has("end_time"):
				var end_time_ms: float = float(note_data.get("end_time", note_time_ms))
				var duration_ms: float = max(0.0, end_time_ms - note_time_ms)
				spawner.spawn_long_note(lane_index, duration_ms)
			else:
				spawner.spawn_note_in_lane(lane_index)

			note_index += 1
		else:
			break

	if not mines.is_empty():
			while mine_index < mines.size():
				var mine_data: Dictionary = mines[mine_index]
				var mine_time_ms: float = float(mine_data.get("time", 0.0))

				if mine_time_ms <= song_time_ms + spawn_ahead_ms:
					var lane_1_based_mine: int = int(mine_data.get("lane", 1))
					var mine_lane_index: int = lane_1_based_mine - 1  # 1..4 -> 0..3

					if spawner.has_method("spawn_mine_in_lane"):
						spawner.spawn_mine_in_lane(mine_lane_index)

					mine_index += 1
				else:
					break

func _load_chart() -> void:
	var file: FileAccess = FileAccess.open(chart_path, FileAccess.READ)
	if file == null:
		push_error("Kan chart niet openen: " + chart_path)
		return

	var text: String = file.get_as_text()
	var data_var: Variant = JSON.parse_string(text)
	if typeof(data_var) != TYPE_DICTIONARY:
		push_error("Ongeldige chart JSON: " + chart_path)
		return

	var data: Dictionary = data_var as Dictionary
	notes = data.get("notes", [])
	
	if judgement != null and notes != null:
		judgement.max_possible_combo = notes.size()	

	if use_chart_audio_path and data.has("audio_file"):
		var audio_path: String = String(data["audio_file"])
		var stream: AudioStream = load(audio_path)
		if stream != null:
			audio_stream = stream
		else:
			push_warning("Kon audio niet laden uit chart: " + audio_path)

func _load_mines_chart() -> void:
	if mines_chart_path == "":
		return

	var file: FileAccess = FileAccess.open(mines_chart_path, FileAccess.READ)
	if file == null:
		push_warning("Kan mines-chart niet openen: " + mines_chart_path)
		return

	var text: String = file.get_as_text()
	var data_var: Variant = JSON.parse_string(text)
	if typeof(data_var) != TYPE_DICTIONARY:
		push_warning("Ongeldige mines JSON: " + mines_chart_path)
		return

	var data: Dictionary = data_var as Dictionary

	if data.has("mines"):
		mines = data.get("mines", [])
	else:
		mines = data.get("notes", [])

	mine_index = 0

	print("Mines geladen:", mines.size(), "uit", mines_chart_path)


func _setup_audio() -> void:
	if audio_player == null:
		push_error("AudioPlayer node niet gevonden. Bestaat er een child node 'AudioPlayer'?")
		return

	if audio_stream == null:
		push_warning("Geen audio_stream ingesteld voor SongPlayer.")
		return

	audio_player.stream = audio_stream


func _on_audio_finished() -> void:

	var timer := get_tree().create_timer(0.5)
	timer.timeout.connect(_show_results_screen)


func _show_results_screen() -> void:
	if results_scene == null:
		return

	var screen := results_scene.instantiate()
	add_child(screen)


	if screen.has_method("set_level_name"):

		var short_name := chart_path
		var slash_idx := chart_path.rfind("/")
		if slash_idx != -1 and slash_idx + 1 < chart_path.length():
			short_name = chart_path.substr(slash_idx + 1, chart_path.length() - slash_idx - 1)

		if short_name.ends_with(".json"):
			short_name = short_name.substr(0, short_name.length() - 5)

		screen.set_level_name(short_name)


	if judgement != null and judgement.has_method("set_ui_visible"):
		judgement.set_ui_visible(false)


	if judgement != null and screen.has_method("set_results_from_judgement"):
		screen.set_results_from_judgement(judgement)



func _show_ready_go_intro() -> void:

	if ui_layer == null:
		var found := get_node_or_null("UILayer")
		if found != null:
			ui_layer = found as CanvasLayer
		else:
			ui_layer = CanvasLayer.new()
			ui_layer.name = "UILayer"
			add_child(ui_layer)

	intro_overlay = Control.new()
	intro_overlay.anchor_left = 0.0
	intro_overlay.anchor_top = 0.0
	intro_overlay.anchor_right = 1.0
	intro_overlay.anchor_bottom = 1.0
	intro_overlay.offset_left = 0.0
	intro_overlay.offset_top = 0.0
	intro_overlay.offset_right = 0.0
	intro_overlay.offset_bottom = 0.0

	ui_layer.add_child(intro_overlay)


	intro_label = Label.new()
	intro_label.text = "READY"
	intro_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	intro_label.add_theme_font_size_override("font_size", 128)

	intro_label.anchor_left = 0.5
	intro_label.anchor_top = 0.5
	intro_label.anchor_right = 0.5
	intro_label.anchor_bottom = 0.5
	intro_label.offset_left = -200.0
	intro_label.offset_right = 200.0
	intro_label.offset_top = -150.0
	intro_label.offset_bottom = 50.0

	intro_label.modulate.a = 0.0

	intro_overlay.add_child(intro_label)

	var tween := create_tween()

	tween.tween_property(intro_label, "modulate:a", 1.0, 0.2)
	tween.tween_interval(0.3)
	tween.tween_property(intro_label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(_show_go_text)


func _show_go_text() -> void:
	if intro_label == null:
		return

	intro_label.text = "GO!!"
	intro_label.modulate.a = 0.0
	intro_label.add_theme_font_size_override("font_size", 128)

	var tween := create_tween()
	tween.tween_property(intro_label, "modulate:a", 1.0, 0.1)
	tween.tween_interval(0.3)
	tween.tween_property(intro_label, "modulate:a", 0.0, 0.3)
	tween.tween_callback(_on_intro_finished)


func _on_intro_finished() -> void:
	level_started = true
	_start_level()

	if intro_overlay != null:
		intro_overlay.queue_free()
		intro_overlay = null
		intro_label = null


func _start_level() -> void:
	audio_player.play()
	

var pause_menu_instance: Control = null


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause_menu()


func _toggle_pause_menu() -> void:
	if pause_menu_instance != null and is_instance_valid(pause_menu_instance):
		return

	_show_pause_menu()


func _show_pause_menu() -> void:
	if pause_menu_scene == null:
		push_warning("pause_menu_scene is niet ingesteld op SongPlayer.")
		return

	get_tree().paused = true

	pause_menu_instance = pause_menu_scene.instantiate() as Control
	if pause_menu_instance == null:
		push_warning("Kon pause_menu_scene niet instantieren.")
		get_tree().paused = false
		return

	var root := get_tree().root
	root.add_child(pause_menu_instance)
	root.move_child(pause_menu_instance, root.get_child_count() - 1)

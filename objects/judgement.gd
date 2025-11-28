extends Sprite2D

var accuracy: float = 0.0
var hits: int = 0               # aantal 300/100/50 (geen MISS)
var acc_score: int = 0          # totale score
var result: String = ""
var accuracy_display: float = 100.0
var accuracy_tween: Tween = null

var total_judgements: int = 0   # elke keypress OF auto-miss telt als judgement

# afzonderlijke tellers per judgement type
var perfect_count: int = 0
var great_count: int = 0
var good_count: int = 0
var ok_count: int = 0
var miss_count: int = 0

var combo: int = 0
var max_combo: int = 0
var max_possible_combo: int = 0	# wordt later van buitenaf gezet (bijv. door SongPlayer)

var combo_base_position: Vector2
var judgement_base_position: Vector2



@onready var judgement_label: Label = $JudgementLabel
@onready var accuracy_label: Label = $AccuracyLabel
@onready var combo_label: Label = $ComboLabel

# voor animatie van de judgement-tekst
var judgement_tween: Tween = null
# voor animatie van de combo-tekst
var combo_tween: Tween = null

# Lane → action mapping (van links naar rechts)
const LANE_ACTIONS: Array[String] = [
	"Left",  # lane 0
	"Down",  # lane 1
	"Up",  # lane 2
	"Right"   # lane 3
]

# Sleep hier in de inspector je 4 Keylistener sprites in, in volgorde van links naar rechts
@export var key_listener_paths: Array[NodePath]

var lane_hit_y: Array[float] = []  # per lane de Y-positie waarop je wilt hitten
var lane_hold_notes: Array[Sprite2D] = []  # per lane de long note die nu wordt vastgehouden


func _ready() -> void:
	_init_hit_lines()
	
	# long note hold-state per lane klaarzetten
	lane_hold_notes.resize(LANE_ACTIONS.size())
	for i in range(lane_hold_notes.size()):
		lane_hold_notes[i] = null
	
	combo_label.visible = false
	combo_label.text = "0x"
	combo_base_position = combo_label.position

	judgement_base_position = judgement_label.position



func _init_hit_lines() -> void:
	lane_hit_y.clear()

	for path in key_listener_paths:
		var sprite := get_node(path) as Sprite2D
		if sprite == null:
			push_warning("Keylistener niet gevonden voor pad: " + str(path))
		else:
			lane_hit_y.append(sprite.global_position.y)

	if lane_hit_y.is_empty():
		push_warning("Geen lane_hit_y ingesteld! Vul key_listener_paths in de Inspector.")

func _process(delta: float) -> void:
	_check_auto_misses()


func _input(event: InputEvent) -> void:
	for lane_idx in range(LANE_ACTIONS.size()):
		var action_name := LANE_ACTIONS[lane_idx]

		if event.is_action_pressed(action_name):
			handle_hit_for_lane(lane_idx)
			show_accuracy()
			show_judgement(result)
		elif event.is_action_released(action_name):
			_handle_release_for_lane(lane_idx)


func handle_hit_for_lane(lane_idx: int) -> void:
	# Elke keypress telt als judgement attempt
	total_judgements += 1

	if lane_idx < 0 or lane_idx >= lane_hit_y.size():
		result = "MISS"
		_on_miss()
		print("Judgement lane", lane_idx, "→ MISS (lane buiten bereik)")
		return

	var note := _find_closest_note_in_lane(lane_idx)
	if note == null:
		result = "MISS"
		_on_miss()
		print("Judgement lane", lane_idx, "→ MISS (geen note in lane)")
		return

	# afstand in pixels tussen note en HIT-LIJN (y van de keylistener voor deze lane)
	var hit_y: float = lane_hit_y[lane_idx]
	var dy: float = abs(note.global_position.y - hit_y)

	# tijdverschil = afstand / snelheid (in seconden)
	var scroll_velocity: float = note.scroll_velocity
	if scroll_velocity <= 0.0:
		result = "MISS"
		_on_miss()
		print("Judgement lane", lane_idx, "→ MISS (scroll_velocity <= 0)")
		return

	var time_diff: float = dy / scroll_velocity
	result = _apply_time_diff_and_update_stats(time_diff)

	var is_long: bool = note.is_in_group("long_notes")

	if is_long and note.has_method("mark_head_result"):
		note.mark_head_result(result)

	if result == "MISS":
		_on_miss()
	else:
		combo += 1
		if combo > max_combo:
			max_combo = combo
		_show_combo()

		if is_long:
			# head goed → vanaf nu moet je vasthouden tot de tail
			lane_hold_notes[lane_idx] = note
		else:
			# normale note
			note.queue_free()

	print("Judgement lane", lane_idx, "→", result, " time_diff=", time_diff)


	print("Judgement lane", lane_idx, "→", result, " time_diff=", time_diff)
	

func _handle_release_for_lane(lane_idx: int) -> void:
	if lane_idx < 0 or lane_idx >= lane_hold_notes.size():
		return

	var note := lane_hold_notes[lane_idx]
	if note == null:
		return
	if not note.is_inside_tree():
		lane_hold_notes[lane_idx] = null
		return
	if not note.is_in_group("long_notes"):
		lane_hold_notes[lane_idx] = null
		return
	if note.get("is_broken"):
		lane_hold_notes[lane_idx] = null
		return

	var hit_y: float = lane_hit_y[lane_idx]

	var tail_sprite := note.get_node_or_null("HoldEnd") as Sprite2D
	if tail_sprite == null:
		lane_hold_notes[lane_idx] = null
		return

	var dy: float = abs(tail_sprite.global_position.y - hit_y)
	var scroll_velocity: float = note.scroll_velocity
	if scroll_velocity <= 0.0:
		lane_hold_notes[lane_idx] = null
		return

	var time_diff: float = dy / scroll_velocity

	# elke release op een actieve long note = 1 judgement
	total_judgements += 1
	var tail_result := _apply_time_diff_and_update_stats(time_diff)

	if note.has_method("mark_tail_result"):
		note.mark_tail_result(tail_result)

	if tail_result == "MISS":
		_on_miss()
	else:
		combo += 1
		if combo > max_combo:
			max_combo = combo
		_show_combo()

	print("Tail release lane", lane_idx, "→", tail_result, " time_diff=", time_diff)
	show_accuracy()
	show_judgement(tail_result)

	# in alle gevallen is deze long note klaar voor deze lane
	lane_hold_notes[lane_idx] = null


func _find_closest_note_in_lane(lane_idx: int) -> Sprite2D:
	var best_note: Sprite2D = null
	var best_distance: float = INF

	for n in get_tree().get_nodes_in_group("notes"):
		var note := n as Sprite2D
		if note == null:
			continue

		# lane_index veilig uitlezen
		var note_lane = note.get("lane_index")
		if typeof(note_lane) != TYPE_INT or note_lane != lane_idx:
			continue

		var dy: float = abs(note.global_position.y - lane_hit_y[lane_idx])
		if dy < best_distance:
			best_distance = dy
			best_note = note

	return best_note

func _apply_time_diff_and_update_stats(time_diff: float) -> String:
	if time_diff <= 0.035:
		acc_score += 300
		hits += 1
		perfect_count += 1
		return "PERFECT"
	elif time_diff <= 0.076:
		acc_score += 250
		hits += 1
		great_count += 1
		return "GREAT"
	elif time_diff <= 0.106:
		acc_score += 150
		hits += 1
		good_count += 1
		return "GOOD"
	elif time_diff <= 0.127:
		acc_score += 75
		hits += 1
		ok_count += 1
		return "OK"
	else:
		miss_count += 1
		return "MISS"


func _check_auto_misses() -> void:
	# Auto-MISS voor notes die te laat zijn voor een 50
	var notes_to_miss: Array = []

	for n in get_tree().get_nodes_in_group("notes"):
		var note := n as Sprite2D
		if note.is_in_group("long_notes") and note.get("head_judged"):
			continue

		if note == null:
			continue

		var note_lane = note.get("lane_index")
		if typeof(note_lane) != TYPE_INT:
			continue

		var lane_idx: int = note_lane
		if lane_idx < 0 or lane_idx >= lane_hit_y.size():
			continue

		var hit_y: float = lane_hit_y[lane_idx]
		var scroll_velocity: float = note.scroll_velocity
		if scroll_velocity <= 0.0:
			continue

		# signed distance: positief = note is onder de hitlijn
		var dy_signed: float = note.global_position.y - hit_y
		var max_distance: float = scroll_velocity * 0.2  # zelfde 0.2s als 50-window

		# Als de note verder dan 50-window onder de hitlijn is → auto MISS
		if dy_signed > max_distance:
			notes_to_miss.append(note)

	for note in notes_to_miss:
		total_judgements += 1
		result = "MISS"
		miss_count += 1
		_on_miss()

		if note.is_in_group("long_notes") and note.has_method("mark_head_result"):
			note.mark_head_result("MISS")
		else:
			note.queue_free()

		show_accuracy()
		show_judgement(result)
		print("Auto-MISS voor lane", note.get("lane_index"))



func _on_miss() -> void:
	# eerst visueel de oude combo laten aftellen naar 0
	if combo > 0:
		_animate_combo_reset(combo)
	combo = 0



func show_accuracy() -> void:
	# herbereken de echte accuracy op basis van score en judgements
	if total_judgements > 0:
		accuracy = float(acc_score) / float(total_judgements * 300) * 100.0
	else:
		accuracy = 100.0

	# stop oude tween als die nog bezig is
	if accuracy_tween != null and accuracy_tween.is_running():
		accuracy_tween.kill()
		accuracy_tween = null

	# start nieuwe tween van huidige display-waarde naar echte accuracy
	var start_value := accuracy_display
	var end_value := accuracy

	accuracy_tween = get_tree().create_tween()
	accuracy_tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	accuracy_tween.tween_method(_update_accuracy_value, start_value, end_value, 0.25)

	accuracy_tween.finished.connect(func():
		accuracy_display = accuracy
		_update_accuracy_label_from_value(accuracy_display)
	)

func _update_accuracy_value(value: float) -> void:
	accuracy_display = value
	_update_accuracy_label_from_value(value)


func _update_accuracy_label_from_value(value: float) -> void:
	# Speciale case: EXACT 100%
	if abs(value - 100.0) < 0.0001:
		accuracy_label.text = "100%"
	else:
		accuracy_label.text = "%.2f%%" % value


func show_judgement(result: String) -> void:
	# stop vorige animatie als die nog bezig is
	if judgement_tween != null and judgement_tween.is_running():
		judgement_tween.kill()
		judgement_tween = null

	judgement_label.text = result

	match result:
		"PERFECT":
			judgement_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
		"GREAT":
			judgement_label.add_theme_color_override("font_color", Color(0.468, 0.989, 1.0, 1.0))
		"GOOD":
			judgement_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
		"OK":
			judgement_label.add_theme_color_override("font_color", Color(0.838, 0.0, 0.763, 1.0))
		"MISS":
			judgement_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))

	# begin altijd vanaf de basispositie
	judgement_label.position = judgement_base_position
	judgement_label.modulate.a = 1.0
	judgement_label.scale = Vector2.ONE   # voor de zekerheid weer normaal

	judgement_tween = get_tree().create_tween()
	judgement_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	var target_pos := judgement_base_position + Vector2(0, 6)

	# eerst 0.1s NIETS doen (label blijft gewoon staan en volledig zichtbaar)
	judgement_tween.tween_interval(0.1)

	# daarna in 0.25s: naar beneden bewegen...
	judgement_tween.tween_property(judgement_label, "position", target_pos, 0.5)
	# ...en tegelijk uitfaden
	judgement_tween.parallel().tween_property(judgement_label, "modulate:a", 0.0, 0.5)




func _show_combo() -> void:
	# combo tonen vanaf 1x (dus 1x, 2x, 3x, ...)
	if combo <= 0:
		combo_label.visible = false
		return

	combo_label.visible = true
	combo_label.text = str(combo) + "x"

	# stop eventuele vorige animatie (ook countdown)
	if combo_tween != null and combo_tween.is_running():
		combo_tween.kill()
		combo_tween = null

	# basisstaat
	combo_label.position = combo_base_position
	combo_label.scale = Vector2.ONE
	combo_label.modulate.a = 1.0

	# zachte pop naar rechts-boven
	combo_tween = get_tree().create_tween()
	combo_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# eerste stuk: klein beetje groter + iets naar rechts-boven
	combo_tween.tween_property(combo_label, "scale", Vector2(1.12, 1.12), 0.06)
	combo_tween.parallel().tween_property(combo_label, "position", combo_base_position + Vector2(4, -4), 0.06)

	# terug naar normaal en originele positie
	combo_tween.tween_property(combo_label, "scale", Vector2.ONE, 0.08)
	combo_tween.parallel().tween_property(combo_label, "position", combo_base_position, 0.08)


func _animate_combo_reset(start_combo: int) -> void:
	if start_combo <= 0:
		combo_label.visible = false
		return

	# stop eventuele vorige animatie
	if combo_tween != null and combo_tween.is_running():
		combo_tween.kill()
		combo_tween = null

	combo_label.visible = true
	combo_label.position = combo_base_position
	combo_label.scale = Vector2.ONE
	combo_label.modulate.a = 1.0

	combo_tween = get_tree().create_tween()
	combo_tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

	# laat het getal snel aftellen naar 0
	combo_tween.tween_method(_update_combo_label_value, float(start_combo), 0.0, 0.25)
	# en tegelijk wegfaden
	combo_tween.parallel().tween_property(combo_label, "modulate:a", 0.0, 0.25)

	combo_tween.finished.connect(func():
		combo_label.visible = false
	)


func _update_combo_label_value(value: float) -> void:
	var v := int(round(value))
	combo_label.text = str(v) + "x"

func set_ui_visible(visible: bool) -> void:
	# Pas deze paths aan naar jouw echte nodes
	if has_node("ComboLabel"):
		$ComboLabel.visible = visible
	if has_node("AccuracyLabel"):
		$AccuracyLabel.visible = visible
	if has_node("JudgementLabel"):
		$JudgementLabel.visible = visible

extends Control

@export var level_name: String = "" # Komt vanuit SongPlayer

@onready var title_label: Label = $Panel/VBoxContainer/Title
@onready var perfect_row: HBoxContainer = $Panel/VBoxContainer/PerfectRow
@onready var great_row: HBoxContainer = $Panel/VBoxContainer/GreatRow
@onready var good_row: HBoxContainer = $Panel/VBoxContainer/GoodRow
@onready var ok_row: HBoxContainer = $Panel/VBoxContainer/OkRow
@onready var miss_row: HBoxContainer = $Panel/VBoxContainer/MissRow
@onready var combo_row: HBoxContainer = $Panel/VBoxContainer/ComboRow
@onready var accuracy_label: Label = $AccuracyLabel
@onready var grade_image: TextureRect = $GradeImage

@onready var retry_button: Button = $RetryButton
@onready var back_button: Button = $BackButton

# Panel rechts voor beste scores:
@onready var best_scores_list: VBoxContainer = get_node_or_null("BestScoresPanel/ScoresList")


func _ready() -> void:
	_apply_colors()
	_start_intro_animation()
	
	retry_button.pressed.connect(_on_retry_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _apply_colors() -> void:
	title_label.add_theme_color_override("font_color", Color(1, 1, 1))

	var perfect_value: Label = perfect_row.get_node("Value")
	perfect_value.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	perfect_row.get_node("Label").add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))

	var great_value: Label = great_row.get_node("Value")
	great_value.add_theme_color_override("font_color", Color(0.468, 0.989, 1.0, 1.0))
	great_row.get_node("Label").add_theme_color_override("font_color", Color(0.468, 0.989, 1.0, 1.0))

	var good_value: Label = good_row.get_node("Value")
	good_value.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
	good_row.get_node("Label").add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))

	var ok_value: Label = ok_row.get_node("Value")
	ok_value.add_theme_color_override("font_color", Color(0.838, 0.0, 0.763, 1.0))
	ok_row.get_node("Label").add_theme_color_override("font_color", Color(0.838, 0.0, 0.763, 1.0))

	var miss_value: Label = miss_row.get_node("Value")
	miss_value.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	miss_row.get_node("Label").add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))

	var combo_value: Label = combo_row.get_node("Value")
	combo_value.add_theme_color_override("font_color", Color(1, 1, 1))
	combo_row.get_node("Label").add_theme_color_override("font_color", Color(1, 1, 1))
	accuracy_label.add_theme_color_override("font_color", Color(1, 1, 1))


func _start_intro_animation() -> void:
	var nodes: Array = [
		title_label,
		perfect_row,
		good_row,
		ok_row,
		miss_row,
		combo_row
	]

	var delay: float = 0.0
	var tween := create_tween()
	for node in nodes:
		var orig_pos: Vector2 = node.position
		node.position.x = orig_pos.x - 120.0
		node.modulate.a = 0.0

		var t1 = tween.parallel().tween_property(node, "position:x", orig_pos.x, 0.4)
		t1.set_delay(delay)
		var t2 = tween.parallel().tween_property(node, "modulate:a", 1.0, 0.4)
		t2.set_delay(delay)

		delay += 0.05

	var acc_orig: Vector2 = accuracy_label.position
	accuracy_label.position.x = acc_orig.x + 160.0
	accuracy_label.modulate.a = 0.0

	var t3 = tween.parallel().tween_property(accuracy_label, "position:x", acc_orig.x, 0.5)
	t3.set_delay(0.2)
	var t4 = tween.parallel().tween_property(accuracy_label, "modulate:a", 1.0, 0.5)
	t4.set_delay(0.2)

	var grade_orig: Vector2 = grade_image.position
	grade_image.position.y = grade_orig.y - 120.0
	grade_image.modulate.a = 0.0
	
	var t5 = tween.parallel().tween_property(grade_image, "position:y", grade_orig.y, 0.5)
	t5.set_delay(0.1)
	var t6 = tween.parallel().tween_property(grade_image, "modulate:a", 1.0, 0.5)
	t6.set_delay(0.1)


func _get_grade_letter(acc: float) -> String:
	if acc >= 100.0:
		return "X"
	elif acc >= 99.0:
		return "S+"
	elif acc >= 95.0:
		return "S"
	elif acc >= 90.0:
		return "A"
	elif acc >= 80.0:
		return "B"
	elif acc >= 72.7:
		return "C"
	else:
		return "D"

func _get_grade_color(grade: String) -> Color:
	if grade == "X":
		return Color(1.0, 1.0, 1.0, 1.0)
	elif grade == "S+":
		return Color(1.0, 0.95, 0.4)
	elif grade == "S":
		return Color(0.968, 0.971, 0.0, 1.0)
	elif grade == "A":
		return Color(0.3, 1.0, 0.3)
	elif grade == "B":
		return Color(0.468, 0.989, 1.0, 1.0)
	elif grade == "C":
		return Color(0.838, 0.0, 0.763, 1.0)
	else :
		return Color(1.0, 0.3, 0.3)
		

func _get_grade_icon_texture(grade: String) -> Texture2D:
	var img_path: String = ""

	match grade:
		"X":
			img_path = "res://Resources/art/X.png"
		"S+":
			img_path = "res://Resources/art/SS.png"
		"S":
			img_path = "res://Resources/art/S.png"
		"A":
			img_path = "res://Resources/art/A.png"
		"B":
			img_path = "res://Resources/art/B.png"
		"C":
			img_path = "res://Resources/art/C.png"
		"D":
			img_path = "res://Resources/art/D.png"
		_:
			img_path = ""

	if img_path != "" and ResourceLoader.exists(img_path):
		return ResourceLoader.load(img_path) as Texture2D

	return null

func _create_grade_icon_control(grade_str: String) -> Control:
	var tex: Texture2D = _get_grade_icon_texture(grade_str)
	var container: Control = Control.new()

	if tex == null:
		container.custom_minimum_size = Vector2(80, 80)
		return container

	var target_size: float = 80.0
	container.custom_minimum_size = Vector2(target_size, target_size)
	container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	container.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var icon: TextureRect = TextureRect.new()
	icon.texture = tex
	icon.stretch_mode = TextureRect.STRETCH_SCALE
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var tex_w: float = float(tex.get_width())
	var tex_h: float = float(tex.get_height())
	if tex_h <= 0.0:
		tex_h = 1.0

	# schaal zodat de texturehoogte ongeveer target_size wordt
	var scale_factor: float = target_size / tex_h
	icon.scale = Vector2(scale_factor, scale_factor)

	# bbox van niet-transparante pixels ophalen
	var offset_y: float = 0.0
	var img: Image = tex.get_image()
	if img != null:
		var used: Rect2i = img.get_used_rect()

		var tex_center_y: float = tex_h * 0.5
		var used_center_y: float = float(used.position.y) + float(used.size.y) * 0.5
		offset_y = (used_center_y - tex_center_y) * scale_factor

	var manual_offset_y: float = -10.0   # hoogte van grade aanpassen
	
	var center: Vector2 = Vector2(target_size * 0.5, target_size * 0.5)
	var icon_size: Vector2 = Vector2(tex_w * scale_factor, tex_h * scale_factor)

	icon.position = Vector2(
		center.x - icon_size.x * 0.5,
		center.y - icon_size.y * 0.5 - offset_y + manual_offset_y
	)

	container.add_child(icon)
	return container




func _update_grade(acc: float) -> void:
	var grade_letter: String = _get_grade_letter(acc)
	var img_path: String = ""

	match grade_letter:
		"X":
			img_path = "res://Resources/art/X.png"
		"S+":
			img_path = "res://Resources/art/SS.png"
		"S":
			img_path = "res://Resources/art/S.png"
		"A":
			img_path = "res://Resources/art/A.png"
		"B":
			img_path = "res://Resources/art/B.png"
		"C":
			img_path = "res://Resources/art/C.png"
		"D":
			img_path = "res://Resources/art/D.png"
		_:
			img_path = ""

	if img_path != "" and ResourceLoader.exists(img_path):
		var tex := ResourceLoader.load(img_path) as Texture2D
		grade_image.texture = tex
	else:
		push_warning("Grade image not found for grade: " + grade_letter + " (path: " + img_path + ")")


func set_results_from_judgement(judgement: Node) -> void:
	if judgement == null:
		return
	
	var acc: float = 0.0
	var perfect: int = 0
	var great: int = 0
	var good: int = 0
	var ok: int = 0
	var miss: int = 0
	var max_combo: int = 0
	var max_possible_combo: int = 0
	var avg_time_diff: int = 0
	
	acc = float(judgement.accuracy)
	perfect = int(judgement.perfect_count)
	great = int(judgement.great_count)
	good = int(judgement.good_count)
	ok = int(judgement.ok_count)
	miss = int(judgement.miss_count)
	max_combo = int(judgement.max_combo)
	max_possible_combo = int(judgement.max_possible_combo)
	avg_time_diff = int(judgement.average_time_diff)
	
	perfect_row.get_node("Value").text = str(perfect)
	great_row.get_node("Value").text = str(great)
	good_row.get_node("Value").text = str(good)
	ok_row.get_node("Value").text = str(ok)
	miss_row.get_node("Value").text = str(miss)
	combo_row.get_node("Value").text = "%d / %d" % [max_combo, max_possible_combo]
	
	accuracy_label.text = "%.2f%%" % acc

	_update_grade(acc)

	var grade_letter: String = _get_grade_letter(acc)

	_log_results_to_file(
		acc,
		grade_letter,
		perfect,
		great,
		good,
		ok,
		miss,
		max_combo,
		max_possible_combo
	)

	# Na loggen: beste scores inlezen en tonen
	_load_best_scores_panel()


func _log_results_to_file(
	acc: float,
	grade_letter: String,
	perfect: int,
	great: int,
	good: int,
	ok: int,
	miss: int,
	max_combo: int,
	max_possible_combo: int
) -> void:

	var lvl: String = level_name
	if lvl == "":
		var root: Node = get_tree().current_scene
		if root != null:
			lvl = root.name
		else:
			lvl = "UnknownLevel"

	var timestamp: String = Time.get_datetime_string_from_system(false, true)
	var safe_timestamp: String = timestamp.replace(":", "-")

	var exe_dir: String = OS.get_executable_path().get_base_dir()
	var logs_dir_path: String = exe_dir.path_join("logs")

	var err: int = DirAccess.make_dir_recursive_absolute(logs_dir_path)
	if err != OK and err != ERR_ALREADY_EXISTS:
		push_error("Kon logs directory niet aanmaken: %s" % err)
		return

	var filename: String = "result_%s_%s.txt" % [lvl, safe_timestamp]
	filename = filename.replace(" ", "_")
	var full_path: String = logs_dir_path.path_join(filename)

	var file: FileAccess = FileAccess.open(full_path, FileAccess.WRITE)
	if file == null:
		push_error("Kon logbestand niet schrijven: " + full_path)
		return

	var content: String = ""
	content += "Level: %s\n" % lvl
	content += "Timestamp: %s\n" % timestamp
	content += "Grade: %s\n" % grade_letter
	content += "\n"
	content += "Perfect: %d\n" % perfect
	content += "Great: %d\n" % great
	content += "Good: %d\n" % good
	content += "OK: %d\n" % ok
	content += "Miss: %d\n" % miss
	content += "Max Combo: %d / %d\n" % [max_combo, max_possible_combo]
	content += "Accuracy: %.2f%%\n" % acc

	file.store_string(content)
	file.close()

	print("Result log saved to: ", full_path)


func _load_best_scores_panel() -> void:
	if best_scores_list == null:
		return

	best_scores_list.add_theme_constant_override("separation", 6)

	# oude rows opruimen
	for child in best_scores_list.get_children():
		child.queue_free()

	# logs-map naast de .exe
	var exe_dir: String = OS.get_executable_path().get_base_dir()
	var logs_dir_path: String = exe_dir.path_join("logs")
	var dir: DirAccess = DirAccess.open(logs_dir_path)
	if dir == null:
		return

	var entries: Array = []

	dir.list_dir_begin()
	while true:
		var f: String = dir.get_next()
		if f == "":
			break
		if dir.current_is_dir():
			continue
		if not f.ends_with(".txt"):
			continue
		if not f.begins_with("result_"):
			continue

		var full_path: String = logs_dir_path.path_join(f)
		var parsed: Dictionary = _parse_log_file(full_path)
		if parsed.is_empty():
			continue

		# filter op level_name als die bekend is
		if level_name != "" and parsed.has("level") and parsed["level"] != level_name:
			continue

		entries.append(parsed)
	dir.list_dir_end()

	if entries.is_empty():
		return

	# sorteer op accuracy
	entries.sort_custom(func(a, b) -> bool:
		var acc_a: float = float(a["accuracy"])
		var acc_b: float = float(b["accuracy"])
		return acc_a > acc_b
	)

	var max_rows: int = min(5, entries.size())

	for i in range(max_rows):
		var e: Dictionary = entries[i]

		var grade_str: String = String(e.get("grade", "?"))
		var grade_color: Color = _get_grade_color(grade_str)

		var acc_val: float = float(e.get("accuracy", 0.0))
		var miss_val: int = int(e.get("miss", 0))

		var ts: String = String(e.get("timestamp", ""))
		var date_text: String = ts
		if ts.contains(" "):
			date_text = ts.split(" ")[0]

		
		var row: HBoxContainer = HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 100)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.alignment = BoxContainer.ALIGNMENT_BEGIN
		row.add_theme_constant_override("separation", 20)

		
		var text_box: VBoxContainer = VBoxContainer.new()
		text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_box.add_theme_constant_override("separation", 2)

		var line1: Label = Label.new()
		line1.text = "%d.  %s" % [i + 1, date_text]
		line1.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		line1.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		line1.add_theme_color_override("font_color", grade_color)

		var line2: Label = Label.new()
		line2.text = "Acc: %.2f%%" % acc_val
		line2.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		line2.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		line2.add_theme_color_override("font_color", grade_color)

		var line3: Label = Label.new()
		line3.text = "Miss: %d" % miss_val
		line3.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		line3.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		line3.add_theme_color_override("font_color", grade_color)

		text_box.add_child(line1)
		text_box.add_child(line2)
		text_box.add_child(line3)

		var icon_control: Control = _create_grade_icon_control(grade_str)

		row.add_child(text_box)
		row.add_child(icon_control)

		best_scores_list.add_child(row)






func _parse_log_file(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}

	var result: Dictionary = {}

	while file.get_position() < file.get_length():
		var line: String = file.get_line().strip_edges()

		if line.begins_with("Level:"):
			result["level"] = line.substr(7).strip_edges()
		elif line.begins_with("Timestamp:"):
			result["timestamp"] = line.substr(10).strip_edges()
		elif line.begins_with("Grade:"):
			result["grade"] = line.substr(7).strip_edges()
		elif line.begins_with("Miss:"):
			var miss_str: String = line.substr(5).strip_edges()
			result["miss"] = int(miss_str)
		elif line.begins_with("Accuracy:"):
			var acc_str: String = line.substr(9).strip_edges()
			acc_str = acc_str.replace("%", "")
			result["accuracy"] = float(acc_str)

	file.close()

	if not result.has("accuracy"):
		return {}

	return result



func set_level_name(name: String) -> void:
	level_name = name


func _on_retry_pressed() -> void:
	get_tree().paused = false
	var tree := get_tree()
	queue_free()
	tree.reload_current_scene()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

extends Control

@export var level_name: String = "" #Komt vanuit SongPlayer

@onready var title_label: Label = $Panel/VBoxContainer/Title
@onready var perfect_row: HBoxContainer = $Panel/VBoxContainer/PerfectRow
@onready var great_row: HBoxContainer = $Panel/VBoxContainer/GreatRow
@onready var good_row: HBoxContainer = $Panel/VBoxContainer/GoodRow
@onready var ok_row: HBoxContainer = $Panel/VBoxContainer/OkRow
@onready var miss_row: HBoxContainer = $Panel/VBoxContainer/MissRow
@onready var combo_row: HBoxContainer = $Panel/VBoxContainer/ComboRow
@onready var accuracy_label: Label = $AccuracyLabel
@onready var grade_image: TextureRect = $GradeImage

func _ready() -> void:
	_apply_colors()
	_start_intro_animation()

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

	# Slide-in van links voor de panel-items
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

	# Accuracy rechts onder slidet in van rechts
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
		return "SS"
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


func _update_grade(acc: float) -> void:
	var grade_letter: String = _get_grade_letter(acc)
	var img_path: String = ""

	match grade_letter:
		"X":
			img_path = "res://Resources/art/X.png"
		"SS":
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
	
	acc = float(judgement.accuracy)
	perfect = int(judgement.perfect_count)
	great = int(judgement.great_count)
	good = int(judgement.good_count)
	ok = int(judgement.ok_count)
	miss = int(judgement.miss_count)
	max_combo = int(judgement.max_combo)
	max_possible_combo = int(judgement.max_possible_combo)
	
	perfect_row.get_node("Value").text = str(perfect)
	great_row.get_node("Value").text = str(great)
	good_row.get_node("Value").text = str(good)
	ok_row.get_node("Value").text = str(ok)
	miss_row.get_node("Value").text = str(miss)
	combo_row.get_node("Value").text = "%d / %d" % [max_combo, max_possible_combo]
	
	accuracy_label.text = "%.2f%%" % acc

	_update_grade(acc)

	var grade_letter: String = _get_grade_letter(acc)

	# Resultaat loggen naar txt-bestand
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
	# Level-naam bepalen
	var lvl: String = level_name
	if lvl == "":
		var root := get_tree().current_scene
		if root != null:
			lvl = root.name
		else:
			lvl = "UnknownLevel"

	var timestamp: String = Time.get_datetime_string_from_system(false, true)
	var safe_timestamp: String = timestamp.replace(":", "-")

	var exe_dir: String = OS.get_executable_path().get_base_dir()

	var logs_dir_path: String = exe_dir.path_join("logs")

	# map (recursief) aanmaken als hij nog niet bestaat
	var err := DirAccess.make_dir_recursive_absolute(logs_dir_path)
	if err != OK and err != ERR_ALREADY_EXISTS:
		push_error("Kon logs directory niet aanmaken: %s" % err)
		return


	var filename: String = "result_%s_%s.txt" % [lvl, safe_timestamp]
	filename = filename.replace(" ", "_")
	var full_path: String = logs_dir_path.path_join(filename)

	var file := FileAccess.open(full_path, FileAccess.WRITE)
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


func set_level_name(name: String) -> void:
	level_name = name

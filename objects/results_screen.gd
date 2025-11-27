extends Control

@onready var title_label: Label = $Panel/VBoxContainer/Title
@onready var perfect_row: HBoxContainer = $Panel/VBoxContainer/PerfectRow
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
	# Titel wit
	title_label.add_theme_color_override("font_color", Color(1, 1, 1))

	# PERFECT groen
	var perfect_value: Label = perfect_row.get_node("Value")
	perfect_value.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
	perfect_row.get_node("Label").add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))

	# GOOD blauw
	var good_value: Label = good_row.get_node("Value")
	good_value.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
	good_row.get_node("Label").add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))

	# OK geel
	var ok_value: Label = ok_row.get_node("Value")
	ok_value.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	ok_row.get_node("Label").add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))

	# MISS rood
	var miss_value: Label = miss_row.get_node("Value")
	miss_value.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	miss_row.get_node("Label").add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))

	# Combo en accuracy wit
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

	# Grade slidet bijvoorbeeld van boven naar zijn plek
	var grade_orig: Vector2 = grade_image.position
	grade_image.position.y = grade_orig.y - 120.0
	grade_image.modulate.a = 0.0
	
	var t5 = tween.parallel().tween_property(grade_image, "position:y", grade_orig.y, 0.5)
	t5.set_delay(0.1)
	var t6 = tween.parallel().tween_property(grade_image, "modulate:a", 1.0, 0.5)
	t6.set_delay(0.1)

func _update_grade(acc: float) -> void:
	var img_path: String = ""
	
	if acc >= 100.0:
		img_path = "res://art/X.png"
	elif acc >= 99.0:
		img_path = "res://art/SS.png"	
	elif acc >= 95.0:
		img_path = "res://art/S.png"
	elif acc >= 90.0:
		img_path = "res://art/A.png"
	elif acc >= 85.0:
		img_path = "res://art/B.png"
	elif acc >= 80.0:
		img_path = "res://art/C.png"
	else:
		img_path = "res://art/D.png"
	
	if ResourceLoader.exists(img_path):
		var tex := ResourceLoader.load(img_path) as Texture2D
		grade_image.texture = tex
	else:
		push_warning("Grade image not found: " + img_path)


func set_results_from_judgement(judgement: Node) -> void:
	if judgement == null:
		return
	
	# expliciete types zodat Godot niet hoeft te infereren
	var acc: float = 0.0
	var perfect: int = 0
	var good: int = 0
	var ok: int = 0
	var miss: int = 0
	var max_combo: int = 0
	var max_possible_combo: int = 0
	
	# waarden uit de Judgement-node halen (runtime duck-typing)
	acc = float(judgement.accuracy)
	perfect = int(judgement.perfect_count)
	good = int(judgement.good_count)
	ok = int(judgement.ok_count)
	miss = int(judgement.miss_count)
	max_combo = int(judgement.max_combo)
	max_possible_combo = int(judgement.max_possible_combo)
	
	perfect_row.get_node("Value").text = str(perfect)
	good_row.get_node("Value").text = str(good)
	ok_row.get_node("Value").text = str(ok)
	miss_row.get_node("Value").text = str(miss)
	combo_row.get_node("Value").text = "%d / %d" % [max_combo, max_possible_combo]
	
	# Alleen percentage rechts onder tonen
	accuracy_label.text = "%.2f%%" % acc

	accuracy_label.text = "%.2f%%" % acc
	
	# Grade-image updaten op basis van accuracy
	_update_grade(acc)

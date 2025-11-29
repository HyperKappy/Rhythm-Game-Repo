extends Control

@export var label_paths: Array[NodePath] = []

var labels: Array[Label] = []
var flash_tween: Tween = null
var is_on: bool = false


func _ready() -> void:
	visible = false


	if label_paths.is_empty():
		for child in get_children():
			if child is Label:
				labels.append(child)
	else:
		for path in label_paths:
			var l := get_node_or_null(path) as Label
			if l != null:
				labels.append(l)

	if labels.is_empty():
		push_warning("WarningFlash: geen labels gevonden")
		return

	# Basisstaat
	for label in labels:
		if label.text.strip_edges() == "":
			label.text = "!"
		var c := label.modulate
		c.a = 0.0
		label.modulate = c


func _set_labels_on(on: bool) -> void:
	is_on = on
	for label in labels:
		var c := label.modulate
		c.a = 1.0 if on else 0.0
		label.modulate = c


func _blink_step() -> void:
	_set_labels_on(!is_on)


func start_flashing() -> void:
	if labels.is_empty():
		return

	visible = true

	if flash_tween != null and flash_tween.is_running():
		flash_tween.kill()
		flash_tween = null

	
	_set_labels_on(false)

	flash_tween = create_tween()
	flash_tween.set_loops()

	
	flash_tween.tween_callback(_blink_step)
	flash_tween.tween_interval(0.12)	# snelheid van knipperen


func stop_flashing() -> void:
	if flash_tween != null and flash_tween.is_running():
		flash_tween.kill()
	flash_tween = null

	_set_labels_on(false)
	visible = false

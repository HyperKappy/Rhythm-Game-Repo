extends HSlider

@export var value_label_path: NodePath

@onready var value_label: Label = get_node_or_null(value_label_path) as Label


func _ready() -> void:
	min_value = -100.0
	max_value = 100.0
	step = 1.0

	value = AudioSettings.get_offset_ms()
	_update_label()

func _process(delta: float) -> void:
	if value_label:
		global_position.y = value_label.global_position.y

func _on_value_changed(v: float) -> void:
	AudioSettings.set_offset_ms(v)
	_update_label()


func _update_label() -> void:
	if value_label == null:
		return

	var v := int(round(value))
	var prefix := ""
	if v >= 0:
		prefix = "+"

	value_label.text = "Audio Offset: %s%d ms" % [prefix, v]

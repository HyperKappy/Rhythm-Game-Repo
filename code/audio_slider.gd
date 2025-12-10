extends HSlider

@export var bus_name: String
@export var volume_label_path: NodePath

var bus_index: int
@onready var volume_label: Label = get_node(volume_label_path) as Label

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)

	min_value = 0.0
	max_value = 1.0
	step = 0.01

	var stored_volume := AudioSettings.get_master_volume_linear()

	value = stored_volume

	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(stored_volume)
	)

func _process(delta: float) -> void:
	if volume_label:
		global_position.y = volume_label.global_position.y

func _on_value_changed(v: float) -> void:
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(v)
	)

	AudioSettings.set_master_volume_linear(v)

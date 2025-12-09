extends Control

@onready var graphics_label: Label = $VBoxContainer/GraphicsRow/GraphicsLabel
@onready var low_button: Button = $VBoxContainer/GraphicsRow/GraphicsButtonRow/LowButton
@onready var high_button: Button = $VBoxContainer/GraphicsRow/GraphicsButtonRow/HighButton

var normal_size: int = 50
var selected_size: int = 60


func _ready() -> void:
	if low_button:
		normal_size = low_button.get_theme_font_size("font_size", "Button")
		selected_size = normal_size + 6

	_refresh_ui()


func _on_low_button_pressed() -> void:
	GraphicsSettings.apply_quality(GraphicsSettings.Quality.LOW)
	_refresh_ui()

func _on_high_button_pressed() -> void:
	GraphicsSettings.apply_quality(GraphicsSettings.Quality.HIGH)
	_refresh_ui()


func _refresh_ui() -> void:
	if graphics_label:
		graphics_label.text = "Graphics Quality"

	if low_button:
		low_button.add_theme_font_size_override("font_size", normal_size)
	if high_button:
		high_button.add_theme_font_size_override("font_size", normal_size)

	match GraphicsSettings.current_quality:
		GraphicsSettings.Quality.LOW:
			if low_button:
				low_button.add_theme_font_size_override("font_size", selected_size)
		GraphicsSettings.Quality.HIGH:
			if high_button:
				high_button.add_theme_font_size_override("font_size", selected_size)

extends Control

@export var main_menu_scene_path: String = "res://levels/main_menu.tscn"

@onready var continue_button: Button = $CanvasLayer/Panel/VBoxContainer/ContinueButton
@onready var retry_button: Button = $CanvasLayer/Panel/VBoxContainer/RetryButton
@onready var back_button: Button = $CanvasLayer/Panel/VBoxContainer/BackButton
@onready var blur_overlay: Control = $CanvasLayer/BlurOverlay

func _ready() -> void:
	if blur_overlay:
		blur_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

		if GraphicsSettings.current_quality == GraphicsSettings.Quality.LOW:
			blur_overlay.visible = false

	continue_button.pressed.connect(_on_continue_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	back_button.pressed.connect(_on_back_pressed)

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_continue_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
	queue_free()


func _on_retry_pressed() -> void:
	get_tree().paused = false
	queue_free()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().reload_current_scene()

func _on_back_pressed() -> void:
	get_tree().paused = false
	var tree := get_tree()
	queue_free()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if main_menu_scene_path != "":
		tree.change_scene_to_file(main_menu_scene_path)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_continue_pressed()

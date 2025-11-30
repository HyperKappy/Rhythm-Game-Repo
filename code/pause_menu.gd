extends Control

@export var main_menu_scene_path: String = "res://levels/main_menu.tscn"

@onready var continue_button: Button = $CanvasLayer/Panel/VBoxContainer/ContinueButton
@onready var retry_button: Button = $CanvasLayer/Panel/VBoxContainer/RetryButton

func _ready() -> void:

	if has_node("BlurOverlay"):
		var blur := $BlurOverlay
		blur.mouse_filter = Control.MOUSE_FILTER_IGNORE

	continue_button.pressed.connect(_on_continue_pressed)
	retry_button.pressed.connect(_on_retry_pressed)

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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_continue_pressed()

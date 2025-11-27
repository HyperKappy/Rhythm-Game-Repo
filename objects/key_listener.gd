extends Sprite2D

@export var lane_index: int = 0
@export var pressed_texture: Texture2D = preload("res://objects/falling_key.png")

var default_texture: Texture2D
var action_name: String = ""

const LANE_ACTIONS: Array[String] = [
	"Left",  # lane 0
	"Down",  # lane 1
	"Up",  # lane 2
	"Right"   # lane 3
]


func _ready() -> void:
	default_texture = texture

	if lane_index >= 0 and lane_index < LANE_ACTIONS.size():
		action_name = LANE_ACTIONS[lane_index]
	else:
		action_name = "button_d"  # fallback
		push_warning("lane_index buiten bereik, val terug op 'button_d'.")


func _input(event: InputEvent) -> void:
	if action_name == "":
		return

	if event.is_action_pressed(action_name):
		_on_pressed()
	elif event.is_action_released(action_name):
		_on_released()


func _on_pressed() -> void:
	if pressed_texture:
		texture = pressed_texture


func _on_released() -> void:
	if default_texture:
		texture = default_texture

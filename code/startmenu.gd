class_name Rebind
extends Control

@onready var label = $HBoxContainer/Label
@onready var button = $HBoxContainer/Button

@export var action_name : String = "Left"

func _ready():
	set_process_unhandled_key_input(false)
	set_action_name()
	set_text_for_key()

func set_action_name() -> void:
	label.text = "Unassigned"
	
	match action_name:
		"Left":
			label.text = "Left"
		"Down":
			label.text = "Down"
		"Up":
			label.text = "Up"
		"Right":
			label.text = "Right"

func set_text_for_key() -> void:
	var action_events = InputMap.action_get_events(action_name)
	var action_event = action_events[0]
	var action_keycode = OS.get_keycode_string(action_event.physical_keycode)
	
	print(action_keycode)
	button.text = "%s" % action_keycode

func _on_button_toggled(button_pressed) -> void:
	if button_pressed:
		button.text = "Druk op de gewenste knop.."
		set_process_unhandled_key_input(button_pressed)
		
		for i in get_tree().get_nodes_in_group("Hotkey_Button"):
			var rebinder = i.get_parent()  # <-- Fix Option 3 applied
			if rebinder is Rebind and rebinder.action_name != self.action_name:
				rebinder.button.toggle_mode = false
				rebinder.set_process_unhandled_key_input(false)
	else:
		set_text_for_key()
		
func _unhandled_key_input(event):
	rebind_action_key(event)
	button.button_pressed = false

func rebind_action_key(event) -> void:
	# FIX 1: Erase ALL old events properly
	for old_event in InputMap.action_get_events(action_name):
		InputMap.action_erase_event(action_name, old_event)

	# FIX 2: "action" → "action_name"
	InputMap.action_add_event(action_name, event)
	
	set_process_unhandled_key_input(false)
	set_text_for_key()
	set_action_name()

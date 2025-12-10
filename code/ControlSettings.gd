extends Node

const CONFIG_PATH := "user://input_settings.cfg"
const SECTION_INPUT := "input"

func _ready() -> void:
	load_all_actions()

func save_action(action_name: String) -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(CONFIG_PATH)

	var events := InputMap.action_get_events(action_name)
	if events.size() == 0:
		return

	var ev = events[0]

	if ev is InputEventKey:
		var key_event := ev as InputEventKey
		var data := {
			"physical_keycode": key_event.physical_keycode,
			"keycode": key_event.keycode
		}
		cfg.set_value(SECTION_INPUT, action_name, data)
		cfg.save(CONFIG_PATH)

func load_all_actions() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(CONFIG_PATH)
	if err != OK:
		return

	if not cfg.has_section(SECTION_INPUT):
		return

	for action_name in cfg.get_section_keys(SECTION_INPUT):
		var data = cfg.get_value(SECTION_INPUT, action_name, null)
		if typeof(data) != TYPE_DICTIONARY:
			continue

		var ev := InputEventKey.new()
		if data.has("physical_keycode"):
			ev.physical_keycode = int(data["physical_keycode"])
		elif data.has("keycode"):
			ev.keycode = int(data["keycode"])

		InputMap.action_erase_events(action_name)
		InputMap.action_add_event(action_name, ev)

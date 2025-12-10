extends Node

const CONFIG_PATH := "user://audio_settings.cfg"
const CONFIG_SECTION := "audio"
const CONFIG_KEY_OFFSET := "global_offset_ms"

# Positief = audio eerder, negatief = audio later
static var global_offset_ms: float = 0.0


func _ready() -> void:
	load_settings()


static func load_settings() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(CONFIG_PATH)
	if err != OK:
		return

	global_offset_ms = float(cfg.get_value(CONFIG_SECTION, CONFIG_KEY_OFFSET, 0.0))


static func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(CONFIG_SECTION, CONFIG_KEY_OFFSET, global_offset_ms)
	cfg.save(CONFIG_PATH)


static func set_offset_ms(value: float) -> void:
	global_offset_ms = value
	save_settings()


static func get_offset_ms() -> float:
	return global_offset_ms

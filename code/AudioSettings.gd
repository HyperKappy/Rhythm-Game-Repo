extends Node

const CONFIG_PATH := "user://audio_settings.cfg"
const CONFIG_SECTION_AUDIO := "audio"
const KEY_OFFSET := "global_offset_ms"
const KEY_MASTER_VOLUME := "master_volume_linear"   # 0.0 – 1.0

# Globale waardes
static var global_offset_ms: float = 0.0
static var master_volume_linear: float = 0.5

func _ready() -> void:
	load_settings()

static func load_settings() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(CONFIG_PATH)
	if err != OK:
		return

	global_offset_ms = float(cfg.get_value(CONFIG_SECTION_AUDIO, KEY_OFFSET, 0.0))
	master_volume_linear = float(cfg.get_value(CONFIG_SECTION_AUDIO, KEY_MASTER_VOLUME, 1.0))

static func save_settings() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(CONFIG_PATH)

	cfg.set_value(CONFIG_SECTION_AUDIO, KEY_OFFSET, global_offset_ms)
	cfg.set_value(CONFIG_SECTION_AUDIO, KEY_MASTER_VOLUME, master_volume_linear)

	cfg.save(CONFIG_PATH)

static func set_offset_ms(value: float) -> void:
	global_offset_ms = value
	save_settings()

static func get_offset_ms() -> float:
	return global_offset_ms

static func set_master_volume_linear(value: float) -> void:
	master_volume_linear = clamp(value, 0.0, 1.0)
	save_settings()

static func get_master_volume_linear() -> float:
	return master_volume_linear

extends Node

enum Quality { LOW, HIGH }

var current_quality: Quality = Quality.HIGH
var base_resolution: Vector2i

const CONFIG_PATH := "user://graphics_settings.cfg"
const CONFIG_SECTION := "graphics"
const CONFIG_KEY_QUALITY := "quality"


func _ready() -> void:
	base_resolution = DisplayServer.window_get_size()
	_load_quality()


func apply_quality(quality: Quality) -> void:
	current_quality = quality

	match quality:
		Quality.HIGH:
			#_apply_scale(1.0)
			_apply_msaa(RenderingServer.VIEWPORT_MSAA_2X)
			_apply_filtering(true)

		Quality.LOW:
			#_apply_scale(0.65)
			_apply_msaa(RenderingServer.VIEWPORT_MSAA_DISABLED)
			_apply_filtering(false)

	_save_quality()


func _apply_scale(scale: float) -> void:
	#var root := get_tree().root
	#root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	#root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	#root.content_scale_factor = scale
	pass


func _apply_msaa(msaa_level: int) -> void:
	var root := get_tree().root
	var rid := root.get_viewport_rid()
	RenderingServer.viewport_set_msaa_2d(rid, msaa_level)


func _apply_filtering(enable: bool) -> void:
	ProjectSettings.set_setting("rendering/textures/default_filters", enable)


func _save_quality() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(CONFIG_SECTION, CONFIG_KEY_QUALITY, current_quality)
	cfg.save(CONFIG_PATH)


func _load_quality() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(CONFIG_PATH)
	if err != OK:
		return

	var stored_quality: int = int(cfg.get_value(CONFIG_SECTION, CONFIG_KEY_QUALITY, Quality.HIGH))

	if stored_quality >= Quality.LOW and stored_quality <= Quality.HIGH:
		apply_quality(stored_quality)

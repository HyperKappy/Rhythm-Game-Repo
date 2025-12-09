extends ColorRect

var blur_speed := 1
var max_blur := 3

func _process(delta):
	if GraphicsSettings.current_quality == GraphicsSettings.Quality.LOW:
		visible = false
		return
		
	if !is_visible_in_tree():
		return

	var mat := material as ShaderMaterial
	var blur = mat.get_shader_parameter("blur_radius")
	blur += 8.5 * delta
	mat.set_shader_parameter("blur_radius", blur)

shader_type canvas_item;

uniform float blur_radius = 0.0;
uniform int sample_count = 2;
uniform float darken = 0.3;

uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 col = vec4(0.0);
	float total = 0.0;


	for (int i = -sample_count; i <= sample_count; i++) {
		for (int j = -sample_count; j <= sample_count; j++) {
			vec2 offset_pixels = vec2(float(i), float(j)) * blur_radius;
			vec2 offset_uv = offset_pixels * SCREEN_PIXEL_SIZE; // 🔹 Godot 4 manier
			col += texture(screen_texture, uv + offset_uv);
			total += 1.0;
		}
	}

	col /= max(total, 1.0);


	vec3 darkened = col.rgb * (1.0 - darken);

	COLOR = vec4(darkened, 1.0);
}

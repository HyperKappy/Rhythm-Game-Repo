shader_type canvas_item;

uniform float alpha_cutoff = 0.9;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float brightness = (tex.r + tex.g + tex.b) / 3.0;

	// alles dat (bijna) zwart is → transparant
	if (brightness <= alpha_cutoff) {
		discard;
	}

	// teken de witte vorm volledig opaak (maar met je modulate kleur)
	COLOR = vec4(tex.rgb, 1.0) * COLOR;
}

shader_type canvas_item;

uniform sampler2D dither_tex : filter_nearest, repeat_enable;
uniform float exposure : hint_range(0.0, 2.0) = 1.0;
uniform float contrast : hint_range(0.0, 4.0) = 1.0;
uniform float steps : hint_range(0.0, 8.0, 1.0) = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

float quantize(float value, float _steps) {
	return floor(value * _steps) / _steps;
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	//COLOR *= exposure;
	float dither_bias = texture(dither_tex, UV / TEXTURE_PIXEL_SIZE / 16.0).r * 2.0 - 1.0;
	vec3 color = COLOR.rgb * exposure;
	color = vec3(
		pow(color.r, contrast),
		pow(color.g, contrast),
		pow(color.b, contrast)
	);
	COLOR = vec4(vec3(
		quantize(color.r + dither_bias / 2.0, steps),
		quantize(color.g + dither_bias / 2.0, steps),
		quantize(color.b + dither_bias / 2.0, steps)
	), 1);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

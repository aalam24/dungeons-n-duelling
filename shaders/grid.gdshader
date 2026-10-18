shader_type spatial;

uniform float cell_size = 1.5;
uniform float line_width = 0.03;
uniform vec4 ground_color : source_color = vec4(0.26, 0.33, 0.22, 1.0);
uniform vec4 line_color : source_color = vec4(0.0, 0.0, 0.0, 0.35);

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 d = abs(fract(world_pos.xz / cell_size - 0.5) - 0.5) * cell_size;
	float line = 1.0 - smoothstep(0.0, line_width, min(d.x, d.y));
	ALBEDO = mix(ground_color.rgb, line_color.rgb, line * line_color.a);
}
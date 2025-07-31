shader_type spatial;
render_mode unshaded, cull_back;

uniform sampler2D gradient_main;
uniform float star_density = 0.996;
uniform int star_layers = 4;
uniform float star_size = 40.0;
uniform float star_shine = 1.2;
uniform float flicker_speed = 6.0;
uniform float flicker_intensity = 0.3;
uniform float transparency_star : hint_range(0.0, 1.0) = 0.1;

uniform float seed = 0.0;
uniform vec4 ocean_color : source_color = vec4(0.02, 0.01, 0.06, 1.0);

float rand(vec2 st) {
	return fract(sin(dot(st.xy, vec2(12.9898 + seed, 78.233))) * 43758.5453);
}

float remap(float low, float high, float value) {
	return clamp((value - low) / (high - low), 0.0, 1.0);
}

void vertex() {
	// Pas de mouvement, surface figée
}

void fragment() {
	vec2 uv = UV;
	vec3 final_color = ocean_color.rgb;

	vec2 coord = uv;

	for (int i = 1; i <= star_layers; i++) {
		float layer_size = star_size / float(i);
		vec2 grid = floor(coord * layer_size);
		float star_val = rand(grid);

		if (star_val > star_density) {
			vec2 center = grid / layer_size + vec2(0.5 / layer_size);
			float dist = distance(coord, center);

			float base_shine = max(0.0, 1.0 - dist * layer_size);
			float flicker = 1.0 + flicker_intensity * sin(TIME * flicker_speed + star_val * 30.0);
			float intensity = base_shine * base_shine * star_shine * flicker / float(i);

			vec4 col = texture(gradient_main, vec2(remap(star_density, 1.0, star_val), 0.5));
			final_color += col.rgb * intensity * (1.0 - transparency_star);
		}
	}

	ALBEDO = final_color;
	EMISSION = final_color;
}

shader_type spatial;

uniform int line_count : hint_range(1, 20) = 1;
uniform float line_spacing : hint_range(0.0, 1.0) = 0.3;
uniform float line_thickness : hint_range(0.005, 0.2) = 0.05;
uniform vec4 line_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 road_color : source_color = vec4(0.1, 0.1, 0.1, 1.0);
uniform float noise_scale : hint_range(0.1, 10.0) = 3.0;
uniform float line_repeat : hint_range(1.0, 50.0) = 10.0;
uniform bool dash_enabled = true;
uniform float dash_length : hint_range(0.01, 0.5) = 0.1;
uniform float gap_length : hint_range(0.01, 0.5) = 0.1;
uniform float edge_fade : hint_range(0.0, 0.5) = 0.1;

// émission
uniform float emission_strength : hint_range(0.0, 5.0) = 1.0; // intensité globale
uniform vec4 emission_color : source_color = vec4(1.0, 1.0, 0.8, 1.0); // couleur de l’émission des lignes
uniform float road_emission_factor : hint_range(0.0, 1.0) = 0.0; // si tu veux que la route émette un peu

float hash(vec2 p){
	return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453123);
}

float noise(vec2 p){
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float dash_pattern(float coord){
	if (!dash_enabled) {
		return 1.0;
	}
	float cycle = dash_length + gap_length;
	float m = mod(coord, cycle);
	return step(0.0, dash_length - m);
}

void fragment(){
	vec2 uv = UV;

	// base bruitée de la route
	float n = noise(uv * noise_scale * vec2(1.0, 0.1));
	vec3 base = road_color.rgb * (0.8 + 0.2 * n);

	// ligne(s)
	float line_layer = 0.0;
	float half = float(line_count - 1) * 0.5;
	for (int i = 0; i < 8; ++i){
		if (i >= line_count) { break; }
		float offset_index = float(i) - half;
		float line_pos = 0.5 + offset_index * line_spacing;
		float center_dist = abs(uv.y - line_pos);
		float line_core = smoothstep(line_thickness * 0.5 + 0.001, 0.0, center_dist);
		float long_coord = fract(uv.x * line_repeat);
		float dash = dash_pattern(long_coord * (dash_length + gap_length));
		float contribution = line_core * dash;
		line_layer = max(line_layer, contribution);
	}

	// couleur finale de surface avant émission
	vec3 final_color = base;
	final_color = mix(final_color, line_color.rgb, line_layer);

	// fondu bords
	float edge = smoothstep(0.0, edge_fade, min(uv.y, 1.0 - uv.y));
	final_color *= edge;

	ALBEDO = final_color;
	ROUGHNESS = 1.0;
	METALLIC = 0.0;

	// émission : lignes + (optionnel) route
	vec3 emit_line = emission_color.rgb * line_layer;
	vec3 emit_road = road_color.rgb * road_emission_factor * 0.2; // faiblement selon le facteur
	EMISSION = (emit_line + emit_road) * emission_strength;
}

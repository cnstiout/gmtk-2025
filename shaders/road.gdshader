shader_type spatial;

uniform int line_count : hint_range(1, 8) = 1;
uniform float line_spacing : hint_range(0.0, 1.0) = 0.3;
uniform float line_thickness : hint_range(0.005, 0.2) = 0.05;
uniform vec4 line_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);

// --- nouvelle texture de route et teinte ---
uniform sampler2D road_texture; // texture RGBA, alpha = transparence
uniform vec4 road_tint : source_color = vec4(0.1, 0.1, 0.1, 1.0); // couleur modulante

uniform float noise_scale : hint_range(0.1, 10.0) = 3.0;
uniform float line_repeat : hint_range(1.0, 50.0) = 10.0;
uniform bool dash_enabled = true;
uniform float dash_length : hint_range(0.01, 0.5) = 0.1;
uniform float gap_length : hint_range(0.01, 0.5) = 0.1;
uniform float edge_fade : hint_range(0.0, 0.5) = 0.1;

uniform float emission_strength : hint_range(0.0, 5.0) = 1.0;
uniform vec4 emission_color : source_color = vec4(1.0, 1.0, 0.8, 1.0);
uniform float road_emission_factor : hint_range(0.0, 1.0) = 0.0;

uniform float line_offset_long : hint_range(0.0, 1.0) = 0.0;
uniform float line_offset_cross : hint_range(-1.0, 1.0) = 0.0;

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
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float smooth_dash(float coord, float cycle, float dash_len){
    if (!dash_enabled) return 1.0;
    float m = mod(coord, cycle);
    float fw = fwidth(m);
    float edge0 = dash_len - 0.5 * fw;
    float edge1 = dash_len + 0.5 * fw;
    return smoothstep(edge1, edge0, m);
}

void fragment(){
    vec2 uv = UV;
    uv.x = fract(uv.x + line_offset_long);
    uv.y = clamp(uv.y + line_offset_cross, 0.0, 1.0);

    // base de route bruitée
    float n = noise(uv * noise_scale * vec2(1.0, 0.1));
    vec3 procedural_base = vec3(0.0);
    procedural_base = (0.8 + 0.2 * n) * road_tint.rgb; // teinte de base + bruit

    // échantillonnage de la texture de route
    vec4 tex = texture(road_texture, uv);
    // moduler la couleur de la texture par la teinte (comme un tint)
    vec3 textured = tex.rgb * road_tint.rgb;
    float texture_alpha = tex.a;

    // combiner base procédurale et texture : la texture se superpose avec son alpha
    vec3 base = mix(procedural_base, textured, texture_alpha);

    // lignes
    int effective_count = clamp(line_count, 1, 8);
    float half = float(effective_count - 1) * 0.5;
    float cycle = dash_length + gap_length;
    float repeat_uv = uv.x * line_repeat;

    float line_layer = 0.0;
    for (int i = 0; i < 8; ++i){
        if (i >= effective_count) break;
        float offset_index = float(i) - half;
        float line_pos = 0.5 + offset_index * line_spacing;
        float center_dist = abs(uv.y - line_pos);
        float core_threshold = max(line_thickness * 0.5, 0.001);
        float line_core = smoothstep(core_threshold + 0.001, 0.0, center_dist);

        float long_coord = fract(repeat_uv);
        float dash = smooth_dash(long_coord * cycle, cycle, dash_length);
        float contribution = line_core * dash;
        line_layer = max(line_layer, contribution);
    }

    vec3 final_color = base;
    final_color = mix(final_color, line_color.rgb, line_layer);

    // fondu en bordure
    float ef = max(edge_fade, 1e-5);
    float edge = smoothstep(0.0, ef, min(uv.y, 1.0 - uv.y));
    final_color *= edge;

    ALBEDO = final_color;
    ROUGHNESS = 1.0;
    METALLIC = 0.0;

    vec3 emit_line = emission_color.rgb * line_layer;
    vec3 emit_road = road_tint.rgb * road_emission_factor * 0.2;
    EMISSION = (emit_line + emit_road) * emission_strength;
}

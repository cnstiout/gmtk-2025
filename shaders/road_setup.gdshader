shader_type spatial;

// === Contrôles généraux ===
uniform int line_count : hint_range(1, 8) = 5;
uniform float line_spacing : hint_range(0.0, 1.0) = 0.024;
uniform float line_thickness : hint_range(0.005, 0.2) = 0.015;

// Couleurs par ligne
uniform vec4 line_color_0 : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 line_color_1 : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 line_color_2 : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 line_color_3 : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 line_color_4 : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 line_color_5 : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 line_color_6 : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 line_color_7 : source_color = vec4(1.0, 1.0, 0.0, 1.0);

// === Texture de route + teinte + alpha global + tiling/aspect ===
uniform sampler2D road_texture;
uniform vec4 road_tint : source_color = vec4(0.1, 0.1, 0.1, 1.0);
uniform float base_alpha : hint_range(0.0, 1.0) = 1.0;
uniform vec2 road_uv_scale = vec2(1.0, 48.0);
uniform vec2 mesh_scale = vec2(1.0, 1.0);

// === Lignes, dash, bruit, bord ===
uniform float noise_scale : hint_range(0.1, 10.0) = 3.0;
uniform float line_repeat : hint_range(1.0, 50.0) = 10.0;
uniform bool dash_enabled = true;
uniform float dash_length : hint_range(0.01, 0.5) = 0.01;
uniform float gap_length : hint_range(0.01, 0.5) = 0.5;
uniform float edge_fade : hint_range(0.0, 0.5) = 0.5;

// === Émission ===
uniform float emission_strength : hint_range(0.0, 5.0) = 5.0;
uniform float road_emission_factor : hint_range(0.0, 1.0) = 0.0;
// Option : contrôler si on normalise par la plus forte contribution ou la somme
uniform bool blend_line_emission = true; // true = moyenne perceptuelle (sum), false = dominant (max)

// === Offsets ===
uniform float line_offset_long : hint_range(0.0, 1.0) = 0.0;
uniform float line_offset_cross : hint_range(-1.0, 1.0) = 0.438;

// === Options supplémentaires ===
uniform bool use_nearest_sampling = true;

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

float compute_dash(float coord, float cycle, float dash_len){
    if (!dash_enabled) return 1.0;
    float m = mod(coord, cycle);
    // Utiliser la dérivée avant wrap pour éviter les discontinuités visibles
    float fw = fwidth(coord);
    float edge0 = dash_len - 0.5 * fw;
    float edge1 = dash_len + 0.5 * fw;
    return smoothstep(edge1, edge0, m);
}

vec3 get_line_color(int i) {
    vec4 colors[8] = vec4[8](
        line_color_0, line_color_1, line_color_2, line_color_3,
        line_color_4, line_color_5, line_color_6, line_color_7
    );
    return colors[i].rgb;
}

void fragment(){
    vec2 uv = UV;
    uv.x = fract(uv.x + line_offset_long);
    uv.y = clamp(uv.y + line_offset_cross, 0.0, 1.0);

    // Bruit procédural pour base
    float n = noise(uv * noise_scale * vec2(1.0, 0.1));
    vec3 procedural_base = (0.8 + 0.2 * n) * road_tint.rgb;

    // Correction d'aspect avec sécurité contre zéro/négatif
    vec2 safe_mesh = max(abs(mesh_scale), vec2(0.0001));
    vec2 aspect_corrected_uv = uv * vec2(safe_mesh.y / safe_mesh.x, 1.0);
    vec2 scaled_uv = fract(aspect_corrected_uv * road_uv_scale);

    // Échantillonnage de la texture
    vec4 tex;
    if (use_nearest_sampling) {
        ivec2 tex_size_i = textureSize(road_texture, 0);
        vec2 tex_size = vec2(tex_size_i);
        vec2 nearest_uv = floor(scaled_uv * tex_size + 0.5) / tex_size;
        tex = texture(road_texture, nearest_uv);
    } else {
        tex = texture(road_texture, scaled_uv);
    }
    vec3 textured = tex.rgb * road_tint.rgb;
    float texture_alpha = tex.a;

    vec3 base = mix(procedural_base, textured, texture_alpha);

    int eff_count = clamp(line_count, 1, 8);
    float half = float(eff_count - 1) * 0.5;
    float cycle = dash_length + gap_length;
    float repeat_uv = uv.x * line_repeat;

    vec3 accumulated_line = vec3(0.0);
    float max_line_layer = 0.0;
    float sum_contribution = 0.0;

    // Pour émission individuelle
    vec3 accumulated_line_emission = vec3(0.0);

    for (int i = 0; i < eff_count; ++i){
        float offset_index = float(i) - half;
        float line_pos = 0.5 + offset_index * line_spacing;
        float center_dist = abs(uv.y - line_pos);
        float core_threshold = max(line_thickness * 0.5, 0.001);
        float line_core = smoothstep(core_threshold + 0.001, 0.0, center_dist);

        float dash = compute_dash(repeat_uv, cycle, dash_length);
        float contribution = line_core * dash;

        vec3 line_col = get_line_color(i);

        accumulated_line += line_col * contribution;
        accumulated_line_emission += line_col * contribution;
        max_line_layer = max(max_line_layer, contribution);
        sum_contribution += contribution;
    }

    // Choix de normalisation pour couleur de ligne affichée
    vec3 line_final;
    if (sum_contribution > 0.0) {
        line_final = blend_line_emission
            ? (accumulated_line / sum_contribution)    // mélange perceptuel
            : (accumulated_line / max(0.0001, max_line_layer)); // dominante
    } else {
        line_final = vec3(0.0);
    }

    float blend_factor = max_line_layer;
    vec3 final_color = mix(base, line_final, blend_factor);

    // Fade sur les bords
    float edge = (edge_fade <= 0.0)
        ? 1.0
        : smoothstep(0.0, edge_fade, min(uv.y, 1.0 - uv.y));
    final_color *= edge;

    ALBEDO = final_color;
    ROUGHNESS = 1.0;
    METALLIC = 0.0;

    // Émission : lignes avec leur couleur propre + route
    vec3 line_emission_final;
    if (blend_line_emission) {
        line_emission_final = (sum_contribution > 0.0)
            ? (accumulated_line_emission / sum_contribution)
            : vec3(0.0);
    } else {
        line_emission_final = (max_line_layer > 0.0)
            ? (accumulated_line_emission / max_line_layer)
            : vec3(0.0);
    }

    vec3 emit_road = road_tint.rgb * road_emission_factor * 0.2;
    EMISSION = (line_emission_final + emit_road) * emission_strength;

    float out_alpha = texture_alpha * base_alpha * edge;
    ALPHA = out_alpha;
}

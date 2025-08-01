shader_type spatial;
render_mode unshaded, blend_add, cull_back;


uniform sampler2D ribbon_texture ;

uniform vec3 base_color = vec3(0.2, 0.8, 1.0);
uniform float ribbon_width : hint_range(0.01, 1.0, 0.01) = 0.25;
uniform float scroll_speed : hint_range(0.0, 5.0, 0.01) = 1.2;
uniform float edge_softness : hint_range(0.0, 1.0, 0.01) = 0.2;
uniform float fresnel_power : hint_range(0.1, 8.0, 0.1) = 2.5;
uniform float emission_strength : hint_range(0.0, 10.0, 0.1) = 4.0;
uniform float pulse_speed : hint_range(0.1, 5.0, 0.01) = 1.5;
uniform float scanline_intensity : hint_range(0.0, 1.0, 0.01) = 0.25;
uniform float scanline_density : hint_range(5.0, 100.0, 1.0) = 50.0;
uniform float noise_amount : hint_range(0.0, 1.0, 0.01) = 0.12;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
    vec2 uv = UV;

    // Défilement de gauche à droite
    float scroll = TIME * scroll_speed;
    float center_pos = fract(uv.x + scroll);

    // Masque ruban (avec adoucissement)
    float dist = abs(fract(uv.x + scroll) - 0.5) * 2.0;
    float mask = smoothstep(ribbon_width + edge_softness, ribbon_width - edge_softness, dist);

    // Détail texturé + pulsation verticale
    vec2 detail_uv = vec2(uv.x + scroll * 0.6, uv.y * 2.0 + sin(TIME * pulse_speed) * 0.04);
    vec4 detail = texture(ribbon_texture, detail_uv);

    // Teinte dynamique (léger shift)
    float hue_shift = sin(TIME * 0.6) * 0.1;
    vec3 holo_color = base_color + vec3(hue_shift, -hue_shift * 0.5, hue_shift * 0.3);
    holo_color = clamp(holo_color, 0.0, 1.0);

    // Fresnel pour lueur de bord
    float fresnel = pow(1.0 - abs(dot(NORMAL, VIEW)), fresnel_power);

    // Bruit / flicker
    float n = noise(uv * 12.0 + TIME * 0.5);
    float flicker = mix(0.85, 1.05, n) * (0.8 + 0.2 * sin(TIME * 7.0));

    // Scanline horizontale
    float scan = sin(uv.y * scanline_density + TIME * 6.5);
    float scan_mod = mix(1.0, scan * 0.5 + 0.5, scanline_intensity);

    // Composition couleur
    vec3 ribbon_rgb = holo_color * detail.rgb;
    ribbon_rgb *= mask;
    ribbon_rgb *= flicker;
    ribbon_rgb *= scan_mod;

    // Emission avec accent sur les bords
    vec3 emission = ribbon_rgb * (0.5 + fresnel * 0.5) * emission_strength;

    // Halo externe léger
    float edge_glow = smoothstep(0.0, 1.0, fresnel) * 0.25 * (1.0 - mask);
    emission += base_color * edge_glow * emission_strength * 0.4;

    // Alpha pour transparence douce
    float alpha = clamp(mask * (0.9 + 0.1 * sin(TIME * 2.2)), 0.0, 1.0);

    ALBEDO = ribbon_rgb;
    EMISSION = emission;
    ALPHA = alpha;
}

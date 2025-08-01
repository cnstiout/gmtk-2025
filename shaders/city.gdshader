shader_type spatial;
render_mode unshaded;

// === UV / mouvement ===
uniform float uv_speed : hint_range(0.0, 5.0) = 1.0;
uniform float uv_breath_amp : hint_range(0.0, 0.5) = 0.1;
uniform float uv_breath_speed : hint_range(0.1, 2.0) = 0.5;
uniform float uv_offset_x : hint_range(-5.0, 5.0) = 0.0;
uniform float uv_offset_y : hint_range(-5.0, 5.0) = 0.0;
uniform float uv_scale_x : hint_range(0.1, 100.0) = 1.0;
uniform float uv_scale_y : hint_range(0.1, 100.0) = 1.0;

// === Couches de ville ===
uniform float layer_speed_0 : hint_range(0.0, 4.0) = 1.0;
uniform float layer_speed_1 : hint_range(0.0, 4.0) = 0.8;
uniform float layer_speed_2 : hint_range(0.0, 4.0) = 0.6;
uniform float layer_depth_0 : hint_range(0.0, 1.0) = 1.0;
uniform float layer_depth_1 : hint_range(0.0, 1.0) = 0.6;
uniform float layer_depth_2 : hint_range(0.0, 1.0) = 0.4;
uniform float layer_offset_0 = 0.0;
uniform float layer_offset_1 = 1.7;
uniform float layer_offset_2 = 3.4;

// === Fenêtres ===
uniform float window_density : hint_range(0.0, 1.0) = 0.5;
uniform float window_width : hint_range(0.01, 0.5) = 0.1;
uniform float window_height : hint_range(0.01, 0.5) = 0.2;
uniform float window_spacing : hint_range(5.0, 30.0) = 10.0;
uniform float window_blink_threshold : hint_range(0.0, 1.0) = 0.6;
uniform float window_brightness_variance : hint_range(0.0, 1.0) = 0.2;
uniform float window_noise_scale : hint_range(0.1, 100.0) = 1.0;
uniform vec3 window_color : source_color = vec3(1.0, 0.3, 0.9);
uniform float window_corner_softness : hint_range(0.0, 0.5) = 0.1;

// === Petites étoiles ===
uniform float star_density : hint_range(0.0, 1.0) = 0.15;
uniform float star_size : hint_range(0.5, 5.0) = 2.0;
uniform float star_flicker_speed : hint_range(0.1, 10.0) = 3.0;

// === Apparence générale ===
uniform vec4 base_sky : source_color = vec4(0.02, 0.02, 0.08, 1.0);
uniform vec4 city_color : source_color = vec4(0.15, 0.6, 1.0, 1.0);
uniform float glow_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float scanline_strength : hint_range(0.0, 0.2) = 0.08;
uniform float palette_cycle_speed : hint_range(0.0, 2.0) = 1.2;

// === Helpers noise / hash ===
float hash2(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash2(i);
    float b = hash2(i + vec2(1.0, 0.0));
    float c = hash2(i + vec2(0.0, 1.0));
    float d = hash2(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// === Skyline procédurale ===
float skyline(float x, float layer_offset) {
    float cell = floor(x * 30.0 + layer_offset);
    float rnd = fract(sin(cell * 1.3 + layer_offset * 7.1) * 43758.5453);
    float height = mix(0.1, 0.6, smoothstep(0.0, 1.0, rnd));
    float local = fract(x * 30.0 + layer_offset);
    float width = mix(0.3, 0.9, smoothstep(0.0, 1.0, fract(sin(cell + 3.2) * 43758.5453)));
    float inside = step(local, width);
    return inside * height;
}

// === Fenêtre adoucie ===
float soft_box(vec2 uv, vec2 size, float softness) {
    vec2 half = size * 0.5;
    vec2 d = abs(uv) - half;
    vec2 smoothe = max(d, vec2(0.0));
    float outside = length(smoothe);
    float inside = min(max(d.x, d.y), 0.0);
    float dist = outside + inside;
    return 1.0 - smoothstep(0.0, softness, dist);
}

void fragment() {
    float t = TIME;

    // UV : scale + breathing + offset + déplacement global
    float breath_x = 1.0 + uv_breath_amp * sin(t * uv_breath_speed + 1.1);
    float breath_y = 1.0 + uv_breath_amp * cos(t * uv_breath_speed + 2.3);
    vec2 uv = UV;
    uv = uv * vec2(uv_scale_x * breath_x, uv_scale_y * breath_y);
    uv += vec2(uv_offset_x, uv_offset_y);
    uv += vec2(t * uv_speed * 0.1, 0.0);
    uv = fract(uv);

    // fond
    vec3 color = base_sky.rgb;

    // ville (3 couches)
    float city_accum = 0.0;
    float y0 = skyline(uv.x + t * layer_speed_0 + layer_offset_0, layer_offset_0);
    city_accum += smoothstep(0.0, 1.0, y0) * layer_depth_0;
    float y1 = skyline(uv.x + t * layer_speed_1 + layer_offset_1, layer_offset_1);
    city_accum += smoothstep(0.0, 1.0, y1) * layer_depth_1;
    float y2 = skyline(uv.x + t * layer_speed_2 + layer_offset_2, layer_offset_2);
    city_accum += smoothstep(0.0, 1.0, y2) * layer_depth_2;
    vec3 city = city_color.rgb * city_accum;

    // fenêtres avec flicker noise + jitter
    vec3 window_layer = vec3(0.0);
    vec2 grid = vec2(floor(uv.x * window_spacing + t * layer_speed_0 * 0.5),
                     floor(uv.y * 10.0));
    // jitter corrigé : convertir le float en vec2
    vec2 jitter = vec2(hash2(grid) - 0.5) * 0.2;
    vec2 cell_uv = fract(vec2(uv.x * window_spacing + t * layer_speed_0 * 0.5,
                              uv.y * 10.0) + jitter) - 0.5;
    float cell_rand = hash2(grid);
    if (cell_rand < window_density) {
        vec2 noise_coord = grid * window_noise_scale + vec2(t * 0.15, t * 0.27);
        float flicker_noise_raw = noise(noise_coord);
        float flicker_noise = smoothstep(window_blink_threshold, 1.0, flicker_noise_raw);
        if (flicker_noise_raw > window_blink_threshold) {
            float brightness_variation = mix(1.0 - window_brightness_variance, 1.0 + window_brightness_variance,
                                             hash2(grid * 1.37));
            float window_mask = soft_box(cell_uv / vec2(window_width, window_height), vec2(1.0), window_corner_softness);
            window_layer += window_color * flicker_noise * brightness_variation * window_mask * step(city_accum, 1.0);
        }
    }

    // glow
    float glow = smoothstep(0.02, 0.0, abs(uv.y - 0.5)) * city_accum * glow_intensity;

    // petites étoiles
    vec3 star_layer = vec3(0.0);
    vec2 star_uv = UV * 30.0;
    float n = noise(star_uv + t * star_flicker_speed * 0.1);
    if (n < star_density) {
        vec2 local = fract(UV * star_size) - 0.5;
        float dist = length(local);
        float atten = smoothstep(0.5, 0.0, dist);
        float flick = smoothstep(0.0, 1.0, noise(vec2(n * 10.0, t * 0.5)));
        star_layer = vec3(1.0) * flick * atten * 0.5;
    }

    // scanlines rétro
    float scanline = sin(uv.y * 300.0) * scanline_strength * (1.0 - uv.y * 0.5);

    // composition
    color += city + window_layer + vec3(glow) + star_layer + vec3(scanline);

    // posterisation
    color = floor(color * 6.0) / 6.0;

    // palette cycling subtil
    color *= 0.95 + 0.05 * sin(t * palette_cycle_speed + uv.x * 3.0);

    ALBEDO = color;
    EMISSION = color;
}

shader_type sky;

uniform float time;
uniform float speed = 1.0;
uniform sampler2D city_strip_above;
uniform sampler2D city_strip_below;
uniform vec3 base_color = vec3(0.1, 0.6, 1.0);
uniform vec3 neon_color = vec3(1.0, 0.3, 0.9);
uniform float neon_strength = 1.0;
uniform float city_opacity = 0.7;

float cheap_noise(float x) {
    return fract(sin(x * 12.9898 + 78.233) * 43758.5453);
}

float neon_mask_func(float u, float t) {
    float phase = fract(u * 10.0 + t * 0.5);
    return smoothstep(0.45, 0.55, sin(phase * 2.0 * 3.14159265));
}

void sky() {
    vec3 view_dir = normalize(EYEDIR);
    float vertical = clamp(view_dir.y * 0.5 + 0.5, 0.0, 1.0);

    float azimuth = atan(view_dir.z, view_dir.x);
    float u = fract((azimuth / (2.0 * 3.14159265)) + 0.5 + time * speed * 0.05 * (1.0 - vertical));

    float fade_above = pow(smoothstep(0.2, 0.9, view_dir.y), 1.2);
    float fade_below = pow(smoothstep(0.2, 0.9, -view_dir.y), 1.2);

    vec3 silhouette_above = texture(city_strip_above, vec2(u, 0.5)).rgb;
    vec3 silhouette_below = texture(city_strip_below, vec2(u, 0.5)).rgb;

    float scanline = step(0.5, fract(view_dir.y * 300.0));
    float shimmer = sin(time * 8.0 + view_dir.y * 60.0) * 0.04;
    float flicker_above = mix(0.9, 1.1, cheap_noise(view_dir.y * 25.0 + time * 1.2));
    float flicker_below = mix(0.85, 1.0, cheap_noise(view_dir.y * 20.0 + time * 1.5));

    float neon_mask = neon_mask_func(u, time);
    vec3 neon_above = neon_color * neon_strength * neon_mask * silhouette_above;
    vec3 neon_below = neon_color * neon_strength * neon_mask * silhouette_below * 0.6;

    vec3 city_above = base_color * silhouette_above * flicker_above;
    city_above += neon_above;
    city_above *= fade_above;

    vec3 city_below = base_color * silhouette_below * flicker_below * 0.6;
    city_below += neon_below;
    city_below *= fade_below;

    vec3 retro_noise = vec3(scanline * 0.03 + shimmer);

    vec3 sky_base = mix(vec3(0.02, 0.02, 0.08), vec3(0.12, 0.3, 0.6), pow(vertical, 1.5));

    vec3 combined = sky_base + (city_above + city_below) * city_opacity + retro_noise;

    combined = floor(combined * 6.0) / 6.0;
    combined = combined / (combined + vec3(1.0));

    COLOR = combined;
}

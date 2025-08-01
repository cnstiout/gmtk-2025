shader_type spatial;

// --- paramètres exposés ---
uniform vec3 light_color = vec3(0.2, 0.8, 1.0);
uniform float speed = 1.3;
uniform float ribbon_width = 0.12;
uniform float trail_length = 1.1;
uniform float noise_strength = 0.25;
uniform int ribbon_count = 4;
uniform float contrast = 2.2;
uniform float glow_falloff = 2.8;
uniform float speed_multiplier = 1.0; // contrôle de vitesse interne

// Helpers bruit 1D
float hash1(float x) {
    return fract(sin(x * 43758.5453123) * 43758.5453123);
}
float noise1(float x) {
    float i = floor(x);
    float f = fract(x);
    float a = hash1(i);
    float b = hash1(i + 1.0);
    return mix(a, b, smoothstep(0.0, 1.0, f));
}

void fragment() {
    vec2 uv = UV;
    float time = TIME * speed_multiplier;

    // Position et normale en monde reconstruites
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vec3 world_norm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);

    // Position de la caméra et direction (built-ins que tu as dit fonctionner)
    vec3 cam_pos = CAMERA_POSITION_WORLD;
    vec3 cam_dir = normalize(CAMERA_DIRECTION_WORLD); // direction de la caméra (vers où elle regarde)

    // Flux : direction entre cam et fragment projetée sur le plan
    vec3 to_cam = normalize(cam_pos - world_pos);
    vec3 flow_world = normalize(to_cam - dot(to_cam, world_norm) * world_norm);
    float dir_offset = dot(flow_world.xy, vec2(1.0, 0.0));

    float accum = 0.0;

    for (int i = 0; i < ribbon_count; ++i) {
        float fi = float(i);
        float base_offset = mix(-0.35, 0.35, fi / max(1.0, float(ribbon_count - 1)));

        float phase = hash1(fi * 12.3) * 6.28318;
        float speed_offset = (hash1(fi * 7.7) - 0.5) * 0.4;

        float moving = fract((uv.y + time * (speed + speed_offset)) * 0.25);
        float lateral_noise = (noise1(uv.y * 4.5 + fi * 2.2 + time * 0.6) - 0.5) * noise_strength;

        // Centre droit : pas de wrapping sur X
        float ribbon_center = 0.5 + base_offset + sin(uv.y * 3.14 + phase + time * 0.9) * 0.3 
                              + lateral_noise + dir_offset * 0.12;
        ribbon_center = clamp(ribbon_center, 0.0, 1.0);

        float dist = abs(uv.x - ribbon_center);
        float ribbon_mask = smoothstep(ribbon_width * 0.5, 0.0, dist);

        float diff = uv.y - moving;
        diff = mod(diff + 1.0, 1.0);
        float trail_factor = pow(max(0.0, 1.0 - diff * trail_length), glow_falloff);

        accum += ribbon_mask * trail_factor;
    }

    accum = pow(accum * contrast, 1.0);
    vec3 base = vec3(0.015);
    vec3 glow = light_color * accum;

    ALBEDO = base + glow;
    EMISSION = glow;
    ALPHA = clamp(accum, 0.0, 1.0);
}

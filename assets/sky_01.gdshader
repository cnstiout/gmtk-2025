shader_type sky;

// ==== CONTROLES =====
uniform float time : hint_range(0, 1000) = 0.0;
uniform vec4 sky_color = vec4(0.05, 0.07, 0.15, 1.0);
uniform vec4 horizon_color = vec4(0.15, 0.18, 0.25, 1.0);
uniform float fog_start : hint_range(0.0, 200.0) = 60.0;
uniform float fog_end : hint_range(0.0, 400.0) = 150.0;
uniform float fog_strength : hint_range(0.0, 1.0) = 0.6;
uniform bool enable_edge_highlight = true;
uniform bool enable_horizon = true;
uniform bool enable_grid_far = true;
uniform float max_distance : hint_range(50.0, 400.0) = 200.0;
uniform float detail_scale : hint_range(0.1, 2.0) = 0.6; // step multiplier
uniform float quant_levels : hint_range(2.0, 16.0) = 6.0; // rétro quantification

// ==== UTILITAIRES ====
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 78.233);
    return fract(p.x * p.y);
}

float box_sdf(vec3 p, vec3 b) {
    vec3 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

float building_height(vec2 cell) {
    float h = hash(cell);
    h = floor(h * 5.0 + 1.0); // 1..5
    h += 0.15 * sin(time + hash(cell) * 6.2831); // pulsation
    return h;
}

float city_sdf(vec3 pos) {
    vec2 cell = floor(pos.xz);
    float minDist = 1e5;
    for (int dx = -1; dx <= 1; dx++) {
        for (int dz = -1; dz <= 1; dz++) {
            vec2 c = cell + vec2(float(dx), float(dz));
            float h = building_height(c);
            vec3 center = vec3(c.x + 0.5, h * 0.5, c.y + 0.5);
            vec3 local = pos - center;
            vec3 half = vec3(0.4, h * 0.5, 0.4);
            float d = box_sdf(local, half);
            minDist = min(minDist, d);
        }
    }
    return minDist;
}

vec3 building_color(vec2 cell) {
    float v = hash(cell);
    if (v < 0.33) return vec3(0.8, 0.6, 0.4);
    else if (v < 0.66) return vec3(0.4, 0.7, 0.8);
    else return vec3(0.6, 0.9, 0.5);
}

// gradient / horizon mix
vec3 compute_horizon(vec3 ray_dir, vec3 sc, vec3 hc) {
    float down_factor = clamp((-ray_dir.y - 0.1) / 0.9, 0.0, 1.0);
    float t = pow(down_factor, 1.5);
    return mix(sc, hc, t);
}

// grille lointaine pour structure visuelle
vec3 far_grid(vec3 p, float total_dist) {
    if (!enable_grid_far) return vec3(0.0);
    float fade = smoothstep(100.0, 150.0, total_dist);
    vec2 gv = fract(p.xz * 0.1);
    float line = step(0.02, min(gv.x, gv.y));
    vec3 gcol = mix(vec3(0.02), vec3(0.12), line);
    return gcol * fade;
}

// edge highlight approximatif
float edge_factor(vec3 p) {
    float eps = 0.03;
    float gx = city_sdf(p + vec3(eps, 0.0, 0.0)) - city_sdf(p - vec3(eps, 0.0, 0.0));
    float gz = city_sdf(p + vec3(0.0, 0.0, eps)) - city_sdf(p - vec3(0.0, 0.0, eps));
    return length(vec2(gx, gz));
}

void sky() {
    vec3 sc = sky_color.rgb;
    vec3 hc = horizon_color.rgb;

    vec3 ray_dir = normalize(EYEDIR);
    vec3 ray_origin = vec3(0.0, 10.0, 0.0);
    if (ray_dir.y > -0.1) {
        ray_dir.y = -abs(ray_dir.y);
    }

    float total_dist = 0.0;
    vec3 col = sc;
    bool hit = false;
    vec3 hit_pos = vec3(0.0);

    // Raymarching
    for (int i = 0; i < 140; i++) {
        vec3 p = ray_origin + ray_dir * total_dist;

        if (p.y < 0.0) {
            float d = city_sdf(p);
            if (d < 0.008) {
                vec2 cell = floor(p.xz);
                col = building_color(cell);
                hit = true;
                hit_pos = p;
                break;
            }
        }

        float distField = city_sdf(p);
        float step = max(0.005, distField * detail_scale);
        total_dist += step;
        if (total_dist > max_distance) break;
    }

    if (!hit && enable_horizon) {
        col = compute_horizon(ray_dir, sc, hc);
    }

    col = mix(col, far_grid(ray_origin + ray_dir * total_dist, total_dist), 1.0);

    if (enable_edge_highlight && hit) {
        float ef = edge_factor(hit_pos);
        float edge = smoothstep(0.1, 0.35, ef);
        col += edge * 0.15;
    }

    if (hit) {
        float height_factor = clamp(hit_pos.y / 5.0, 0.0, 1.0);
        col *= 0.7 + 0.3 * height_factor;
    }

    float fog = clamp((total_dist - fog_start) / max(1.0, fog_end - fog_start), 0.0, 1.0);
    col = mix(col, sc, fog * fog_strength);

    col = floor(col * quant_levels) / quant_levels;

    COLOR = col;
}

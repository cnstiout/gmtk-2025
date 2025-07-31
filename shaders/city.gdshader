shader_type sky;

// ==== PARAMÈTRES =====
uniform float time : hint_range(0, 1000) = 0.0;
uniform vec4 sky_color  = vec4(0.05, 0.07, 0.15, 1.0);
uniform vec4 horizon_color  = vec4(0.15, 0.18, 0.25, 1.0);
uniform float fog_start : hint_range(0.0, 200.0) = 80.0;
uniform float fog_end : hint_range(0.0, 400.0) = 160.0;
uniform float fog_strength : hint_range(0.0, 1.0) = 0.5;

uniform float max_distance : hint_range(50.0, 400.0) = 180.0;
uniform float detail_scale : hint_range(0.2, 1.5) = 0.7;
uniform float quant_levels : hint_range(2.0, 16.0) = 6.0; // rétro quantification
uniform float pixel_steps : hint_range(8.0, 64.0) = 16.0; // niveau de pixelisation directionnelle
uniform bool low_quality = false;
uniform bool enable_edge_highlight = true;
uniform bool enable_horizon = true;
uniform bool enable_far_grid = true;

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
    h += 0.1 * sin(time + hash(cell) * 6.2831);
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

vec3 compute_horizon(vec3 ray_dir, vec3 sc, vec3 hc) {
    float down = clamp((-ray_dir.y - 0.1) / 0.9, 0.0, 1.0);
    float t = pow(down, 1.4);
    return mix(sc, hc, t);
}

vec3 far_grid(vec3 p, float total_dist) {
    if (!enable_far_grid) return vec3(0.0);
    float fade = smoothstep(100.0, 150.0, total_dist);
    vec2 gv = fract(p.xz * 0.1);
    float line = step(0.03, min(gv.x, gv.y));
    vec3 gcol = mix(vec3(0.02), vec3(0.1), line);
    return gcol * fade;
}

float edge_factor(vec3 p) {
    float eps = 0.04;
    float gx = city_sdf(p + vec3(eps, 0.0, 0.0)) - city_sdf(p - vec3(eps, 0.0, 0.0));
    float gz = city_sdf(p + vec3(0.0, 0.0, eps)) - city_sdf(p - vec3(0.0, 0.0, eps));
    return length(vec2(gx, gz));
}

void sky() {
    vec3 sc = sky_color.rgb;
    vec3 hc = horizon_color.rgb;

    // Pixelisation directionnelle : quantifier EYEDIR en sphère discrète
    vec3 raw_dir = normalize(EYEDIR);
    vec3 ray_dir = raw_dir;
    if (pixel_steps > 1.0) {
        // simple quantification en longitude/latitude approximée via normalisation après floor
        vec2 sph = vec2(atan(raw_dir.x, -raw_dir.y), acos(clamp(raw_dir.z, -1.0, 1.0)));
        sph = floor(sph * pixel_steps) / pixel_steps;
        float sin_phi = sin(sph.y);
        ray_dir = normalize(vec3(sin_phi * sin(sph.x), -cos(sph.y), sin_phi * cos(sph.x)));
    }

    if (low_quality) {
        // simplification directionnelle supplémentaire
        ray_dir = normalize(mix(ray_dir, vec3(0.0, -1.0, 0.0), 0.25));
    }

    // early exit : si on regarde trop haut et horizon seul suffit
    if (!low_quality && ray_dir.y > -0.15 && enable_horizon) {
        COLOR = compute_horizon(ray_dir, sc, hc);
    }

    vec3 ray_origin = vec3(0.0, 10.0, 0.0);
    if (ray_dir.y > -0.1) ray_dir.y = -abs(ray_dir.y);

    float total_dist = 0.0;
    vec3 col = sc;
    bool hit = false;
    vec3 hit_pos = vec3(0.0);

    int max_iter = low_quality ? 70 : 120;
    float threshold = low_quality ? 0.012 : 0.008;

    for (int i = 0; i < max_iter; i++) {
        vec3 p = ray_origin + ray_dir * total_dist;
        float distField = city_sdf(p);

        if (total_dist > 120.0) {
            if (!hit) {
                col = mix(sc, vec3(0.2, 0.25, 0.3), clamp((-ray_dir.y), 0.0, 1.0));
            }
            break;
        }

        float step = max(0.008, distField * detail_scale);
        if (total_dist > 80.0) step *= 1.3;
        total_dist += step;
        if (total_dist > max_distance) break;

        if (p.y < 0.0 && distField < threshold) {
            col = building_color(floor(p.xz));
            hit = true;
            hit_pos = p;
            break;
        }
    }

    if (!hit && enable_horizon) {
        col = compute_horizon(ray_dir, sc, hc);
    }

    if (!low_quality) {
        col = mix(col, far_grid(ray_origin + ray_dir * total_dist, total_dist), 1.0);
    }

    if (enable_edge_highlight && hit && !low_quality) {
        float ef = edge_factor(hit_pos);
        float edge = smoothstep(0.1, 0.35, ef);
        col += edge * 0.12;
    }

    if (hit) {
        float height_factor = clamp(hit_pos.y / 5.0, 0.0, 1.0);
        col *= 0.7 + 0.3 * height_factor;
    }

    float fog = clamp((total_dist - fog_start) / max(1.0, fog_end - fog_start), 0.0, 1.0);
    col = mix(col, sc, fog * fog_strength);

    // quantification rétro
    col = floor(col * quant_levels) / quant_levels;

    COLOR = col;
}

shader_type sky;

group_uniforms MainStars;
uniform sampler2D gradientA;
uniform float horizontalMovement: hint_range(-2.0, 2.0, 0.1) = 0.1;
uniform float verticalMovement: hint_range(-2.0, 2.0, 0.1) = 0.1;
uniform float frequencyStar: hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float sizeStar: hint_range(10.0, 200.0, 10.0) = 100.0;
uniform float brightnessStar: hint_range(1.0, 5.0, 1.0) = 3.0;
uniform float shineFrequencyStar: hint_range(1.0, 20.0, 1.0) = 8.0;
uniform float transparencyStar: hint_range(0.0, 1.0, 0.01) = 0.0;
uniform int starIterations: hint_range(1, 10, 1) = 3;

group_uniforms BackgroundStars;
uniform sampler2D gradientB;
uniform float frequencyBgStar: hint_range(0.950, 1.0, 0.001) = 0.996;
uniform float shineFrequencyBgStar: hint_range(0.0, 5.0, 1.0) = 1.0;
uniform float transparencyBgStar: hint_range(0.0, 1.0, 0.01) = 0.0;

group_uniforms Background;
uniform vec4 colorBackground: source_color = vec4(0.05, 0.04, 0.20, 1.0);
uniform float transparencyBackground: hint_range(0.0, 1.0, 0.01) = 0.0;

group_uniforms Noise;
uniform float seed: hint_range(0.0, 100.0, 1.0) = 0.0;

float rand(vec2 st) {
    return fract(sin(dot(st, vec2(seed + 12.9898, 78.233))) * 43758.5453123);
}

float remap(float prob, float starValue) {
    return (starValue - prob) / max(1.0 - prob, 0.0001);
}

void sky() {
    // Direction de vue et coordonnées sphériques
    vec3 dir = normalize(EYEDIR);
    float az = atan(dir.z, dir.x); // [-pi,pi]
    float el = asin(clamp(dir.y, -1.0, 1.0)); // [-pi/2,pi/2]
    vec2 sphere_uv = vec2(az / (2.0 * 3.14159265) + 0.5, el / 3.14159265 + 0.5);

    // Base
    vec3 accum = colorBackground.rgb * (1.0 - transparencyBackground);

    // Déplacements simulés
    vec2 travel = vec2(TIME * horizontalMovement, TIME * verticalMovement);

    float prob = 1.0 - frequencyStar;

    // Étoiles principales en "couches"
    for (int i = 1; i <= starIterations; i++) {
        float layer_size = sizeStar / float(i);
        // Simuler grille sur la sphère
        vec2 scaled = sphere_uv * layer_size + travel * (1.0 / layer_size);
        vec2 cell = floor(scaled);
        float starValue = rand(cell);

        if (starValue > prob) {
            // Calcul de scintillement
            float t = 0.9 + 0.2 * sin(TIME * shineFrequencyStar + remap(prob, starValue) * 45.0);
            float flicker = t * t * brightnessStar / float(i);

            // Distance sur UV entre point et centre de cellule
            vec2 center_uv = (cell + 0.5 - travel * (1.0 / layer_size)) / layer_size;
            vec2 diff = sphere_uv - center_uv;
            float dist = length(diff);
            float shape = 1.0 - dist * layer_size; // plus proche = plus fort
            shape = clamp(shape, 0.0, 1.0);

            float star_contrib = flicker * shape;

            vec4 colormapA = texture(gradientA, vec2(remap(prob, starValue), 0.5));
            accum += colormapA.rgb * star_contrib * (1.0 - transparencyStar);
        }
    }

    // Étoiles de fond aléatoires
    if (rand(sphere_uv * 0.05) > frequencyBgStar) {
        float r = rand(sphere_uv);
        float shine = sin(TIME * shineFrequencyBgStar * (r * 5.0) + 720.0 * r);
        float color_factor = r * (0.85 * shine + 0.95);
        vec4 colormapB = texture(gradientB, vec2(r, 0.5));
        accum += colormapB.rgb * color_factor * (1.0 - transparencyBgStar);
    }

    // Posterisation / palette SNES léger
    vec3 final_color = floor(accum * 6.0) / 6.0;
    final_color = final_color / (final_color + vec3(1.0)); // tonemapping doux
    final_color *= 0.95 + 0.05 * sin(TIME * 1.1 + sphere_uv.y * 3.0); // léger cycling

    COLOR = final_color;
}

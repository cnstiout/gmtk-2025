shader_type canvas_item;

uniform float skew_strength : hint_range(0.0, 1.0) = 0.4;
uniform float angle : hint_range(-3.1415927, 3.1415927) = 0.0; // pas d'expressions, valeurs littérales

void vertex() {
    float h_shear = sin(angle) * skew_strength;
    float v_shear = cos(angle) * skew_strength * 0.3;

    vec2 pos = VERTEX;
    vec2 sheared = vec2(
        pos.x + h_shear * pos.y,
        v_shear * pos.x + pos.y
    );
    VERTEX = sheared;
}

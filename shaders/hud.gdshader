shader_type canvas_item;

uniform sampler2D original_tex;
uniform sampler2D glow_tex;
uniform float glow_intensity : hint_range(0.0, 3.0) = 1.0;
uniform float glow_fade : hint_range(0.0, 1.0) = 0.5; // atténuation du glow
uniform vec4 tint = vec4(1.0, 0.9, 0.6, 1.0); // couleur du glow

void fragment() {
    vec2 uv = UV;
    vec4 base = texture(original_tex, uv);
    vec4 glow = texture(glow_tex, uv);

    // Teinter & atténuer le glow
    glow = glow * tint * glow_intensity;
    // Optionnel : fade selon alpha
    glow *= pow(glow.a, 0.5); // ou autre courbe

    // Composite : base + glow additive, tu peux aussi faire un mix
    vec4 result = base + glow * (1.0 - glow_fade);

    COLOR = result;
}

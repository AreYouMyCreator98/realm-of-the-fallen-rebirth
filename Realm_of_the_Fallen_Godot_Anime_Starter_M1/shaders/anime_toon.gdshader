shader_type spatial;
render_mode diffuse_toon, specular_toon, cull_back;

uniform vec4 base_color : source_color = vec4(0.13, 0.17, 0.24, 1.0);
uniform float roughness_amount : hint_range(0.0, 1.0) = 0.72;
uniform float rim_strength : hint_range(0.0, 1.0) = 0.3;

void fragment() {
    ALBEDO = base_color.rgb;
    ROUGHNESS = roughness_amount;
    METALLIC = 0.03;
    RIM = rim_strength;
    RIM_TINT = 0.28;
}

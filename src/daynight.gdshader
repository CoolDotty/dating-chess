shader_type canvas_item;

uniform float cycle_speed = 2.2; // Controls how fast the cycle runs
uniform vec4 night_tint : source_color = vec4(0.2, 0.3, 0.5, 1.0); // Dark blue tint
uniform float max_darkness = 0.7; // How much to blend toward night (0.0-1.0)

void fragment() {
    // Sample the original texture
    vec4 original_color = texture(TEXTURE, UV);
    
    // Create a smooth oscillating value between 0 and 1 using sine wave
    float cycle = (sin(TIME * cycle_speed) + 1.0) * 0.5;
    
    // Scale by max_darkness to control intensity
    float blend_factor = cycle * max_darkness;
    
    // Apply night tint to the original color
    vec4 night_color = original_color * night_tint;
    
    // Interpolate between original and night-tinted color
    COLOR = mix(original_color, night_color, blend_factor);
}

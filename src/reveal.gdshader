shader_type canvas_item;

// Uniform to control the fill percentage (0.0 = hidden, 1.0 = fully visible)
uniform float fill_percentage : hint_range(0.0, 1.0) = 1.0;

// You can expose these as uniforms if you want to tweak them in the inspector
// uniform vec3 color_start : source_color = vec3(1.0, 0.65, 0.75); // Pink
// uniform vec3 color_end : source_color = vec3(1.0, 0.15, 0.15);   // Red

void fragment() {
    // Get the original texture color
    vec4 original_color = texture(TEXTURE, UV);
    
    // UV.y goes from 0.0 (top) to 1.0 (bottom)
    float cutoff = 1.0 - fill_percentage;
    
    if (UV.y < cutoff) {
        COLOR = vec4(original_color.rgb, 0.0);
    } else {
        // Calculate factor: 0.0 at 50% fill, 1.0 at 100% fill
        float red_factor = 0.0;
        if (fill_percentage > 0.5) {
            float normalized = (fill_percentage - 0.5) / 0.5;
            red_factor = pow(normalized, 2.0);
        }
        
        // Define your colors
        vec3 pink = vec3(1.0, 0.65, 0.75); // Start color (Pink)
        vec3 red = vec3(1.0, 0.15, 0.15);  // End color (Red)
        
        // specific to user request: Scale from Pink to Red
        // We mix the TINT colors first, then apply to the sprite.
        // At red_factor 0.0 (low fill), tint is Pink.
        // At red_factor 1.0 (high fill), tint is Red.
        vec3 current_tint = mix(pink, red, red_factor);
        
        // Apply the tint to the original texture
        // This replaces the old 'mix' logic to ensure the start state is Pink, not White
        COLOR = vec4(original_color.rgb * current_tint, original_color.a);
    }
}

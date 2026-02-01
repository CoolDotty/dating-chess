shader_type canvas_item;

// Uniform to control the fill percentage (0.0 = hidden, 1.0 = fully visible)
uniform float fill_percentage : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    // Get the original texture color
    vec4 original_color = texture(TEXTURE, UV);
    
    // UV.y goes from 0.0 (top) to 1.0 (bottom)
    // We want to reveal from bottom up, so we check if the current pixel
    // is in the visible range
    float cutoff = 1.0 - fill_percentage; // Convert to top-down cutoff
    
    // If the current UV.y is above the cutoff line, make it transparent
    if (UV.y < cutoff) {
        COLOR = vec4(original_color.rgb, 0.0);
    } else {
        // Calculate red blend factor with exponential curve starting at 0.5
        float red_factor = 0.0;
        if (fill_percentage > 0.5) {
            // Remap fill_percentage from [0.5, 1.0] to [0.0, 1.0]
            float normalized = (fill_percentage - 0.5) / 0.5;
            // Apply exponential curve (adjust exponent for steepness)
            red_factor = pow(normalized, 2.0);
        }
        
        // Blend original color with red based on red_factor
        vec3 red = vec3(1.0, 0.25, 0.25);
        vec3 blended_color = mix(original_color.rgb, red, red_factor);
        COLOR = vec4(blended_color, original_color.a);
    }
}

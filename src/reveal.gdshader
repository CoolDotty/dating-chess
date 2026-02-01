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
        COLOR = original_color;
    }
}

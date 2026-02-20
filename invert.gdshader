shader_type canvas_item;

uniform bool invert_colors = false;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    vec4 final_color = tex_color;
	vec4 final_mod = COLOR;
    
    if (invert_colors) {
        final_color = vec4(1.0 - tex_color.rgb, tex_color.a);
		final_mod = vec4(1.0 - COLOR.rgb, COLOR.a);
		COLOR = final_color + final_mod;
    } else {
		COLOR = final_color * final_mod;
	}
}

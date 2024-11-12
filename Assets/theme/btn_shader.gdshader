shader_type canvas_item;

uniform bool is_hovered = false;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	
	if (is_hovered) {
		tex_color.rgb = clamp(tex_color.rgb * 1.5, 0.0, 1.0);
	}

	COLOR = tex_color;
}

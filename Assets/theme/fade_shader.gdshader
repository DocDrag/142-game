shader_type canvas_item;

uniform float fade_height : hint_range(0.0, 1.0) = 0.1;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float fade_top = smoothstep(0.0, fade_height, UV.y);
	float fade_bottom = smoothstep(1.0, 1.0 - fade_height, UV.y);
	color.a *= min(fade_top, fade_bottom);
	COLOR = color;
}
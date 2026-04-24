shader_type canvas_item;

uniform float my_alpha = 0.2;

uniform float wave_speed = 3.0;
uniform float wave_freq = 10.0;
uniform float wave_width = 0.005;

void fragment() {
	vec4 current_color = COLOR;
	current_color.a = my_alpha;
	
	// Output the final color
	COLOR = current_color;
}
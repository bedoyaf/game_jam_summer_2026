shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float wave_speed = 3.0;
uniform float wave_freq = 10.0;
uniform float wave_width = 0.005;

void fragment() {
	// Get the screen UV coordinates
	vec2 uv = SCREEN_UV;
	
	// Create the "Underwater" distortion using Sine and Cosine
	// We shift the X position based on Y and Time, and vice versa
	float diff_x = sin(uv.y * wave_freq + TIME * wave_speed) * wave_width;
	float diff_y = cos(uv.x * wave_freq + TIME * wave_speed) * wave_width;
	
	vec2 distorted_uv = uv + vec2(diff_x, diff_y);
	
	COLOR = texture(SCREEN_TEXTURE, distorted_uv);
	
	//COLOR.rgb *= vec3(1.0, 0.3, 0.25);
}
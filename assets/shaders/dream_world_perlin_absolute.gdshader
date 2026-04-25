shader_type canvas_item;

uniform float speed = 2.0;
uniform float frequency = 10.0;
uniform float amplitude = 0.02;
uniform float edge_softness = 0.4;

uniform float alpha_addition_threshold = 0.0;
uniform float add_alpha = 0.2;
uniform float max_alpha = 0.8;


uniform sampler2D noise_texture : repeat_enable;

void fragment() {
    // 1. Calculate the wave based on SCREEN_UV.y (consistent scaling)
    float wave = sin(SCREEN_UV.y * frequency + TIME * speed) * amplitude;
    
    // 2. Apply wave to the standard UV for the actual sprites/view
    // This makes the dream world contents wiggle
    vec2 distorted_main_uv = UV + vec2(wave, 0.0);
    
    // 3. Apply wave to SCREEN_UV for the noise
    // This keeps the noise "stuck" to the distorted sprites
    vec2 distorted_noise_uv = SCREEN_UV + vec2(wave, 0.0);
    
    // 4. Sample the Viewport texture with distortion
    vec4 tex_color = texture(TEXTURE, distorted_main_uv);
    
    // 5. Sample the Noise
    float noise_value = texture(noise_texture, distorted_noise_uv).r;
    
    // 6. Edge Fading (Using undistorted UV so the "frame" stays stable)
    vec2 centered_uv = UV * 2.0 - 1.0;
    float dist = max(abs(centered_uv.x), abs(centered_uv.y));
    float edge_mask = smoothstep(1.0, 1.0 - edge_softness, dist);
    
    // Final composite
	//if (noise_value <= alpha_addition_threshold) {
		//tex_color.a += add_alpha;
    //}
	

	//if (noise_value <= 1.0) {
		//tex_color.a += 1.0;
    //}
	
	
	tex_color.a *= noise_value * edge_mask;
	tex_color.a += add_alpha;
	
	if (tex_color.a >= max_alpha) {
		tex_color.a = max_alpha;
	}
	
    COLOR = tex_color;
	

	
}
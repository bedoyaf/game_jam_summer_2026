shader_type canvas_item;

uniform float speed = 2.0;
uniform float frequency = 10.0;
uniform float amplitude = 0.02;

// Controls how "soft" the edge fade is
uniform float edge_softness = 0.4; 

uniform sampler2D noise_texture : repeat_enable;

void fragment() {
    // 1. Calculate wave using SCREEN_UV.y
    float wave = sin(SCREEN_UV.y * frequency + TIME * speed) * amplitude;
    
    // 2. Apply the wave distortion to SCREEN_UV for noise
    vec2 fixed_noise_uv = SCREEN_UV + vec2(wave, 0.0);
    float noise_value = texture(noise_texture, fixed_noise_uv).r;
    
    // 3. Edge Fading Logic (Vignette style)
    // Distance from the center (0.5, 0.5)
    vec2 centered_uv = UV * 2.0 - 1.0; // Remaps UV from [0,1] to [-1,1]
    float dist = length(centered_uv); // 0 at center, 1 at corners
    
    // Create a smooth mask that is 1.0 at center and 0.0 at edges
    // 'smoothstep' allows you to tune the falloff
    float edge_mask = smoothstep(1.0, 1.0 - edge_softness, dist);
    
    // 4. Combine everything
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Alpha is now (Base Color Alpha) * (Perlin Noise) * (Edge Mask)
    tex_color.a *= noise_value * edge_mask;
	
	tex_color.a += 0.1;
    
    COLOR = tex_color;
}
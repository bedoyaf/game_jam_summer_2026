shader_type canvas_item;

uniform float speed = 2.0;
uniform float frequency = 10.0;
uniform float amplitude = 0.02;

uniform float x_threshold = 0.5;
uniform float edge_softness = 0.4;

uniform float alpha_addition_threshold = 0.0;
uniform float add_alpha = 0.2;
uniform float max_alpha = 0.8;

uniform sampler2D noise_texture : repeat_enable;

void fragment() {
    // 1. Calculate waves for both axes
    // wave_x uses Y position to wiggle left/right
    float wave_x = sin(SCREEN_UV.y * frequency + TIME * speed) * amplitude;
    // wave_y uses X position to wiggle up/down
    float wave_y = cos(SCREEN_UV.x * frequency * 2.0 + TIME * speed) * amplitude;
    
    vec2 total_wave = vec2(wave_x, wave_y);

    // 2. Apply bidirectional wave to the standard UV
    vec2 distorted_main_uv = UV + total_wave;
    
    // 3. Apply bidirectional wave to SCREEN_UV for the noise
    vec2 distorted_noise_uv = SCREEN_UV + total_wave;
    
    // 4. Sample the Viewport texture with distortion
    vec4 tex_color = texture(TEXTURE, distorted_main_uv);
    
    // 5. Sample the Noise
    float noise_value = texture(noise_texture, distorted_noise_uv).r;
    
    // Updated fading logic to be more symmetrical for both axes
    float fade_x = smoothstep(1.0, x_threshold, UV.x);
    float fade_y = smoothstep(1.0, x_threshold, UV.y);
    
    // 6. Alpha and Masking
    tex_color.a += add_alpha;
    
    float edge_mask = fade_x * fade_y;
    tex_color.a *= noise_value * edge_mask;
    
    if (tex_color.a > max_alpha) {
        tex_color.a = max_alpha;
    }
    
    COLOR = tex_color;
}
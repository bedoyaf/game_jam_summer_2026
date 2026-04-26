shader_type canvas_item;

uniform float speed = 2.0;
uniform float frequency = 10.0;
uniform float amplitude = 0.02;

uniform float x_threshold = 0.5;
uniform float edge_softness = 0.4;

uniform float alpha_addition_threshold = 0.0;
uniform float add_alpha = 0.2;
uniform float max_alpha = 0.8;

// NEW PARAMETERS
uniform float reveal_progress : hint_range(0.0, 1.0) = 0.0;
uniform float reveal_softness = 0.1;

uniform sampler2D noise_texture : repeat_enable;

void fragment() {
    // 1. Calculate waves
    float wave_x = sin(SCREEN_UV.y * frequency + TIME * speed) * amplitude;
    float wave_y = cos(SCREEN_UV.x * frequency * 2.0 + TIME * speed) * amplitude;
    vec2 total_wave = vec2(wave_x, wave_y);

    // 2. Distort UVs
    vec2 distorted_main_uv = UV + total_wave;
    vec2 distorted_noise_uv = SCREEN_UV + total_wave;
    
    // 3. Sample Textures
    vec4 tex_color = texture(TEXTURE, distorted_main_uv);
    float noise_value = texture(noise_texture, distorted_noise_uv).r;
    
    // 4. Reveal Logic (The Black Wipe)
    // This creates a mask: 0.0 for black area, 1.0 for texture area
    float reveal_mask = smoothstep(reveal_progress - reveal_softness, reveal_progress + reveal_softness, UV.x);
    
    // Mix the texture color with black based on the mask
    // We keep the alpha separate so the "black" still respects your noise/fading
    tex_color.rgb = mix(vec3(0.0, 0.0, 0.0), tex_color.rgb, reveal_mask);
    
    // 5. Alpha and Masking (Existing logic)
    float fade_x = smoothstep(1.0, x_threshold, UV.x);
    float fade_y = smoothstep(1.0, x_threshold, UV.y);
    
    tex_color.a += add_alpha;
    float edge_mask = fade_x * fade_y;
    tex_color.a *= noise_value * edge_mask;
    
    if (tex_color.a > max_alpha) {
        tex_color.a = max_alpha;
    }
    
    COLOR = tex_color;
}
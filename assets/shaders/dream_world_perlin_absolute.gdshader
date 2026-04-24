shader_type canvas_item;

uniform float speed = 2.0;
uniform float frequency = 10.0;
uniform float amplitude = 0.02;

uniform sampler2D noise_texture : repeat_enable;

void fragment() {
    // 1. Calculate wave distortion using local UV 
    // (So the "wave" still moves with the object)
    float wave = sin(UV.y * frequency + TIME * speed) * amplitude;
    
    // 2. Use SCREEN_UV for the noise to keep it world-locked
    // We add the 'wave' here if you want the noise to distort with the edges
    vec2 fixed_noise_uv = SCREEN_UV + vec2(wave, 0.0);
    
    // 3. Sample the noise using the screen-space coordinates
    float noise_value = texture(noise_texture, fixed_noise_uv).r;
    
    // 4. Sample the ColorRect's color (usually just white for a ColorRect)
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Apply noise to alpha
    tex_color.a *= noise_value;
    
    COLOR = tex_color;
}
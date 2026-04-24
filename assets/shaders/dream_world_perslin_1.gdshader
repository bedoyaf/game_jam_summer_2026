shader_type canvas_item;

uniform float speed = 2.0;
uniform float frequency = 10.0;
uniform float amplitude = 0.02;

// The noise texture input
uniform sampler2D noise_texture;

void fragment() {
    // Wave distortion logic
    float wave = sin(UV.y * frequency + TIME * speed) * amplitude;
    vec2 distorted_uv = vec2(UV.x + wave, UV.y);
    
    // Sample the original texture with distortion
    vec4 tex_color = texture(TEXTURE, distorted_uv);
    
    // Sample the noise texture
    // We use UV or distorted_uv depending on if you want the noise to "wave" too
    float noise_value = texture(noise_texture, distorted_uv).r;
    
    // Apply noise to the alpha channel
    tex_color.a *= noise_value;
    
    COLOR = tex_color;
}
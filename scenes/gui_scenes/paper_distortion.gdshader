shader_type canvas_item;

// We no longer need SCREEN_TEXTURE. 
// Godot automatically provides 'TEXTURE' for the current Sprite.

uniform float wave_speed = 3.0;
uniform float wave_freq = 10.0;
uniform float wave_width = 0.05; // Note: You may need to increase this vs SCREEN_UV

void fragment() {
    // Use the Sprite's local UV (0.0 to 1.0 across the sprite)
    vec2 uv = UV;
    
    // Calculate distortion
    float diff_x = sin(uv.y * wave_freq + TIME * wave_speed) * wave_width;
    float diff_y = cos(uv.x * wave_freq + TIME * wave_speed) * wave_width;
    
    vec2 distorted_uv = uv + vec2(diff_x, diff_y);
    
    // Sample the Sprite's own texture instead of the whole screen
    vec4 tex_color = texture(TEXTURE, distorted_uv);
    
    COLOR = tex_color;
    
    // Optional: Re-enable your tint
    // COLOR.rgb *= vec3(1.0, 0.3, 0.25);
}
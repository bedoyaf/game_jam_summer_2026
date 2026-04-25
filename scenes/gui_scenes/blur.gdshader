shader_type canvas_item;

uniform float blur_strength : hint_range(0.0, 10.0) = 3.0;
uniform float blur_iterations : hint_range(1, 20) = 5;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 color = vec4(0.0);
    float total_weight = 0.0;

    // We use a simplified Gaussian distribution
    for (float i = -blur_iterations; i <= blur_iterations; i++) {
        for (float j = -blur_iterations; j <= blur_iterations; j++) {
            // Calculate distance for Gaussian weight
            float distance = length(vec2(i, j));
            float weight = exp(-(distance * distance) / (2.0 * blur_strength));
            
            vec2 offset = vec2(i, j) * SCREEN_PIXEL_SIZE * (blur_strength / 2.0);
            color += texture(screen_texture, uv + offset) * weight;
            total_weight += weight;
        }
    }

    COLOR = color / total_weight;
}
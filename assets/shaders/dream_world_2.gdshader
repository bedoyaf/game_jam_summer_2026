shader_type canvas_item;
uniform float speed = 2.0;
uniform float frequency = 10.0;
uniform float amplitude = 0.02;
uniform float my_alpha = 0.2;

void fragment() {
    float wave = sin(UV.y * frequency + TIME * speed) * amplitude;
    vec2 distorted_uv = vec2(UV.x + wave, UV.y);
    COLOR = texture(TEXTURE, distorted_uv);
	COLOR.a = my_alpha;
}
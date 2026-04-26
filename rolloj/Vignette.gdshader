shader_type canvas_item;

uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float vignette_multiplier = 0.2;
uniform float vignette_softness = 0.8;

void fragment() {
	// Calculate the distance from the current pixel to the center (0.5, 0.5)
	float dist = distance(UV, vec2(0.5, 0.5));
	
	// Smoothly interpolate the alpha based on the distance
	float alpha = smoothstep(vignette_multiplier, vignette_softness, dist);
	
	// Apply the color and the calculated alpha
	COLOR = vec4(vignette_color.rgb, alpha * vignette_color.a);
}
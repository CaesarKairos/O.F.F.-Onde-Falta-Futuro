shader_type canvas_item;

uniform float amount : hint_range(0.0, 0.1) = 0.015;

float random(vec2 uv)
{
	return fract(
		sin(dot(uv, vec2(12.9898,78.233)))
		* 43758.5453123
	);
}

void fragment()
{
	float noise = random(FRAGCOORD.xy);

	COLOR = vec4(
		vec3(noise),
		amount
	);
}

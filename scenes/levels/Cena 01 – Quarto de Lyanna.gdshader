shader_type canvas_item;

uniform float strength : hint_range(0.0, 1.0) = 0.3;

void fragment()
{
    vec2 pos = UV - vec2(0.5);

	pos.x *= 0.8;

	float dist = length(pos);

    float vignette = smoothstep(0.25, 0.7, dist);

    COLOR = vec4(0.05, 0.08, 0.12, vignette * strength);
}
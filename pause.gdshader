shader_type canvas_item;

uniform vec4 frame_color : source_color = vec4(0.0, 0.0, 0.0, 0.8);
uniform float border_thickness : hint_range(0.0, 0.5) = 0.1;
uniform float inner_corner_radius : hint_range(0.0, 0.5) = 0.05;

float sd_round_box(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + vec2(r);
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

void fragment() {
    vec2 uv = UV - vec2(0.5);
    vec2 size = vec2(0.5 - border_thickness);
    
    float dist = sd_round_box(uv, size, inner_corner_radius);
    
    // Se estiver dentro da caixa arredondada, fica transparente; se estiver fora, desenha a borda
    if (dist < 0.0) {
        COLOR = vec4(0.0);
    } else {
        COLOR = frame_color;
    }
}
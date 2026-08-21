shader_type canvas_item;

// --- CONTROLES DE FORMA E TAMANHO (Ajuste no Inspetor) ---
uniform vec4 cor_luz : source_color = vec4(1.0, 0.9, 0.6, 1.0);
uniform float largura_topo : hint_range(0.0, 1.0) = 0.1;
uniform float largura_base : hint_range(0.0, 1.0) = 0.9;
uniform float suavizacao : hint_range(0.0, 0.5) = 0.08;

// --- CONTROLE DE PISCADA (Controlado pelo Script) ---
uniform float intensidade_piscada : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec2 uv = UV;

    // Forma do Trapézio
    float largura_atual = mix(largura_topo, largura_base, uv.y);
    float margem = (1.0 - largura_atual) * 0.5;
    
    // Máscara com bordas suaves
    float mascara_horizontal = smoothstep(margem, margem + suavizacao, uv.x) - 
                               smoothstep(margem + largura_atual - suavizacao, margem + largura_atual, uv.x);
    
    float mascara_vertical = smoothstep(0.0, suavizacao, uv.y) - 
                             smoothstep(1.0 - suavizacao, 1.0, uv.y);
    
    float mascara_final = mascara_horizontal * mascara_vertical;
    
    // Gradiente vertical (mais forte no topo, desvanece na base)
    mascara_final *= (1.0 - uv.y);

    // Cor final combinando a máscara e o parâmetro de piscada
    COLOR = vec4(cor_luz.rgb, mascara_final * cor_luz.a * intensidade_piscada);
}
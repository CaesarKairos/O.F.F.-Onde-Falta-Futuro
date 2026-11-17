class_name GameConstants

# =========================================================
# ÍCONE DE INTERAÇÃO
# =========================================================

## Tamanho final desejado do ícone na tela, em pixels (largura e altura, já que a imagem
## fonte é quadrada). Ajuste só este número se quiser mudar o tamanho de TODOS os ícones
## do jogo de uma vez.
const INTERACTION_ICON_TARGET_PX := 96.0

## Tamanho do frame na imagem original (Press E.png). Não mude isso a menos que a imagem
## fonte mude de tamanho.
const INTERACTION_ICON_SOURCE_PX := 1024.0

const INTERACTION_ICON_SCALE := INTERACTION_ICON_TARGET_PX / INTERACTION_ICON_SOURCE_PX

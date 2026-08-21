extends Node2D
 
@onready var fade_rect: ColorRect = $ColorRect

func _ready() -> void:

# 1. FADE IN: A tela de carregamento surge do preto
	var tween_in = create_tween()
	tween_in.tween_property(fade_rect, "color:a", 0.0, 0.5)
	await tween_in.finished
	
	# 2. CARREGAMENTO (Simula o tempo de carregamento/barra de progresso)
	await get_tree().create_timer(2.0).timeout
	
	# 3. FADE OUT: A tela de carregamento escurece antes de ir para o jogo
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween_out = create_tween()
	tween_out.tween_property(fade_rect, "color:a", 1.0, 0.5)
	await tween_out.finished
	
	# 4. Troca para a cena do Quarto da Lyanna
	get_tree().change_scene_to_file("res://scenes/levels/Cena 01 – Quarto de Lyanna.tscn")

# =========================================================
# SINCRONIZAÇÃO DOS ÍCONES DE TECLA
# =========================================================

func _sincronizar_animacoes() -> void:

	for sprite in _coletar_animated_sprites():

		sprite.frame = 0
		sprite.frame_progress = 0.0
		sprite.play("default")


func _coletar_animated_sprites() -> Array[AnimatedSprite2D]:

	var lista: Array[AnimatedSprite2D] = []

	# Ícones de tecla que são filhos diretos de Control/background
	for filho in $Control/background.get_children():

		if filho is AnimatedSprite2D:

			lista.append(filho)

	# setinha_esquerda é filha de setinha_direita, não de background
	lista.append($Control/background/setinha_direita/setinha_esquerda)

	# AnimatedSprite2D da label "Pausar" fica direto em Control
	lista.append($Control/AnimatedSprite2D)

	return lista

extends Node2D


func _ready() -> void:

	_sincronizar_animacoes()

	var tempo_espera := randf_range(14.0, 17.0)

	print("Tela de carregamento: aguardando ", tempo_espera, " segundos...")

	await get_tree().create_timer(tempo_espera).timeout

	get_tree().change_scene_to_file(
		"res://scenes/levels/Cena 01 – Quarto de Lyanna.tscn"
	)


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
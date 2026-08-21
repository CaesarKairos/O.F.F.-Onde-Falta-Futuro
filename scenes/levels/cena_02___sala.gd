extends Node2D

# Called when the node enters the scene tree for the first tim
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
	get_tree().change_scene_to_file("res://scenes/levels/cena_04_rua_placeholder.tscn")

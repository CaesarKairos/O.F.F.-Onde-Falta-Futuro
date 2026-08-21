extends Node2D

func _ready() -> void:
	print("TELA INICIAL CARREGADA")
	print("btnJogar encontrado: ", $btnJogar)
	print("btnJogar disabled: ", $btnJogar.disabled)
	print("btnJogar mouse_filter: ", $btnJogar.mouse_filter)

func _on_btn_jogar_pressed() -> void:
	print("================================")
	print("JOGAR FOI CLICADO")
	print("Tentando carregar tela de carregamento...")
	
	var caminho := "res://scenes/interface/tela de carregamento.tscn"
	var erro := get_tree().change_scene_to_file(caminho)
	
	print("Resultado change_scene_to_file: ", erro)

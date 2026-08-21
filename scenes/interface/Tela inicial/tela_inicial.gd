extends Node2D

func _on_btn_jogar_pressed() -> void:
	
	print("O botão foi clicado!") # Se isso aparecer no Output, o clique está funcionando!
	
	get_tree().change_scene_to_file("res://scenes/interface/tela de carregamento.tscn")
	
func _on_config_pressed() -> void:
	$MenuConfig.visible = true

func _on_btn_cam_1_pressed() -> void:
	$MenuConfig/CONFIG/SetupPanel.visible = true
	$MenuConfig/CONFIG/AcessibilidadePanel.visible = false
	$MenuConfig/CONFIG/InformacoesPanel.visible = false

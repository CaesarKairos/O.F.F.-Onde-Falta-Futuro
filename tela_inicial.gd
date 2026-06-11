extends Node2D

func _on_btn_jogar_pressed() -> void:
	
	get_tree().change_scene_to_file( "res://scenes/levels/Cena 01 – Quarto de Lyanna.tscn"
)

func _on_config_pressed() -> void:
	$MenuConfig.visible = true


func _on_btn_cam_1_pressed() -> void:
	$MenuConfig/CONFIG/SetupPanel.visible = true
	$MenuConfig/CONFIG/AcessibilidadePanel.visible = false
	$MenuConfig/CONFIG/InformacoesPanel.visible = false

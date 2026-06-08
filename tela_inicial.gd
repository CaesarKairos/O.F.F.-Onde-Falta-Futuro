extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_jogar_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://scenes/levels/Cena 01 – Quarto de Lyanna.tscn"
	)


func _on_config_pressed() -> void:
	$"MenuConfig".visible = true





func _on_btn_cam_1_pressed() -> void:

	$"MenuConfig"/CONFIG/SetupPanel.visible = true
	$"MenuConfig"/CONFIG/AcessibilidadePanel.visible = false
	$"MenuConfig"/CONFIG/InformacoesPanel.visible = false

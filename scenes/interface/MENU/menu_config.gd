extends Node2D

var pagina_atual := 1
var camera_atual := 1


func _ready():
	mostrar_pagina(pagina_atual)


func mostrar_pagina(pagina: int):
	pagina_atual = pagina
	
	$SETUP/pag1.hide()
	$SETUP/pag2.hide()
	$SETUP/pag3.hide()
	
	if pagina == 1:
		$SETUP/pag1.show()
	elif pagina == 2:
		$SETUP/pag2.show()
	elif pagina == 3:
		$SETUP/pag3.show()


func _on_setinha_direita_pressed() -> void:
	if pagina_atual == 3:
		mostrar_pagina(1)
	else:
		mostrar_pagina(pagina_atual + 1)


func _on_setinha_esquerda_pressed() -> void:
	if pagina_atual == 1:
		mostrar_pagina(3)
	else:
		mostrar_pagina(pagina_atual - 1)


func _on_cam_1_pressed() -> void:
	mostrar_pagina(1)
	print("CAM 1")


func _on_cam_2_pressed() -> void:
	mostrar_pagina(2)
	print("CAM 2")


func _on_cam_3_pressed() -> void:
	mostrar_pagina(3)
	print("CAM 3")

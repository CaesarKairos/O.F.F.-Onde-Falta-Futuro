extends Node2D

func _ready():
	print("MENU CONFIG INICIADO")
	mostrar_pagina(1)

func mostrar_pagina(pagina: int):
	$SETUP/pag1.visible = pagina == 1
	$SETUP/pag2.visible = pagina == 2
	$SETUP/pag3.visible = pagina == 3

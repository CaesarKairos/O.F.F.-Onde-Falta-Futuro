extends Node2D

# Cena placeholder da rua (Capítulo 01, Cena 04).
# Quando a arte da rua estiver pronta, substitua esta cena pelo conteúdo real.
#
# ATENÇÃO: O Label com o texto "texto" nesta cena é TEMPORÁRIO.
# Ele deve ser substituído futuramente pelo conteúdo real da cena da rua.


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	# Esta é uma cena de "limbo"/transição: o Player é necessário
	# para que o SceneManager possa posicioná-lo no SpawnPoint,
	# mas não deve ser visível nem controlável pelo jogador.
	var player := get_node_or_null("Player")

	if player != null:

		player.hide()
		player.set_physics_process(false)
		player.set_process(false)

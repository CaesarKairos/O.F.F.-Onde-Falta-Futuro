extends Area2D

@onready var icon = $InteractionIcon
@onready var sprite_com_chave = $Sprite2D
@onready var sprite_sem_chave = $Semchave

var player_near := false
var collected := false

@export var message := "A chave do quartinho de bagunça. Sabia que estava aqui. Preciso dar uma geral lá depois para achar meu cartão de memória reserva."
@export var message_en := "The key to the junk room. I knew it was here. I need to tidy up in there later to find my spare memory card."
@export var message_es := "La llave del cuartito del desorden. Sabía que estaba aquí. Necesito ordenar un poco allí después para encontrar mi tarjeta de memoria de repuesto."


func _ready() -> void:
	# Verifica se a chave já foi coletada.
	collected = GameState.has_item("chave_bagunca")

	# --------------------------------------------------------
	# CONFIGURA O VISUAL INICIAL
	# --------------------------------------------------------

	if collected:
		# Chave já foi pega anteriormente.
		sprite_com_chave.visible = false
		sprite_sem_chave.visible = true
	else:
		# Chave ainda está no porta-chaves.
		sprite_com_chave.visible = true
		sprite_sem_chave.visible = false


	# --------------------------------------------------------
	# CONFIGURA ÍCONE DE INTERAÇÃO
	# --------------------------------------------------------

	icon.visible = false

	var parent = icon.get_parent()
	var parent_scale := Vector2.ONE

	if parent:
		parent_scale = parent.global_scale

	if parent_scale == Vector2.ZERO:
		parent_scale = Vector2.ONE

	icon.scale = (
		Vector2.ONE *
		GameConstants.INTERACTION_ICON_SCALE /
		parent_scale
	)


func _process(_delta: float) -> void:
	if collected:
		return

	if not player_near:
		return

	if not Input.is_action_just_pressed("interact"):
		return


	# --------------------------------------------------------
	# MOSTRA A MENSAGEM
	# --------------------------------------------------------

	var ui = get_tree().get_first_node_in_group("message_ui")

	if ui:
		ui.show_message(
			message,
			message_en,
			message_es
		)


	# --------------------------------------------------------
	# ADICIONA A CHAVE AO INVENTÁRIO
	# --------------------------------------------------------

	GameState.add_item("chave_bagunca")

	collected = true


	# --------------------------------------------------------
	# TROCA O SPRITE
	# --------------------------------------------------------

	sprite_com_chave.visible = false
	sprite_sem_chave.visible = true

	# Esconde o ícone de interação.
	icon.visible = false

	# O porta-chaves permanece na cena.


func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_near = true

		if not collected:
			icon.visible = true


func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_near = false
		icon.visible = false

extends Area2D

@onready var icon = $InteractionIcon
@onready var animated_sprite = get_node_or_null("AnimatedSprite2D")

var player_near = false

@export var message := "A chave do quartinho de bagunça. Sabia que estava aqui. Preciso dar uma geral lá depois para achar meu cartão de memória reserva."
@export var message_en := "The key to the junk room. I knew it was here. I need to tidy up in there later to find my spare memory card."
@export var message_es := "La llave del cuartito del desorden. Sabía que estaba aquí. Necesito ordenar un poco allí después para encontrar mi tarjeta de memoria de repuesto."

func _ready():

	# Se a chave já foi coletada, o porta-chaves não deve mais aparecer.
	if GameState.has_item("chave_bagunca"):
		queue_free()
		return

	icon.visible = false
	var parent = icon.get_parent()
	var parent_scale = Vector2.ONE
	if parent:
		parent_scale = parent.global_scale
	if parent_scale == Vector2.ZERO:
		parent_scale = Vector2.ONE
	icon.scale = Vector2.ONE * GameConstants.INTERACTION_ICON_SCALE / parent_scale

	if animated_sprite:
		animated_sprite.play()


func _process(_delta):

	if player_near and Input.is_action_just_pressed("interact"):

		var ui = get_tree().get_first_node_in_group("message_ui")

		if ui:
			ui.show_message(message, message_en, message_es)

		# Interação única: a chave vai pro inventário e o porta-chaves
		# desaparece da cena (não reaparece ao voltar).
		GameState.add_item("chave_bagunca")

		queue_free()


func _on_body_entered(body):

	if body.name == "Player":

		player_near = true
		icon.visible = true


func _on_body_exited(body):

	if body.name == "Player":

		player_near = false
		icon.visible = false
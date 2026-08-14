extends Area2D

@onready var icon = $InteractionIcon
@onready var animated_sprite = get_node_or_null("AnimatedSprite2D")

var player_near = false

@export var message := "Um cartão de memória reserva, jogado entre as coisas antigas. Agora sim eu posso sair pra rua."
@export var message_en := "A spare memory card, tossed among the old stuff. Now I can finally head out to the street."
@export var message_es := "Una tarjeta de memoria de repuesto, tirada entre las cosas viejas. Ahora sí puedo salir a la calle."

func _ready():

	# Se o cartão já foi coletado, ele não deve aparecer novamente.
	if GameState.has_item("cartao_memoria"):
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

		GameState.add_item("cartao_memoria")

		queue_free()


func _on_body_entered(body):

	if body.name == "Player":

		player_near = true
		icon.visible = true


func _on_body_exited(body):

	if body.name == "Player":

		player_near = false
		icon.visible = false
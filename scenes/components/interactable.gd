extends Area2D

@onready var icon = $InteractionIcon
@onready var animated_sprite = get_node_or_null("AnimatedSprite2D")

var player_near = false

@export var message = "Mensagem aqui"

func _ready():

	icon.visible = false

	if animated_sprite:
		animated_sprite.play()

func _process(delta):

	if player_near and Input.is_action_just_pressed("interact"):

		var ui = get_tree().get_first_node_in_group("message_ui")

		if ui:
			ui.show_message(message)

func _on_body_entered(body):

	if body.name == "Player":

		player_near = true
		icon.visible = true

func _on_body_exited(body):

	if body.name == "Player":

		player_near = false
		icon.visible = false

extends Area2D

@onready var icon = $InteractionIcon

var player_near = false

@export var message = "A porta está trancada."

func _ready():

	icon.visible = false

func _process(delta):

	if player_near and Input.is_action_just_pressed("interact"):

		var ui = get_tree().get_first_node_in_group("message_ui")

		ui.show_message(message)

func _on_body_entered(body):

	if body.name == "Player":

		player_near = true
		icon.visible = true

func _on_body_exited(body):

	if body.name == "Player":

		player_near = false
		icon.visible = false

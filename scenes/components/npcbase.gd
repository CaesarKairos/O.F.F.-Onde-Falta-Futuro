extends Area2D

@onready var icon = $InteractionIcon

var player_near = false
var already_interacted = false

func _ready():

	icon.visible = false

func _process(_delta):

	var ui = get_tree().get_first_node_in_group("message_ui")

	if ui and ui.is_message_open():
		return

	if player_near and Input.is_action_just_pressed("interact"):

		if not already_interacted:
			already_interacted = true
			icon.visible = false

		start_dialog()

func start_dialog():

	var ui = get_tree().get_first_node_in_group("message_ui")

	ui.show_dialog(
		"Olá",
		[
			"Oi",
			"Tchau"
		],
		[
			func(): dialog_who_am_i(),
			func(): close_dialog()
		]
	)

func dialog_who_am_i():

	var ui = get_tree().get_first_node_in_group("message_ui")

	ui.show_dialog(
		"Texto",
		[
			"Escolha 1",
			"Escolha 2"
		],
		[
			func(): close_dialog(),
			func(): close_dialog()
		]
	)

func close_dialog():

	var ui = get_tree().get_first_node_in_group("message_ui")

	ui.hide_dialog()

func _on_body_entered(body):

	if body.name == "Player":

		player_near = true

		if not already_interacted:
			icon.visible = true

func _on_body_exited(body):

	if body.name == "Player":

		player_near = false
		icon.visible = false

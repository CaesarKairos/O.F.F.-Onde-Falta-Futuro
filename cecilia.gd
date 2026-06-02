extends Area2D

@onready var icon = $InteractionIcon

var player_near = false

func _ready():

	icon.visible = false

func _process(delta):

	if player_near and Input.is_action_just_pressed("interact"):

		start_dialog()

func start_dialog():

	var ui = get_tree().get_first_node_in_group("message_ui")

	ui.show_dialog(
		"Olá viajante.",
		[
			"Quem é você?",
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
		"Meu nome é Cecília.",
		[
			"Prazer em conhecer você.",
			"Tchau"
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
		icon.visible = true

func _on_body_exited(body):

	if body.name == "Player":

		player_near = false
		icon.visible = false

extends Area2D

var player_near = false

func _process(delta):

	if player_near and Input.is_action_just_pressed("interact"):

		var ui = get_tree().get_first_node_in_group("message_ui")

		ui.show_message("Fiquei acordada até tarde ontem... Pensar tira o meu sono")

func _on_body_entered(body):

	if body.name == "Player":
		player_near = true

func _on_body_exited(body):

	if body.name == "Player":
		player_near = false

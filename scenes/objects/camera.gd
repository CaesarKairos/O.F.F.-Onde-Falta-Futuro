extends Area2D

@onready var icon = $InteractionIcon
@onready var animated_sprite = get_node_or_null("AnimatedSprite2D")

var player_near = false

@export var message := "Não posso sair sem ela; é como se fosse o meu terceiro olho. Mas... onde está o cartão de memória?"
@export var message_en := "I can't leave without it; it's like my third eye. But... where's the memory card?"

func _ready():

	# Se a câmera já foi coletada, ela não deve aparecer novamente.
	if GameState.has_item("camera"):
		queue_free()
		return

	icon.visible = false

	if animated_sprite:
		animated_sprite.play()


func _process(_delta):

	if player_near and Input.is_action_just_pressed("interact"):

		var ui = get_tree().get_first_node_in_group("message_ui")

		if ui:
			ui.show_message(message, message_en)

		GameState.add_item("camera")

		queue_free()


func _on_body_entered(body):

	if body.name == "Player":

		player_near = true
		icon.visible = true


func _on_body_exited(body):

	if body.name == "Player":

		player_near = false
		icon.visible = false

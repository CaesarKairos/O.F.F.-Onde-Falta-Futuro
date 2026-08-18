extends Area2D

@onready var icon = $InteractionIcon
@onready var animated_sprite = get_node_or_null("AnimatedSprite2D")

var player_near = false
var already_interacted = false

@export var message = "Mensagem aqui"
@export var message_en := ""
@export var message_es := ""

# Trava opcional: se preenchida, o item só pode ser interagido quando essa
# flag estiver setada no GameState. Vazio = comportamento original (sempre ativo).
@export var required_flag := ""

func _ready():

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

func _process(delta):

	# Se uma flag é exigida e ainda não foi setada, o item fica travado:
	# não interage e o ícone permanece escondido.
	if required_flag != "" and not GameState.has_flag(required_flag):
		icon.visible = false
		return

	if player_near and Input.is_action_just_pressed("interact"):

		if not already_interacted:
			already_interacted = true
			icon.visible = false

		var ui = get_tree().get_first_node_in_group("message_ui")

		if ui:
			ui.show_message(message, message_en, message_es)

func _on_body_entered(body):

	if body.name == "Player":

		player_near = true

		# Só mostra o ícone se não houver trava de flag pendente.
		if not already_interacted and (required_flag == "" or GameState.has_flag(required_flag)):
			icon.visible = true

func _on_body_exited(body):

	if body.name == "Player":

		player_near = false
		icon.visible = false

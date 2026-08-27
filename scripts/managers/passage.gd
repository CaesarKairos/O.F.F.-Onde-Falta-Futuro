extends Area2D

@onready var interaction_icon: AnimatedSprite2D = $InteractionIcon

@export_file("*.tscn")
var destination_scene := ""

@export
var destination_spawn := ""

# Trava opcional: se preenchida, a porta só funciona quando essa flag estiver setada.
@export var required_flag: String = ""

# Trava opcional por item: se preenchida, a porta só funciona quando o item
# estiver no inventário.
@export var required_item: String = ""

# Segundo item opcional.
@export var required_item_2: String = ""

# Se preenchida, quando essa flag estiver setada a porta fica aberta
# permanentemente (ignora as travas de flag/item).
@export var open_flag: String = ""

# Se preenchida, o item é removido do inventário ao usar a porta.
@export var consume_item: String = ""

# Se preenchida, essa flag é setada quando a porta é usada com sucesso.
@export var set_flag_on_use: String = ""

# Mensagens de feedback quando a porta está travada.
@export var locked_message_pt := ""
@export var locked_message_en := ""
@export var locked_message_es := ""

# Mensagens específicas por trava faltante. A variante "item1" é usada quando o
# `required_item` está faltando; "item2" quando o `required_item_2` está faltando.
# Se a variante correspondente estiver vazia, cai na mensagem genérica
# (`locked_message_*`) — o que mantém o comportamento atual para portas com uma
# única trava ou com `required_flag`.
@export var locked_message_item1_pt := ""
@export var locked_message_item1_en := ""
@export var locked_message_item1_es := ""
@export var locked_message_item2_pt := ""
@export var locked_message_item2_en := ""
@export var locked_message_item2_es := ""

var player_inside := false


func _ready() -> void:
	# O ícone começa escondido.
	interaction_icon.visible = false

	# Aplica o tamanho padrão do ícone de interação dinamicamente, dividindo
	# pela escala do nó pai, igual aos demais objetos interagíveis.
	var parent = interaction_icon.get_parent()
	var parent_scale = Vector2.ONE

	if parent:
		parent_scale = parent.global_scale

	if parent_scale == Vector2.ZERO:
		parent_scale = Vector2.ONE

	interaction_icon.scale = Vector2.ONE * GameConstants.INTERACTION_ICON_SCALE / parent_scale

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta):

	if not player_inside:
		return

	if Input.is_action_just_pressed("interact"):

		if destination_scene == "":
			return

		# Porta aberta permanentemente.
		var is_open := open_flag != "" and GameState.has_flag(open_flag)

		# Verifica required_flag.
		if not is_open and required_flag != "" and not GameState.has_flag(required_flag):

			_show_locked_message("req")
			return

		# Verifica required_item.
		if not is_open and required_item != "" and not GameState.has_item(required_item):

			_show_locked_message("item1")
			return

		# Verifica required_item_2.
		if not is_open and required_item_2 != "" and not GameState.has_item(required_item_2):

			_show_locked_message("item2")
			return

		# Consome o item.
		if consume_item != "" and GameState.has_item(consume_item):
			GameState.remove_item(consume_item)

		# Marca a porta como aberta.
		if set_flag_on_use != "":
			GameState.set_flag(set_flag_on_use)

		# Esconde o ícone antes de trocar de cena.
		interaction_icon.visible = false

		SceneManager.goto_scene(
			destination_scene,
			destination_spawn
		)


func _on_body_entered(body):

	if body.is_in_group("player"):
		player_inside = true

		# Mostra o ícone quando o Player entra na área.
		interaction_icon.visible = true


func _on_body_exited(body):

	if body.is_in_group("player"):
		player_inside = false

		# Esconde o ícone quando o Player sai da área.
		interaction_icon.visible = false


func _show_locked_message(which: String) -> void:

	var msg_pt := locked_message_pt
	var msg_en := locked_message_en
	var msg_es := locked_message_es

	# Escolhe a mensagem específica da trava que falhou, quando existir.
	if which == "item1" and locked_message_item1_pt != "":
		msg_pt = locked_message_item1_pt
		msg_en = locked_message_item1_en
		msg_es = locked_message_item1_es
	elif which == "item2" and locked_message_item2_pt != "":
		msg_pt = locked_message_item2_pt
		msg_en = locked_message_item2_en
		msg_es = locked_message_item2_es

	if msg_pt == "" and msg_en == "" and msg_es == "":
		return

	var ui = get_tree().get_first_node_in_group("message_ui")

	if ui:
		ui.show_message(
			msg_pt,
			msg_en,
			msg_es
		)

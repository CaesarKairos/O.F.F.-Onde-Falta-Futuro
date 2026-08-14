extends Area2D

@export_file("*.tscn")
var destination_scene := ""

@export
var destination_spawn := ""

# Trava opcional: se preenchida, a porta só funciona quando essa flag estiver setada.
@export var required_flag: String = ""

# Trava opcional por item: se preenchida, a porta só funciona quando o item
# estiver no inventário. Se required_flag também estiver preenchida, as duas
# condições valem em conjunto (AND).
@export var required_item: String = ""

# Segundo item opcional: se preenchido, também precisa estar no inventário
# (AND com required_item). Usado para a porta de saída (câmera + cartão).
@export var required_item_2: String = ""

# Se preenchida, quando essa flag estiver setada a porta fica aberta
# permanentemente (ignora as travas de flag/item).
@export var open_flag: String = ""

# Se preenchida, o item é removido do inventário ao usar a porta (ex.: chave).
@export var consume_item: String = ""

# Se preenchida, essa flag é setada quando a porta é usada com sucesso.
@export var set_flag_on_use: String = ""

# Mensagens de feedback (PT/EN/ES) exibidas quando a porta está travada.
@export var locked_message_pt := ""
@export var locked_message_en := ""
@export var locked_message_es := ""

var player_inside := false


func _ready() -> void:

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta):

	if !player_inside:
		return

	if Input.is_action_just_pressed("interact"):

		if destination_scene == "":
			return

		# Porta aberta permanentemente: se open_flag estiver setada, ignora travas.
		var is_open := open_flag != "" and GameState.has_flag(open_flag)

		# Se a porta exige uma flag e ela ainda não foi setada, bloqueia a transição.
		if not is_open and required_flag != "" and not GameState.has_flag(required_flag):

			if locked_message_pt != "" or locked_message_en != "" or locked_message_es != "":

				var ui = get_tree().get_first_node_in_group("message_ui")

				if ui:
					ui.show_message(
						locked_message_pt,
						locked_message_en,
						locked_message_es
					)

			return

		# Se a porta exige um item (ou dois) e ele ainda não está no inventário, bloqueia.
		if not is_open and required_item != "" and not GameState.has_item(required_item):

			if locked_message_pt != "" or locked_message_en != "" or locked_message_es != "":

				var ui = get_tree().get_first_node_in_group("message_ui")

				if ui:
					ui.show_message(
						locked_message_pt,
						locked_message_en,
						locked_message_es
					)

			return

		if not is_open and required_item_2 != "" and not GameState.has_item(required_item_2):

			if locked_message_pt != "" or locked_message_en != "" or locked_message_es != "":

				var ui = get_tree().get_first_node_in_group("message_ui")

				if ui:
					ui.show_message(
						locked_message_pt,
						locked_message_en,
						locked_message_es
					)

			return

		# Consome o item (ex.: chave) e marca a porta como aberta permanentemente.
		if consume_item != "" and GameState.has_item(consume_item):
			GameState.remove_item(consume_item)

		if set_flag_on_use != "":
			GameState.set_flag(set_flag_on_use)

		SceneManager.goto_scene(
			destination_scene,
			destination_spawn
		)


func _on_body_entered(body):

	if body.is_in_group("player"):
		player_inside = true


func _on_body_exited(body):

	if body.is_in_group("player"):
		player_inside = false

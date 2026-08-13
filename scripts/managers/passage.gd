extends Area2D

@export_file("*.tscn")
var destination_scene := ""

@export
var destination_spawn := ""

# Trava opcional: se preenchida, a porta só funciona quando essa flag estiver setada.
@export var required_flag: String = ""

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

		# Se a porta exige uma flag e ela ainda não foi setada, bloqueia a transição.
		if required_flag != "" and not GameState.has_flag(required_flag):

			if locked_message_pt != "" or locked_message_en != "" or locked_message_es != "":

				var ui = get_tree().get_first_node_in_group("message_ui")

				if ui:
					ui.show_message(
						locked_message_pt,
						locked_message_en,
						locked_message_es
					)

			return

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

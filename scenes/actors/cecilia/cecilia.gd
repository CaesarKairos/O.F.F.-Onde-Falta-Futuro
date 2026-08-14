extends Area2D

@onready var icon = $InteractionIcon
@onready var sprite = $AnimatedSprite2D

@export var dialogue_path := "res://data/dialogues/chapter_01/chapter_01_scene_02.json"
@export var start_dialogue_id := "cecilia_001"

# Segunda interação: se preenchido, a segunda vez que o jogador interagir
# (após o primeiro diálogo terminar) inicia este nó do mesmo JSON.
@export var second_dialogue_id := ""

# Progressão configurável por instância (valores padrão reproduzem o comportamento da Sala).
@export var required_story_stage := 1
@export var show_after_flag := ""       # vazio = sempre visível (comportamento atual)
@export var hide_after_flag := "talked_to_cecilia"

# Se true, o _process() remove a Cecília assim que hide_after_flag for setada
# (usado na Cozinha, para ela sumir ao fim do diálogo). Se false, ela permanece
# na cena até o jogador sair (usado na Sala — o _ready() cuida de não reaparecer).
@export var hide_during_dialogue := true

# Follow-up automático: após o diálogo terminar, aguarda followup_delay segundos,
# mostra followup_message via MessageUI e inicia followup_dialogue_path.
@export var followup_dialogue_path := ""
@export var followup_dialogue_id := ""
@export var followup_delay := 2.0
@export var followup_message_pt := ""
@export var followup_message_en := ""
@export var followup_message_es := ""
@export var followup_trigger_flag := ""

var player_near := false
var already_interacted := false
var second_dialogue_played := false
var _was_dialogue_active := false
var _followup_started := false


func _ready() -> void:

	if hide_after_flag != "" and GameState.has_flag(hide_after_flag):
		queue_free()
		return

	if show_after_flag != "" and not GameState.has_flag(show_after_flag):
		queue_free()
		return

	icon.visible = false
	var parent = icon.get_parent()
	var parent_scale = Vector2.ONE
	if parent:
		parent_scale = parent.global_scale
	if parent_scale == Vector2.ZERO:
		parent_scale = Vector2.ONE
	icon.scale = Vector2.ONE * GameConstants.INTERACTION_ICON_SCALE / parent_scale

	if sprite:
		sprite.play("idle")

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta):

	# Se a flag de "sumir" foi setada durante o diálogo (ex.: received_paulo_call),
	# remove a Cecília imediatamente — sem precisar recarregar a cena.
	# Na Sala (hide_during_dialogue = false), ela permanece até o jogador sair.
	if hide_during_dialogue and hide_after_flag != "" and GameState.has_flag(hide_after_flag):
		queue_free()
		return

	if sprite and sprite.animation != "idle":
		sprite.play("idle")

	# Detecta o fim de uma interação para liberar a segunda (se houver).
	if DialogueManager.dialogue_active:
		_was_dialogue_active = true
	else:
		if _was_dialogue_active:
			_was_dialogue_active = false

			# Se a segunda interação ainda não ocorreu, reaparece o ícone
			# para que o jogador possa conversar novamente (fala da família).
			if already_interacted and not second_dialogue_played and second_dialogue_id != "" and player_near:
				icon.visible = true

	_check_followup()

	var ui = get_tree().get_first_node_in_group("message_ui")

	if ui and ui.is_message_open():
		return

	if !player_near:
		return

	if !Input.is_action_just_pressed("interact"):
		return

	if DialogueManager.dialogue_active:
		return

	# A primeira interação exige o story_stage correto; a segunda (fala da
	# família, por exemplo) fica livre após o primeiro diálogo ter ocorrido.
	if !already_interacted and GameState.story_stage != required_story_stage:
		return

	# Primeira interação: inicia o diálogo principal (ex.: kitchen_001).
	if !already_interacted:
		already_interacted = true
		icon.visible = false

		DialogueManager.start_dialog(
			dialogue_path,
			start_dialogue_id
		)
		return

	# Segunda interação: usa o nó alternativo (ex.: fala da família) uma única vez.
	if second_dialogue_id != "" and not second_dialogue_played:
		second_dialogue_played = true
		icon.visible = false

		DialogueManager.start_dialog(
			dialogue_path,
			second_dialogue_id
		)
		return

	# Interações seguintes: repete o diálogo principal.
	DialogueManager.start_dialog(
		dialogue_path,
		start_dialogue_id
	)


func _check_followup() -> void:

	if followup_dialogue_path == "" or _followup_started:
		return

	if DialogueManager.dialogue_active:
		_was_dialogue_active = true
		return

	if _was_dialogue_active:
		_was_dialogue_active = false

		if followup_trigger_flag == "" or GameState.has_flag(followup_trigger_flag):
			_followup_started = true
			_run_followup()


func _run_followup() -> void:

	# Pequena pausa entre o fim da conversa e a mensagem do telefone.
	await get_tree().create_timer(followup_delay).timeout

	var ui = get_tree().get_first_node_in_group("message_ui")

	if ui and followup_message_pt != "":
		ui.show_message(followup_message_pt, followup_message_en, followup_message_es)

		# Aguarda o jogador fechar a mensagem antes de iniciar a ligação.
		while ui.is_message_open():
			await get_tree().process_frame

	DialogueManager.start_dialog(followup_dialogue_path, followup_dialogue_id)


func _on_body_entered(body):

	if body.is_in_group("player"):

		player_near = true

		if !already_interacted:
			icon.visible = true


func _on_body_exited(body):

	if body.is_in_group("player"):

		player_near = false
		icon.visible = false

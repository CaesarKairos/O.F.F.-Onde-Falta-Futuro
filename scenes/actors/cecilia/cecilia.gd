extends Area2D

@onready var icon = $InteractionIcon
@onready var sprite = $AnimatedSprite2D

@export var dialogue_path := "res://data/dialogues/chapter_01/chapter_01_scene_02.json"
@export var start_dialogue_id := "cecilia_001"

# Segunda interação: se preenchido, a segunda vez que o jogador interagir
# (após o primeiro diálogo terminar) inicia este nó do mesmo JSON.
@export var second_dialogue_id := ""

# Progressão configurável por instância.
@export var required_story_stage := 1
@export var show_after_flag := ""       # vazio = sempre visível
@export var hide_after_flag := "talked_to_cecilia"

# Se true, o _process() remove a Cecília assim que hide_after_flag for setada.
# Se false, ela permanece na cena até o jogador sair.
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
	# Se a flag que faz a Cecília desaparecer já estiver definida,
	# remove esta instância da cena.
	if hide_after_flag != "" and GameState.has_flag(hide_after_flag):
		queue_free()
		return

	# Se esta instância só deve aparecer depois de uma determinada flag
	# e ela ainda não foi definida, remove a instância.
	if show_after_flag != "" and not GameState.has_flag(show_after_flag):
		queue_free()
		return

	# Configura o ícone de interação.
	icon.visible = false

	var parent = icon.get_parent()
	var parent_scale = Vector2.ONE

	if parent:
		parent_scale = parent.global_scale

	if parent_scale == Vector2.ZERO:
		parent_scale = Vector2.ONE

	icon.scale = Vector2.ONE * GameConstants.INTERACTION_ICON_SCALE / parent_scale

	# Inicia a animação da Cecília.
	if sprite:
		sprite.play("idle")

	# Conecta os sinais da Area2D.
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	# Trava a interação com a Cecília depois que o fluxo desta instância já foi
	# concluído: ou quando a flag de "esconder" (hide_after_flag, usada pela
	# instância da sala via "talked_to_cecilia") estiver setada, ou quando o
	# fluxo da cozinha ("talked_to_cecilia_kitchen") terminar.
	var cecilia_flow_done := (
		(hide_after_flag != "" and GameState.has_flag(hide_after_flag))
		or GameState.has_flag("talked_to_cecilia_kitchen")
	)

	if cecilia_flow_done:
		icon.visible = false
		return

	# O jogador precisa estar dentro da área.
	if not player_near:
		return

	# Só interage quando o jogador aperta o botão configurado.
	if not Input.is_action_just_pressed("interact"):
		return

	# Não permite iniciar outro diálogo enquanto um diálogo já estiver ativo.
	if DialogueManager.dialogue_active:
		return

	# Primeira interação.
	if not already_interacted:
		already_interacted = true
		icon.visible = false

		DialogueManager.start_dialog(
			dialogue_path,
			start_dialogue_id
		)

		return

	# Segunda interação.
	# Só acontece se um ID de segundo diálogo foi configurado
	# e ele ainda não tiver sido executado.
	if second_dialogue_id != "" and not second_dialogue_played:
		second_dialogue_played = true
		icon.visible = false

		DialogueManager.start_dialog(
			dialogue_path,
			second_dialogue_id
		)

		return


func _on_body_entered(body: Node2D) -> void:
	# Verifica se quem entrou na área é o jogador.
	if body.is_in_group("player"):
		player_near = true

		# Só mostra o ícone se não houver um diálogo acontecendo.
		if not DialogueManager.dialogue_active:
			icon.visible = true


func _on_body_exited(body: Node2D) -> void:
	# Verifica se quem saiu da área é o jogador.
	if body.is_in_group("player"):
		player_near = false
		icon.visible = false

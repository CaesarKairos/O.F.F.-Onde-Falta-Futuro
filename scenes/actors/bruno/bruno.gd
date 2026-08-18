extends Area2D

@onready var icon = $InteractionIcon

@export var dialogue_path := "res://data/dialogues/chapter_01/chapter_01_scene_01.json"
@export var start_dialogue_id := "dream_001"

var movement_locked
var player_near = false
var already_interacted = false

func _ready() -> void:

	# Se já conversou com o Bruno, ele não aparece mais.
	if GameState.has_flag("talked_to_bruno"):
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


func _process(_delta: float) -> void:

	var ui = get_tree().get_first_node_in_group("message_ui")

	if ui and ui.is_message_open():
		return

	if player_near and Input.is_action_just_pressed("interact"):

		if DialogueManager.dialogue_active:
			return

		# Não permite interagir enquanto o Bruno ainda está caminhando
		# até o target (cutscene de chegada em andamento).
		if movement_locked:
			return

		if GameState.story_stage != 0:
			return

		if not already_interacted:
			already_interacted = true
			icon.visible = false

		DialogueManager.start_dialog(
			dialogue_path,
			start_dialogue_id
		)


func _on_body_entered(body) -> void:

	if body.name == "Player":

		player_near = true

		if not already_interacted:
			icon.visible = true


func _on_body_exited(body) -> void:

	if body.name == "Player":

		player_near = false
		icon.visible = false

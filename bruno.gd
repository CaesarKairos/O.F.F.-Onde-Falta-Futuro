extends Area2D

@onready var icon = $InteractionIcon

@export var dialogue_path := "res://data/dialogues/chapter_01/chapter_01_scene_01.json"
@export var start_dialogue_id := "dream_001"

var player_near = false
var already_interacted = false

func _ready() -> void:

	icon.visible = false

func _process(_delta: float) -> void:

	var ui = get_tree().get_first_node_in_group("message_ui")

	if ui and ui.is_message_open():
		return

	if player_near and Input.is_action_just_pressed("interact"):

		if DialogueManager.dialogue_active:
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

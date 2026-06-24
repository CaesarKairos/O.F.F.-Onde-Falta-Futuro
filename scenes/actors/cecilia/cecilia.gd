extends Area2D

@onready var icon = $InteractionIcon

var player_near := false

func _ready() -> void:
	icon.visible = false

func _process(_delta: float) -> void:

	if not player_near:
		return

	if not Input.is_action_just_pressed("interact"):
		return

	if DialogueManager.dialogue_active:
		return

	if GameState.story_stage != 1:
		return

	DialogueManager.start_dialog(
		"res://data/dialogues/chapter_01/chapter_01_scene_02.json",
		"cecilia_001"
	)

func _on_body_entered(body):

	if body.name == "Player":
		player_near = true
		icon.visible = true

func _on_body_exited(body):

	if body.name == "Player":
		player_near = false
		icon.visible = false

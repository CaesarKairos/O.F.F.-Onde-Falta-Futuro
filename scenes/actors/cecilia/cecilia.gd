extends Area2D

@onready var icon = $InteractionIcon
@onready var sprite = $AnimatedSprite2D

@export var dialogue_path := "res://data/dialogues/chapter_01/chapter_01_scene_02.json"
@export var start_dialogue_id := "cecilia_001"

var player_near := false
var already_interacted := false


func _ready() -> void:

	print("=== Cecilia Ready ===")

	if GameState.has_flag("talked_to_cecilia"):
		print("Cecilia removida")
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

	if sprite and sprite.animation != "idle":
		sprite.play("idle")

	if player_near:
		print("Player perto")

	var ui = get_tree().get_first_node_in_group("message_ui")

	if ui and ui.is_message_open():
		return

	if !player_near:
		return

	if !Input.is_action_just_pressed("interact"):
		return

	print("Tentando conversar")

	if DialogueManager.dialogue_active:
		return

	if GameState.story_stage != 1:
		print("Story Stage errado:", GameState.story_stage)
		return

	if !already_interacted:
		already_interacted = true
		icon.visible = false

	print("Iniciando diálogo")

	DialogueManager.start_dialog(
		dialogue_path,
		start_dialogue_id
	)


func _on_body_entered(body):

	print("Entrou:", body.name)

	if body.is_in_group("player"):

		print("PLAYER DETECTADO")

		player_near = true

		if !already_interacted:
			icon.visible = true


func _on_body_exited(body):

	print("Saiu:", body.name)

	if body.is_in_group("player"):

		player_near = false
		icon.visible = false

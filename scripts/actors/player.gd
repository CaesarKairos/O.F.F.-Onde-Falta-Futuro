extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var sprite = $AnimatedSprite2D

func _ready() -> void:

	sprite.play("idle")

func _physics_process(delta: float) -> void:

	# Avançar diálogo com ESPAÇO (ação skip)
	if Input.is_action_just_pressed("skip"):

		if DialogueManager.can_continue():
			DialogueManager.next_dialog()

	var ui = get_tree().get_first_node_in_group("message_ui")

	# Travar movimento durante diálogos ou mensagens
	if (ui and ui.is_message_open()) or DialogueManager.dialogue_active:

		velocity.x = 0

		if sprite.animation != "idle":
			sprite.play("idle")

		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("left", "right")

	if direction:

		velocity.x = direction * SPEED

		if direction < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false

		if sprite.animation != "walking":
			sprite.play("walking")

	else:

		velocity.x = move_toward(velocity.x, 0, SPEED)

		if sprite.animation != "idle":
			sprite.play("idle")

	move_and_slide()

extends Node2D

@onready var bruno = $bruno
@onready var target = $BrunoTarget
@onready var sprite = $bruno/AnimatedSprite2D

var move_speed := 150.0
var moving := true


func _ready():

	# Se o Bruno já foi embora, não executa a cutscene.
	if GameState.has_flag("talked_to_bruno"):
		moving = false
		return

	print("BRUNO:", bruno.global_position)
	print("TARGET:", target.global_position)

	# Se a cutscene de caminhada já rodou antes (mas o Bruno ainda não foi
	# embora), ele aparece já parado no BrunoTarget, sem repetir a animação.
	if GameState.has_flag("bruno_chegou"):
		moving = false
		bruno.global_position = target.global_position
		bruno.movement_locked = false
		sprite.play("idle")
		return

	bruno.movement_locked = true
	sprite.play("walking")


func _process(delta):

	if !moving:
		return

	# Caso o Bruno tenha sido destruído.
	if !is_instance_valid(bruno):
		moving = false
		return

	var direction = target.global_position - bruno.global_position

	if direction.length() < 2:

		moving = false
		sprite.play("idle")
		bruno.movement_locked = false

		# Registra que a cutscene de caminhada do Bruno já foi exibida,
		# para que ela não se repita em reentradas na cena.
		GameState.set_flag("bruno_chegou")

		return

	direction = direction.normalized()

	bruno.global_position += direction * move_speed * delta

	if direction.x > 0:
		sprite.flip_h = false
	elif direction.x < 0:
		sprite.flip_h = true

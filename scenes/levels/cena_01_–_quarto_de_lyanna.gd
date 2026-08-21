extends Node2D

@onready var bruno = $bruno
@onready var target = $BrunoTarget
@onready var sprite = $bruno/AnimatedSprite2D
@onready var player = $Player
@onready var sound_player = $BrunoSound

var move_speed := 150.0
var moving := true
var leaving := false
var start_position: Vector2


func _ready():
	
	# Guarda a posição inicial real do Bruno (porta), para a cutscene de ida embora.
	start_position = bruno.global_position

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

	# Som placeholder: Bruno entrando no quarto.
	_play_sound()


func _process(delta):

	# Trava o movimento do player até o jogador ter falado com o Bruno.
	if is_instance_valid(player):
		player.movement_locked = not GameState.has_flag("talked_to_bruno")

	# Caso o Bruno tenha sido destruído.
	if !is_instance_valid(bruno):
		moving = false
		leaving = false
		return

	# Depois que o diálogo com o Bruno termina (flag setada pelo DialogueManager),
	# inicia a cutscene de ida embora — da Lyanna de volta à porta.
	if not leaving and not moving and GameState.has_flag("talked_to_bruno"):
		leaving = true
		bruno.movement_locked = true
		sprite.play("walking")
		# Som placeholder: Bruno saindo do quarto.
		_play_sound()

	if leaving:
		_process_leaving(delta)
		return

	if !moving:
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


func _process_leaving(delta):

	var direction = start_position - bruno.global_position

	if direction.length() < 2:

		# Chegou na porta: desaparece.
		bruno.queue_free()
		leaving = false
		moving = false
		return

	direction = direction.normalized()

	bruno.global_position += direction * move_speed * delta

	if direction.x > 0:
		sprite.flip_h = false
	elif direction.x < 0:
		sprite.flip_h = true


func _play_sound():

	if sound_player and sound_player.stream:
		sound_player.play()
		
	

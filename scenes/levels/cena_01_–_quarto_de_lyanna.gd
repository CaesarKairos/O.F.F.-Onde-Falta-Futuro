extends Node2D

@onready var bruno = $bruno
@onready var target = $BrunoTarget
@onready var sprite = $bruno/AnimatedSprite2D

var move_speed := 80.0
var moving := true

func _ready():
	print("BRUNO:", bruno.global_position)
	print("TARGET:", target.global_position)

	bruno.movement_locked = true
	sprite.play("walking")


func _process(delta):
	if not moving:
		return

	var direction = target.global_position - bruno.global_position

	# chegou no destino
	if direction.length() < 2:
		moving = false
		sprite.play("idle")
		bruno.movement_locked = false
		return

	direction = direction.normalized()

	# movimento reto e estável
	bruno.global_position += direction * move_speed * delta

	# animação virada corretamente
	if direction.x > 0:
		sprite.flip_h = false
	elif direction.x < 0:
		sprite.flip_h = true

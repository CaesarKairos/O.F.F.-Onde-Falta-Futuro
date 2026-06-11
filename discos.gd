extends Area2D

@onready var icon = $InteractionIcon

@onready var disco1 = $Disco1
@onready var disco2 = $Disco2
@onready var disco3 = $Disco3
@onready var disco4 = $Disco4

var player_near = false

var discos = []

func _ready():

	icon.visible = false

	discos = [
		disco1,
		disco2,
		disco3,
		disco4
	]

	_update_stack()

func _process(_delta):

	if player_near and Input.is_action_just_pressed("interact"):

		rotate_discs()

func rotate_discs():

	if discos.is_empty():
		return

	var primeiro = discos.pop_front()

	discos.append(primeiro)

	_update_stack()

func _update_stack():

	for i in range(discos.size()):

		var disco = discos[i]

		# Mostra uma fresta dos discos de trás acima do da frente
		disco.position.y = -i * 20

		# Mantém a ordem da pilha
		disco.z_index = 3 - i

func _on_body_entered(body):

	if body.name == "Player":

		player_near = true
		icon.visible = true

func _on_body_exited(body):

	if body.name == "Player":

		player_near = false
		icon.visible = false

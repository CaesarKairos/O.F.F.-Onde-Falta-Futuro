extends Node2D

const COVER_SIZE := 500.0
const STACK_OFFSET := 16.0
const INTERACTION_DISTANCE := 70.0

@onready var icon = $InteractionIcon

@onready var disco1 = $Disco1
@onready var disco2 = $Disco2
@onready var disco3 = $Disco3
@onready var disco4 = $Disco4

var player_near = false

var discos = []

func _ready():

	icon.visible = false
	var parent = icon.get_parent()
	var parent_scale = Vector2.ONE
	if parent:
		parent_scale = parent.global_scale
	if parent_scale == Vector2.ZERO:
		parent_scale = Vector2.ONE
	icon.scale = Vector2.ONE * GameConstants.INTERACTION_ICON_SCALE / parent_scale

	discos = [
		disco1,
		disco2,
		disco3,
		disco4
	]

	_update_stack()

func _process(_delta):
	var player = get_tree().get_first_node_in_group("player")
	player_near = player != null and global_position.distance_to(player.global_position) <= INTERACTION_DISTANCE
	icon.visible = player_near

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
		var texture_size = disco.texture.get_size()
		disco.scale = Vector2(
			COVER_SIZE / texture_size.x,
			COVER_SIZE / texture_size.y
		)

		if i == 0:
			disco.region_enabled = false
			disco.position = Vector2.ZERO
		else:
			# Renderiza só a faixa exposta. O restante da capa traseira nem é
			# desenhado, então não pode vazar pelas laterais ou pela base.
			var strip_height: float = texture_size.y * STACK_OFFSET / COVER_SIZE
			disco.region_enabled = true
			disco.region_filter_clip_enabled = true
			disco.region_rect = Rect2(0, 0, texture_size.x, strip_height)
			disco.position = Vector2(
				0,
				-i * STACK_OFFSET - COVER_SIZE / 2.0 + STACK_OFFSET / 2.0
			)

		# Mantém a ordem da pilha
		disco.z_index = 3 - i

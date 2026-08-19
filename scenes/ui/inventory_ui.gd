extends CanvasLayer


# =========================================================
# CONFIGURAÇÃO
# =========================================================

const MAX_SLOTS: int = 6


# =========================================================
# REFERÊNCIAS DA UI
# =========================================================

@onready var inventory_panel: Panel = $InventoryPanel
@onready var slots_container: HBoxContainer = $InventoryPanel/SlotsContainer


# =========================================================
# ÍCONES DOS ITENS
# =========================================================

var item_icons := {

	"camera":
		preload("res://assets/art/environment/props/camera3.png"),

	"cartao_memoria":
		preload("res://assets/art/environment/props/cartao de memory.png"),

	"chave_bagunca":
		preload("res://assets/art/environment/props/chave.png")

}


# =========================================================
# ESTADO
# =========================================================

var inventory_open: bool = false


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	inventory_panel.visible = false

	configure_slot_icons()

	update_inventory()


# =========================================================
# INPUT
# =========================================================

func _process(_delta: float) -> void:

	if Input.is_action_just_pressed("inventory"):

		toggle_inventory()


# =========================================================
# ABRIR / FECHAR
# =========================================================

func toggle_inventory() -> void:

	inventory_open = not inventory_open

	inventory_panel.visible = inventory_open

	if inventory_open:

		update_inventory()


# =========================================================
# ATUALIZAR INVENTÁRIO
# =========================================================

func configure_slot_icons() -> void:

	for slot in slots_container.get_children():

		var icon := slot.get_node_or_null("TextureRect") as TextureRect

		if icon == null:
			continue

		# Faz o ícone preencher o slot inteiro
		icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		icon.size_flags_vertical = Control.SIZE_EXPAND_FILL

		# Centraliza a textura dentro do ícone mantendo a proporção
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED


func update_inventory() -> void:

	configure_slot_icons()

	var slots = slots_container.get_children()


	# ---------------------------------------------------------
	# LIMPA TODOS OS SLOTS
	# ---------------------------------------------------------

	for slot in slots:

		var icon := slot.get_node_or_null("TextureRect") as TextureRect

		if icon:

			icon.texture = null
			icon.visible = false


	# ---------------------------------------------------------
	# COLOCA OS ITENS NOS SLOTS
	# ---------------------------------------------------------

	var item_count: int = mini(
		GameState.inventory.size(),
		slots.size()
	)


	for i in range(item_count):

		var item_name: String = GameState.inventory[i]

		var slot = slots[i]

		var icon := slot.get_node_or_null("TextureRect") as TextureRect


		# -----------------------------------------------------
		# SEGURANÇA
		# -----------------------------------------------------

		if icon == null:

			print(
				"Inventário: Slot sem Icon: ",
				slot.name
			)

			continue


		# -----------------------------------------------------
		# PROCURA O ÍCONE
		# -----------------------------------------------------

		if item_icons.has(item_name):

			icon.texture = item_icons[item_name]
			icon.visible = true

		else:

			print(
				"Inventário: ícone não encontrado para: ",
				item_name
			)

			icon.visible = false

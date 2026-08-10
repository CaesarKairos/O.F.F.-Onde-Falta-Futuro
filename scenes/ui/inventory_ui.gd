extends CanvasLayer


# =========================================================
# CONFIGURAÇÃO
# =========================================================

const MAX_SLOTS := 6


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

	"memory_card":
		preload("res://assets/art/environment/props/camera3.png")

}


# =========================================================
# ESTADO
# =========================================================

var inventory_open := false


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	inventory_panel.visible = false

	_create_slots()


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

func update_inventory() -> void:

	var slots = slots_container.get_children()

	for i in range(slots.size()):

		var slot = slots[i]

		var icon: TextureRect = slot.get_node("Icon")

		icon.texture = null


	# Coloca os itens existentes nos slots

	for i in range(
		min(GameState.inventory.size(), slots.size())
	):

		var item_name: String = GameState.inventory[i]

		var slot = slots[i]

		var icon: TextureRect = slot.get_node("Icon")

		if item_icons.has(item_name):

			icon.texture = item_icons[item_name]

			icon.visible = true

		else:

			print(
				"Inventário: ícone não encontrado para:",
				item_name
			)

			icon.visible = false


# =========================================================
# CRIAR SLOTS
# =========================================================

func _create_slots() -> void:

	for child in slots_container.get_children():

		child.queue_free()


	for i in range(MAX_SLOTS):

		var slot := Panel.new()

		slot.name = "Slot%d" % (i + 1)

		slot.custom_minimum_size = Vector2(64, 64)

		var icon := TextureRect.new()

		icon.name = "Icon"

		icon.set_anchors_and_offsets_preset(
			Control.PRESET_FULL_RECT
		)

		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE

		icon.visible = false

		slot.add_child(icon)

		slots_container.add_child(slot)

extends CanvasLayer

@onready var panel = $Panel
@onready var label = $Panel/Label
@onready var choices = $Panel/ChoicesLabel

var current_options = []

func _ready():

	panel.visible = false

# TEXTO SIMPLES
func show_message(texto):

	panel.visible = true

	label.text = texto

	choices.text = ""

	await get_tree().create_timer(2).timeout

	panel.visible = false

# DIÁLOGO COM OPÇÕES
func show_dialog(texto, options):

	panel.visible = true

	label.text = texto

	current_options = options

	choices.text = ""

	for i in range(options.size()):

		choices.text += str(i + 1) + " - " + options[i] + "\n"

func hide_dialog():

	panel.visible = false

extends CanvasLayer

@onready var dialogue_box = $DialogueBox
@onready var dialogue_text = $DialogueBox/DialogueText

@onready var choice1 = $DialogueBox/ChoicesContainer/Choice1
@onready var choice2 = $DialogueBox/ChoicesContainer/Choice2
@onready var choice3 = $DialogueBox/ChoicesContainer/Choice3

var current_callbacks = []

func _ready():

	dialogue_box.visible = false

	choice1.pressed.connect(_on_choice_1)
	choice2.pressed.connect(_on_choice_2)
	choice3.pressed.connect(_on_choice_3)

func show_message(texto):

	dialogue_box.visible = true

	dialogue_text.text = texto

	choice1.visible = false
	choice2.visible = false
	choice3.visible = false

	await get_tree().create_timer(2).timeout

	dialogue_box.visible = false

func show_dialog(texto, options, callbacks):

	dialogue_box.visible = true

	dialogue_text.text = texto

	current_callbacks = callbacks

	var buttons = [choice1, choice2, choice3]

	for i in range(buttons.size()):

		if i < options.size():

			buttons[i].visible = true
			buttons[i].text = options[i]

		else:

			buttons[i].visible = false

func hide_dialog():

	dialogue_box.visible = false

func _on_choice_1():

	if current_callbacks.size() > 0:

		current_callbacks[0].call()

func _on_choice_2():

	if current_callbacks.size() > 1:

		current_callbacks[1].call()

func _on_choice_3():

	if current_callbacks.size() > 2:

		current_callbacks[2].call()

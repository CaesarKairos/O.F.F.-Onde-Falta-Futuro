extends CanvasLayer

@onready var dialogue_box = $DialogueBox
@onready var dialogue_text = $DialogueBox/DialogueText

@onready var choice1 = $DialogueBox/ChoicesContainer/Choice1
@onready var choice2 = $DialogueBox/ChoicesContainer/Choice2
@onready var choice3 = $DialogueBox/ChoicesContainer/Choice3

func _ready() -> void:
	dialogue_box.visible = false
	_hide_choices()

	choice1.pressed.connect(_on_choice_1)
	choice2.pressed.connect(_on_choice_2)
	choice3.pressed.connect(_on_choice_3)

func show_message(texto: String) -> void:
	dialogue_box.visible = true
	dialogue_text.text = texto
	_hide_choices()

	await get_tree().create_timer(2).timeout
	dialogue_box.visible = false

func show_dialogue(texto: String) -> void:
	dialogue_box.visible = true
	dialogue_text.text = texto
	_hide_choices()

func show_choices(texto: String, options: Array) -> void:
	dialogue_box.visible = true
	dialogue_text.text = texto

	var buttons = [choice1, choice2, choice3]

	for i in range(buttons.size()):
		if i < options.size():
			buttons[i].visible = true
			buttons[i].text = options[i]["text"]
		else:
			buttons[i].visible = false

func hide_dialog() -> void:
	_hide_choices()
	dialogue_box.visible = false

func _hide_choices() -> void:
	choice1.visible = false
	choice2.visible = false
	choice3.visible = false

func _on_choice_1() -> void:
	DialogueManager.select_choice(0)

func _on_choice_2() -> void:
	DialogueManager.select_choice(1)

func _on_choice_3() -> void:
	DialogueManager.select_choice(2)

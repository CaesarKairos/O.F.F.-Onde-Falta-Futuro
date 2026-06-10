extends CanvasLayer

@onready var dialogue_box = $DialogueBox
@onready var dialogue_text = $DialogueBox/DialogueText
@onready var portrait = $DialogueBox/Portrait
@onready var choices_container = $DialogueBox/ChoicesContainer

@onready var choice1 = $DialogueBox/ChoicesContainer/Choice1
@onready var choice2 = $DialogueBox/ChoicesContainer/Choice2
@onready var choice3 = $DialogueBox/ChoicesContainer/Choice3

var portraits = {
	"bruno": preload("res://assets/art/characters/portraits/bruno icon.png"),
	"lyanna": preload("res://assets/art/characters/portraits/lyanna icon.png")
}

func _ready() -> void:

	dialogue_box.visible = false
	portrait.visible = false

	_hide_choices()

	choice1.pressed.connect(_on_choice_1)
	choice2.pressed.connect(_on_choice_2)
	choice3.pressed.connect(_on_choice_3)

func _update_choices_position() -> void:

	await get_tree().process_frame

	choices_container.position.y = (
		dialogue_text.position.y +
		dialogue_text.get_content_height() +
		20
	)

func set_portrait(character_name: String) -> void:

	character_name = character_name.to_lower()

	if portraits.has(character_name):

		portrait.texture = portraits[character_name]
		portrait.visible = true

	else:

		portrait.visible = false

func show_message(texto: String) -> void:

	dialogue_box.visible = true
	dialogue_text.text = texto

	portrait.visible = false

	_hide_choices()

	await _update_choices_position()

	await get_tree().create_timer(4).timeout

	dialogue_box.visible = false

func show_dialogue(texto: String) -> void:

	dialogue_box.visible = true
	dialogue_text.text = texto

	_hide_choices()

	await _update_choices_position()

func show_choices(texto: String, options: Array) -> void:

	dialogue_box.visible = true
	dialogue_text.text = texto

	await _update_choices_position()

	var buttons = [choice1, choice2, choice3]

	for i in range(buttons.size()):

		if i < options.size():

			buttons[i].visible = true
			buttons[i].text = options[i]["text"]

		else:

			buttons[i].visible = false

func hide_dialog() -> void:

	_hide_choices()

	portrait.visible = false
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

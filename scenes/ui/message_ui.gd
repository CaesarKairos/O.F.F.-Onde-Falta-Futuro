extends CanvasLayer

@onready var dialogue_box = $DialogueBox
@onready var dialogue_text = $DialogueBox/DialogueText
@onready var portrait = $DialogueBox/Portrait
@onready var continue_icon = $DialogueBox/ContinueIcon
@onready var choices_container = $DialogueBox/ChoicesContainer

@onready var choice1 = $DialogueBox/ChoicesContainer/Choice1
@onready var choice2 = $DialogueBox/ChoicesContainer/Choice2
@onready var choice3 = $DialogueBox/ChoicesContainer/Choice3

var waiting_message_close := false

var current_message_pt := ""
var current_message_en := ""
var current_message_es := ""

var portraits = {
	"bruno": preload("res://assets/art/characters/portraits/bruno icon.png"),
	"lyanna": preload("res://assets/art/characters/portraits/lyanna icon.png")
}


func _ready() -> void:

	dialogue_box.visible = false
	portrait.visible = false
	continue_icon.visible = false

	# Os retratos são ilustrações não-pixel-art.
	# Use filtragem linear com mipmaps somente nesse elemento,
	# mantendo o restante do jogo com o filtro apropriado para pixel art.
	if portrait is CanvasItem:
		portrait.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

	if continue_icon is AnimatedSprite2D:
		continue_icon.play()

	_hide_choices()

	choice1.pressed.connect(_on_choice_1)
	choice2.pressed.connect(_on_choice_2)
	choice3.pressed.connect(_on_choice_3)

	LocalizationManager.language_changed.connect(_on_language_changed)


func _process(_delta) -> void:

	if waiting_message_close:

		if Input.is_action_just_pressed("skip"):

			waiting_message_close = false

			_hide_choices()
			portrait.visible = false
			continue_icon.visible = false
			dialogue_box.visible = false


func is_message_open() -> bool:

	return waiting_message_close


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


func show_message(
	texto: String,
	texto_en: String = "",
	texto_es: String = ""
) -> void:

	current_message_pt = texto
	current_message_en = texto_en
	current_message_es = texto_es

	waiting_message_close = true

	dialogue_box.visible = true
	dialogue_text.text = _localized_message()

	portrait.visible = false
	continue_icon.visible = true

	_hide_choices()

	await _update_choices_position()


func _localized_message() -> String:

	var language := LocalizationManager.get_language()

	if language == LocalizationManager.LANGUAGE_EN and current_message_en != "":
		return current_message_en

	if language == LocalizationManager.LANGUAGE_ES and current_message_es != "":
		return current_message_es

	return current_message_pt


func _on_language_changed(_language: String) -> void:

	if waiting_message_close:
		dialogue_text.text = _localized_message()


func show_dialogue(texto: String) -> void:

	waiting_message_close = false

	dialogue_box.visible = true
	dialogue_text.text = texto

	continue_icon.visible = true

	_hide_choices()

	await _update_choices_position()


func show_choices(texto: String, options: Array) -> void:

	waiting_message_close = false

	dialogue_box.visible = true
	dialogue_text.text = texto

	portrait.visible = false
	continue_icon.visible = false

	await _update_choices_position()

	var buttons = [choice1, choice2, choice3]

	for i in range(buttons.size()):

		if i < options.size():

			buttons[i].visible = true
			buttons[i].text = options[i]["text"]

		else:

			buttons[i].visible = false


func hide_dialog() -> void:

	waiting_message_close = false

	_hide_choices()

	portrait.visible = false
	continue_icon.visible = false
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

extends CanvasLayer


# ============================================================
# NÓS
# ============================================================

@onready var dialogue_box = $DialogueBox
@onready var dialogue_text = $DialogueBox/DialogueText
@onready var portrait = $DialogueBox/Portrait
@onready var continue_icon = $DialogueBox/ContinueIcon
@onready var choices_container = $DialogueBox/ChoicesContainer

@onready var choice1 = $DialogueBox/ChoicesContainer/Choice1
@onready var choice2 = $DialogueBox/ChoicesContainer/Choice2
@onready var choice3 = $DialogueBox/ChoicesContainer/Choice3


# ============================================================
# CONFIGURAÇÃO DA CAIXA
# ============================================================

# Altura mínima original da DialogueBox.
const DIALOGUE_MIN_HEIGHT: float = 131.0

# Altura máxima que a caixa pode atingir.
const DIALOGUE_MAX_HEIGHT: float = 320.0

# Espaçamento interno do texto.
const TEXT_TOP_MARGIN: float = 17.0
const TEXT_BOTTOM_MARGIN: float = 20.0

# Espaçamento entre texto e escolhas.
const CHOICES_MARGIN: float = 20.0

# Espaçamento depois das escolhas.
const CHOICES_BOTTOM_MARGIN: float = 20.0


# ============================================================
# ESTADO
# ============================================================

var waiting_message_close := false

var current_message_pt := ""
var current_message_en := ""
var current_message_es := ""


# ============================================================
# RETRATOS
# ============================================================

var portraits = {
	"bruno": preload("res://assets/art/characters/portraits/bruno icon.png"),
	"lyanna": preload("res://assets/art/characters/portraits/lyanna icon.png"),
	"cecilia": preload("res://assets/art/characters/portraits/ana paula renault icon.png")
}


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	dialogue_box.visible = false
	portrait.visible = false
	continue_icon.visible = false

	# Os retratos não são pixel art.
	if portrait is CanvasItem:
		portrait.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

	# Inicia a animação do SPACE.
	if continue_icon is AnimatedSprite2D:
		continue_icon.play()

	_hide_choices()

	# Conecta os botões.
	choice1.pressed.connect(_on_choice_1)
	choice2.pressed.connect(_on_choice_2)
	choice3.pressed.connect(_on_choice_3)

	# Recalcula a caixa quando o idioma mudar.
	LocalizationManager.language_changed.connect(_on_language_changed)


# ============================================================
# PROCESS
# ============================================================

func _process(_delta) -> void:

	if waiting_message_close:

		if Input.is_action_just_pressed("skip"):

			waiting_message_close = false

			_hide_choices()

			portrait.visible = false
			continue_icon.visible = false
			dialogue_box.visible = false


# ============================================================
# VERIFICA SE A MENSAGEM ESTÁ ABERTA
# ============================================================

func is_message_open() -> bool:

	return waiting_message_close


# ============================================================
# REDIMENSIONAR DIALOGUE BOX
# ============================================================

func _resize_dialogue_box() -> void:

	# Espera o Godot atualizar o RichTextLabel
	# depois de alterar o texto.
	await get_tree().process_frame


	# --------------------------------------------------------
	# ALTURA DO TEXTO
	# --------------------------------------------------------

	var text_height: float = dialogue_text.get_content_height()

	# Evita que a altura seja zero.
	text_height = max(text_height, 24.0)


	# --------------------------------------------------------
	# ALTURA BASE DA CAIXA
	# --------------------------------------------------------

	var required_height: float = (
		TEXT_TOP_MARGIN +
		text_height +
		TEXT_BOTTOM_MARGIN
	)


	# --------------------------------------------------------
	# SE EXISTIREM ESCOLHAS
	# --------------------------------------------------------

	if _has_visible_choices():

		var choices_height: float = _get_choices_height()

		required_height += CHOICES_MARGIN
		required_height += choices_height
		required_height += CHOICES_BOTTOM_MARGIN


	# --------------------------------------------------------
	# LIMITA A ALTURA
	# --------------------------------------------------------

	required_height = clamp(
		required_height,
		DIALOGUE_MIN_HEIGHT,
		DIALOGUE_MAX_HEIGHT
	)


	# --------------------------------------------------------
	# REDIMENSIONA A DIALOGUE BOX
	# --------------------------------------------------------

	dialogue_box.size.y = required_height


	# --------------------------------------------------------
	# REDIMENSIONA O TEXTO
	# --------------------------------------------------------

	dialogue_text.position = Vector2(
		100.0,
		TEXT_TOP_MARGIN
	)

	dialogue_text.size = Vector2(
		dialogue_box.size.x - 164.0,
		text_height
	)


	# --------------------------------------------------------
	# POSICIONA AS ESCOLHAS
	# --------------------------------------------------------

	if _has_visible_choices():

		choices_container.position = Vector2(
			64.0,
			TEXT_TOP_MARGIN +
			text_height +
			CHOICES_MARGIN
		)

		choices_container.size.y = _get_choices_height()


	# --------------------------------------------------------
	# POSICIONA O SPACE
	# --------------------------------------------------------

	continue_icon.position = Vector2(
		dialogue_box.size.x - 78.0,
		dialogue_box.size.y - 32.0
	)


# ============================================================
# VERIFICA SE EXISTEM ESCOLHAS VISÍVEIS
# ============================================================

func _has_visible_choices() -> bool:

	return (
		choice1.visible or
		choice2.visible or
		choice3.visible
	)


# ============================================================
# CALCULA ALTURA DAS ESCOLHAS
# ============================================================

func _get_choices_height() -> float:

	var total_height: float = 0.0

	var buttons = [
		choice1,
		choice2,
		choice3
	]

	for button in buttons:

		if button.visible:

			total_height += button.get_combined_minimum_size().y

	# Adiciona o espaçamento entre os botões.
	var visible_buttons: int = 0

	for button in buttons:

		if button.visible:
			visible_buttons += 1

	if visible_buttons > 1:

		total_height += (
			visible_buttons - 1
		) * 6.0

	return total_height


# ============================================================
# RETRATO
# ============================================================

func set_portrait(character_name: String) -> void:

	character_name = character_name.to_lower()

	if portraits.has(character_name):

		portrait.texture = portraits[character_name]
		portrait.visible = true

	else:

		portrait.texture = null
		portrait.visible = false

# ============================================================
# SHOW MESSAGE
# ============================================================

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

	await _resize_dialogue_box()


# ============================================================
# LOCALIZAÇÃO
# ============================================================

func _localized_message() -> String:

	var language := LocalizationManager.get_language()

	if language == LocalizationManager.LANGUAGE_EN and current_message_en != "":
		return current_message_en

	if language == LocalizationManager.LANGUAGE_ES and current_message_es != "":
		return current_message_es

	return current_message_pt


# ============================================================
# MUDANÇA DE IDIOMA
# ============================================================

func _on_language_changed(_language: String) -> void:

	if waiting_message_close:

		dialogue_text.text = _localized_message()

		await _resize_dialogue_box()


# ============================================================
# SHOW DIALOGUE
# ============================================================

func show_dialogue(texto: String) -> void:

	waiting_message_close = false

	dialogue_box.visible = true

	dialogue_text.text = texto

	continue_icon.visible = true

	_hide_choices()

	await _resize_dialogue_box()


# ============================================================
# SHOW CHOICES
# ============================================================

func show_choices(texto: String, options: Array) -> void:

	waiting_message_close = false

	dialogue_box.visible = true

	dialogue_text.text = texto

	portrait.visible = false
	continue_icon.visible = false

	var buttons = [
		choice1,
		choice2,
		choice3
	]


	# --------------------------------------------------------
	# CONFIGURA OS BOTÕES
	# --------------------------------------------------------

	for i in range(buttons.size()):

		if i < options.size():

			buttons[i].visible = true
			buttons[i].text = options[i]["text"]

		else:

			buttons[i].visible = false


	# --------------------------------------------------------
	# REDIMENSIONA DEPOIS DE MOSTRAR OS BOTÕES
	# --------------------------------------------------------

	await _resize_dialogue_box()


# ============================================================
# ESCONDER DIÁLOGO
# ============================================================

func hide_dialog() -> void:

	waiting_message_close = false

	_hide_choices()

	portrait.visible = false
	continue_icon.visible = false
	dialogue_box.visible = false


# ============================================================
# ESCONDER ESCOLHAS
# ============================================================

func _hide_choices() -> void:

	choice1.visible = false
	choice2.visible = false
	choice3.visible = false


# ============================================================
# ESCOLHA 1
# ============================================================

func _on_choice_1() -> void:

	DialogueManager.select_choice(0)


# ============================================================
# ESCOLHA 2
# ============================================================

func _on_choice_2() -> void:

	DialogueManager.select_choice(1)


# ============================================================
# ESCOLHA 3
# ============================================================

func _on_choice_3() -> void:

	DialogueManager.select_choice(2)

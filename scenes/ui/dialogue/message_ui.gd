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

var current_playback: Dictionary = {}
var playback_generation := 0
var revealing := false

var wave_effect := DialogueWaveEffect.new()
var impact_effect := DialogueImpactEffect.new()
var pop_effect := DialoguePopEffect.new()


# ============================================================
# RETRATOS
# ============================================================

const DEFAULT_PORTRAIT_EXPRESSION := "normal"

var portraits = {
	"bruno": {
		"normal": preload("res://assets/art/characters/portraits/bruno icon.png")
	},
	"lyanna": {
		"normal": preload("res://assets/art/characters/portraits/lyanna/normal.png"),
		"feliz": preload("res://assets/art/characters/portraits/lyanna/feliz.png"),
		"triste": preload("res://assets/art/characters/portraits/lyanna/triste.png"),
		"brava": preload("res://assets/art/characters/portraits/lyanna/brava.png"),
		"confusa": preload("res://assets/art/characters/portraits/lyanna/confusa.png")
	},
	"cecilia": {
		"normal": preload("res://assets/art/characters/portraits/ana paula renault icon.png")
	}
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

	dialogue_text.bbcode_enabled = true
	dialogue_text.install_effect(wave_effect)
	dialogue_text.install_effect(impact_effect)
	dialogue_text.install_effect(pop_effect)


# ============================================================
# PROCESS
# ============================================================

func _process(_delta) -> void:

	if waiting_message_close:

		if Input.is_action_just_pressed("skip"):
			if revealing:
				reveal_all()
				return

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


func is_revealing() -> bool:
	return revealing


func reveal_all() -> void:
	if not revealing:
		return
	playback_generation += 1
	revealing = false
	dialogue_text.visible_characters = -1
	impact_effect.reset()
	pop_effect.reset()
	continue_icon.visible = true


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
		96.0,
		TEXT_TOP_MARGIN
	)

	dialogue_text.size = Vector2(
		dialogue_box.size.x - 160.0,
		text_height
	)


	# --------------------------------------------------------
	# POSICIONA AS ESCOLHAS
	# --------------------------------------------------------

	if _has_visible_choices():

		choices_container.position = Vector2(
			36.0,
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

func set_portrait(character_name: String, expression: String = DEFAULT_PORTRAIT_EXPRESSION) -> void:

	var character_key := character_name.strip_edges().to_lower()
	character_key = character_key.replace("á", "a").replace("é", "e").replace("í", "i")
	character_key = character_key.replace("ó", "o").replace("ú", "u").replace("ç", "c")
	var expression_key := expression.strip_edges().to_lower()

	if not portraits.has(character_key):
		portrait.texture = null
		portrait.visible = false
		return

	var character_portraits: Dictionary = portraits[character_key]
	if not character_portraits.has(expression_key):
		expression_key = DEFAULT_PORTRAIT_EXPRESSION

	portrait.texture = character_portraits.get(expression_key)
	portrait.visible = portrait.texture != null

	# As novas expressões da Lyanna são pixel art; os retratos legados não são.
	portrait.texture_filter = (
		CanvasItem.TEXTURE_FILTER_NEAREST
		if character_key == "lyanna"
		else CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	)

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

	_start_text_playback(_localized_message())

	portrait.visible = false
	continue_icon.visible = false

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

		_start_text_playback(_localized_message())

		await _resize_dialogue_box()


# ============================================================
# SHOW DIALOGUE
# ============================================================

func show_dialogue(texto: String) -> void:

	waiting_message_close = false

	dialogue_box.visible = true

	_start_text_playback(texto)

	continue_icon.visible = false

	_hide_choices()

	await _resize_dialogue_box()


# ============================================================
# SHOW CHOICES
# ============================================================

func show_choices(texto: String, options: Array) -> void:

	_cancel_playback()
	waiting_message_close = false

	dialogue_box.visible = true

	var parsed := DialogueEffectsManager.parse(texto)
	dialogue_text.text = parsed["bbcode"]
	dialogue_text.visible_characters = -1

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
			buttons[i].text = DialogueEffectsManager.strip_markup(str(options[i]["text"]))

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

	_cancel_playback()
	waiting_message_close = false

	_hide_choices()

	portrait.visible = false
	continue_icon.visible = false
	dialogue_box.visible = false


func _start_text_playback(source: String) -> void:
	_cancel_playback()
	current_playback = DialogueEffectsManager.parse(source)
	dialogue_text.text = current_playback["bbcode"]
	dialogue_text.visible_characters = 0
	revealing = true
	continue_icon.visible = false
	var generation := playback_generation
	_play_text(generation)


func _cancel_playback() -> void:
	playback_generation += 1
	revealing = false
	current_playback = {}
	impact_effect.reset()
	pop_effect.reset()


func _play_text(generation: int) -> void:
	var characters: Array = current_playback.get("characters", [])
	var pauses: Dictionary = current_playback.get("pauses", {})
	var index := 0
	while index < characters.size() and generation == playback_generation:
		if pauses.has(index):
			await get_tree().create_timer(float(pauses[index]) / 1000.0).timeout
			if generation != playback_generation:
				return

		var impact_range := _range_starting_at(current_playback.get("impact_ranges", []), index)
		if not impact_range.is_empty():
			index = int(impact_range["end"])
			dialogue_text.visible_characters = index
			impact_effect.trigger(int(impact_range["start"]))
			await get_tree().create_timer(DialogueEffectsManager.IMPACT_DURATION_SECONDS).timeout
			continue

		var pop_range := _range_containing(current_playback.get("pop_ranges", []), index)
		if not pop_range.is_empty():
			while index < int(pop_range["end"]) and str(characters[index]["character"]).strip_edges() == "":
				index += 1
			var word_start := index
			while index < int(pop_range["end"]) and str(characters[index]["character"]).strip_edges() != "":
				index += 1
			dialogue_text.visible_characters = index
			pop_effect.trigger(word_start, index)
			if word_start < index:
				await get_tree().create_timer(DialogueEffectsManager.POP_INTERVAL_SECONDS).timeout
			continue

		index += 1
		dialogue_text.visible_characters = index
		var speed := DialogueEffectsManager.character_speed(characters[index - 1])
		var wait_time := 1.0 / speed
		var next_character := "" if index >= characters.size() else str(characters[index]["character"])
		wait_time += DialogueEffectsManager.punctuation_pause_seconds(str(characters[index - 1]["character"]), next_character)
		await get_tree().create_timer(wait_time).timeout

	if generation == playback_generation:
		revealing = false
		dialogue_text.visible_characters = -1
		continue_icon.visible = true


func _range_starting_at(ranges: Array, index: int) -> Dictionary:
	for effect_range in ranges:
		if int(effect_range["start"]) == index:
			return effect_range
	return {}


func _range_containing(ranges: Array, index: int) -> Dictionary:
	for effect_range in ranges:
		if index >= int(effect_range["start"]) and index < int(effect_range["end"]):
			return effect_range
	return {}


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

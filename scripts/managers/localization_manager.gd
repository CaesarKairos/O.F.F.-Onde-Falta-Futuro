extends Node

signal language_changed(language: String)


# =========================================================
# IDIOMAS
# =========================================================

const LANGUAGE_PT := "pt_BR"
const LANGUAGE_EN := "en"


# =========================================================
# ESTADO
# =========================================================

var current_language := LANGUAGE_PT


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	TranslationServer.set_locale(current_language)


# =========================================================
# INPUT GLOBAL
# =========================================================

func _unhandled_input(event: InputEvent) -> void:

	if event.is_action_pressed("translate"):

		toggle_language()


# =========================================================
# TROCAR IDIOMA
# =========================================================

func toggle_language() -> void:

	if current_language == LANGUAGE_PT:

		set_language(LANGUAGE_EN)

	else:

		set_language(LANGUAGE_PT)


# =========================================================
# DEFINIR IDIOMA
# =========================================================

func set_language(language: String) -> void:

	if language != LANGUAGE_PT and language != LANGUAGE_EN:

		push_warning(
			"Idioma não suportado: " + language
		)

		return

	current_language = language

	TranslationServer.set_locale(current_language)

	language_changed.emit(current_language)


# =========================================================
# IDIOMA ATUAL
# =========================================================

func is_english() -> bool:

	return current_language == LANGUAGE_EN


func is_portuguese() -> bool:

	return current_language == LANGUAGE_PT


func get_language() -> String:

	return current_language


# =========================================================
# TRADUÇÃO
# =========================================================

func translate(text: String) -> String:

	if text.is_empty():

		return ""

	return tr(text)

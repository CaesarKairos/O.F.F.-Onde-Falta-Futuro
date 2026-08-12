extends Node


# =========================================================
# CONFIGURAÇÕES PERSISTENTES
# =========================================================

const SETTINGS_PATH := "user://settings.cfg"

const SECTION_LOCALIZATION := "localization"
const KEY_LANGUAGE := "language"

const DEFAULT_LANGUAGE := "pt_BR"

const VALID_LANGUAGES := [
	"pt_BR",
	"en",
	"es"
]


# =========================================================
# ESTADO
# =========================================================

var language := DEFAULT_LANGUAGE


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	load_settings()


# =========================================================
# CARREGAR CONFIGURAÇÕES
# =========================================================

func load_settings() -> void:

	var config := ConfigFile.new()

	var err := config.load(SETTINGS_PATH)

	if err != OK:

		if err == ERR_FILE_NOT_FOUND:

			# Arquivo não existe — usa padrão e cria o arquivo.
			language = DEFAULT_LANGUAGE
			save_settings()

		else:

			push_warning("Falha ao carregar settings.cfg (erro %d). Usando padrão." % err)
			language = DEFAULT_LANGUAGE

		return

	# Lê o idioma salvo.
	var saved_language: String = config.get_value(
		SECTION_LOCALIZATION,
		KEY_LANGUAGE,
		DEFAULT_LANGUAGE
	)

	# Migração: versões antigas usavam "pt" para português.
	if saved_language == "pt":
		saved_language = "pt_BR"

	# Valida o idioma.
	if saved_language not in VALID_LANGUAGES:

		push_warning("Idioma inválido em settings.cfg: '%s'. Usando padrão." % saved_language)
		language = DEFAULT_LANGUAGE

	else:

		language = saved_language


# =========================================================
# SALVAR CONFIGURAÇÕES
# =========================================================

func save_settings() -> void:

	var config := ConfigFile.new()

	config.set_value(
		SECTION_LOCALIZATION,
		KEY_LANGUAGE,
		language
	)

	var err := config.save(SETTINGS_PATH)

	if err != OK:

		push_warning("Falha ao salvar settings.cfg (erro %d)." % err)


# =========================================================
# IDIOMA
# =========================================================

func get_language() -> String:

	return language


func set_language(new_language: String) -> void:

	if new_language not in VALID_LANGUAGES:

		push_warning("Idioma inválido: '%s'. Ignorando." % new_language)
		return

	language = new_language

	save_settings()

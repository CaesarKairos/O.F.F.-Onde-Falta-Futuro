extends Node2D

const MENU_CONFIG_SCENE := preload("res://scenes/interface/MENU/menu_config.tscn")

const TELA_INICIAL_SCENE := "res://scenes/interface/Tela inicial/tela_inicial.tscn"


@onready var canvas_layer: CanvasLayer = %CanvasLayer
@onready var pause_hud: Control = %PauseHud


var pause_open: bool = false
var config_menu: Node = null


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	# Garante que o menu de pause continue processando enquanto o jogo está pausado
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Sincroniza o estado inicial: menu de pause começa oculto e o jogo rodando
	canvas_layer.visible = pause_open
	get_tree().paused = pause_open

	_setup_botoes()


# =========================================================
# INPUT
# =========================================================

func _process(_delta: float) -> void:

	if Input.is_action_just_pressed("ui_cancel"):

		# Se a config estiver aberta, o primeiro Esc fecha só ela
		if config_menu != null and config_menu.visible:

			_fechar_config()

		else:

			toggle_pause()


# =========================================================
# PAUSE
# =========================================================

func toggle_pause() -> void:

	pause_open = not pause_open

	canvas_layer.visible = pause_open
	get_tree().paused = pause_open

	if not pause_open:

		_fechar_config()


# =========================================================
# BOTÕES
# =========================================================

func _on_continuar_pressed() -> void:

	toggle_pause()


func _on_config_pressed() -> void:

	if config_menu == null:

		config_menu = MENU_CONFIG_SCENE.instantiate()
		config_menu.visible = false
		canvas_layer.add_child(config_menu)

	config_menu.visible = not config_menu.visible
	pause_hud.visible = not config_menu.visible


func _on_save_pressed() -> void:

	SaveManager.save_game()


func _on_exit_pressed() -> void:

	get_tree().paused = false
	pause_open = false
	canvas_layer.visible = false

	_fechar_config()

	get_tree().change_scene_to_file(TELA_INICIAL_SCENE)


# =========================================================
# CONFIG
# =========================================================

func _fechar_config() -> void:

	if config_menu != null:

		config_menu.visible = false

	pause_hud.visible = true


# =========================================================
# BOTÕES INVISÍVEIS (SÃO SPRITES NA CENA)
# =========================================================

func _setup_botoes() -> void:

	_criar_botao(Vector2(158, 339), _on_continuar_pressed)
	_criar_botao(Vector2(155, 403), _on_config_pressed)
	_criar_botao(Vector2(156, 467), _on_save_pressed)
	_criar_botao(Vector2(152, 534), _on_exit_pressed)


func _criar_botao(centro: Vector2, callback: Callable) -> void:

	var botao := Button.new()
	botao.flat = true
	botao.modulate.a = 0.0
	botao.size = Vector2(240, 48)
	botao.position = Vector2(centro.x - 120.0, centro.y - 24.0)
	botao.mouse_filter = Control.MOUSE_FILTER_STOP
	botao.pressed.connect(callback)
	pause_hud.add_child(botao)

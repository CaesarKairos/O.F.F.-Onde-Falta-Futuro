extends Node2D

@onready var light_beam: ColorRect = $ColorRect
@onready var timer: Timer = $Timer

# Intervalos de tempo entre as piscadas (em segundos)
@export var tempo_min: float = 0.05
@export var tempo_max: float = 0.25

# Duração da transição suave (quanto maior, mais suave e menos "agressiva" é a piscada)
@export var duracao_transicao: float = 0.08

var tween: Tween

func _ready() -> void:
	if not timer or not light_beam:
		push_error("Erro: Nó Timer ou ColorRect não foi encontrado!")
		return

	# Conecta o evento do Timer
	timer.timeout.connect(_on_timer_timeout)
	
	# Força a primeira piscada para ligar o sistema imediatamente
	_on_timer_timeout()

func _on_timer_timeout() -> void:
	var mat = light_beam.material as ShaderMaterial
	if not mat:
		return

	# Seleciona aleatoriamente a intensidade do próximo estado
	var modo: int = randi() % 3
	var intensidade_alvo: float = 1.0

	match modo:
		0: intensidade_alvo = 0.05 # Quase apagado
		1: intensidade_alvo = 0.4  # Meia luz
		2: intensidade_alvo = 1.0  # Luz forte/normal

	_transicionar_brilho_suave(mat, intensidade_alvo)
	_programar_proxima_piscada()

func _transicionar_brilho_suave(mat: ShaderMaterial, alvo: float) -> void:
	# Recupera o valor atual do shader
	var valor_bruto = mat.get_shader_parameter("intensidade_piscada")
	
	# Tratamento para evitar o erro de tipo 'Nil' / null no primeiro frame
	var valor_atual: float = 1.0
	if valor_bruto != null:
		valor_atual = float(valor_bruto)

	# Cancela animações anteriores em execução
	if tween and tween.is_running():
		tween.kill()

	# Cria a interpolação suave da luz
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_method(
		func(val: float): mat.set_shader_parameter("intensidade_piscada", val),
		valor_atual,
		alvo,
		duracao_transicao
	)

func _programar_proxima_piscada() -> void:
	timer.start(randf_range(tempo_min, tempo_max))

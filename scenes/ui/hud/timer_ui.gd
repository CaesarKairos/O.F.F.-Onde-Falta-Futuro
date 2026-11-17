extends Control

@onready var label: Label = $Label


func _process(_delta: float) -> void:
	label.text = TimerManager.get_tempo_formatado()
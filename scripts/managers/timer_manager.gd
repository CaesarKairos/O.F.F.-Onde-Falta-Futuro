extends Node

var tempo_total: float = 0.0


func _process(delta: float) -> void:
	tempo_total += delta


func get_tempo() -> float:
	return tempo_total


func get_tempo_formatado() -> String:
	var dias: int = int(tempo_total) / 86400
	var horas: int = (int(tempo_total) % 86400) / 3600
	var minutos: int = (int(tempo_total) % 3600) / 60
	var segundos: int = int(tempo_total) % 60

	return "%02dd %02dh %02dm %02ds" % [
		dias,
		horas,
		minutos,
		segundos
	]

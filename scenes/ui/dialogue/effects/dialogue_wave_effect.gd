class_name DialogueWaveEffect
extends RichTextEffect

var bbcode := "dialogue_wave"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var phase := char_fx.elapsed_time * DialogueEffectsManager.WAVE_FREQUENCY * TAU
	phase += float(char_fx.absolute_index) * DialogueEffectsManager.WAVE_CHARACTER_PHASE
	char_fx.offset.y += sin(phase) * DialogueEffectsManager.WAVE_AMPLITUDE
	return true

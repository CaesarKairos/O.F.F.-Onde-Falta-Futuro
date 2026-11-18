class_name DialogueWaveEffect
extends RichTextEffect

var bbcode := "dialogue_wave"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var phase := char_fx.elapsed_time * DialogueEffectsManager.WAVE_FREQUENCY * TAU
	var character_index := int(char_fx.env.get("start", 0)) + char_fx.relative_index
	phase += float(character_index) * DialogueEffectsManager.WAVE_CHARACTER_PHASE
	char_fx.offset.y += sin(phase) * DialogueEffectsManager.WAVE_AMPLITUDE
	return true

class_name DialogueImpactEffect
extends RichTextEffect

var bbcode := "dialogue_impact"
var triggered_at: Dictionary = {}


func reset() -> void:
	triggered_at.clear()


func trigger(start_index: int) -> void:
	triggered_at[start_index] = Time.get_ticks_msec()


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var start_index := int(char_fx.env.get("start", -1))
	if not triggered_at.has(start_index):
		return true
	var elapsed := float(Time.get_ticks_msec() - int(triggered_at[start_index])) / 1000.0
	var duration := DialogueEffectsManager.IMPACT_DURATION_SECONDS
	if elapsed >= duration:
		return true
	var progress := clampf(elapsed / duration, 0.0, 1.0)
	var bounce := exp(-5.0 * progress) * cos(progress * PI * 3.0)
	var scale_value := 1.0 + (DialogueEffectsManager.IMPACT_INITIAL_SCALE - 1.0) * maxf(bounce, 0.0)
	char_fx.transform = char_fx.transform.scaled_local(Vector2(scale_value, scale_value))
	return true

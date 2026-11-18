class_name DialoguePopEffect
extends RichTextEffect

var bbcode := "dialogue_pop"
var triggered_ranges: Array[Dictionary] = []


func reset() -> void:
	triggered_ranges.clear()


func trigger(start_index: int, end_index: int) -> void:
	triggered_ranges.append({
		"start": start_index,
		"end": end_index,
		"triggered_at": Time.get_ticks_msec(),
	})
	if triggered_ranges.size() > 32:
		triggered_ranges.pop_front()


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var active_range: Dictionary = {}
	for index in range(triggered_ranges.size() - 1, -1, -1):
		var candidate := triggered_ranges[index]
		if char_fx.absolute_index >= candidate["start"] and char_fx.absolute_index < candidate["end"]:
			active_range = candidate
			break
	if active_range.is_empty():
		return true
	var elapsed := float(Time.get_ticks_msec() - int(active_range["triggered_at"])) / 1000.0
	if elapsed >= DialogueEffectsManager.POP_ANIMATION_DURATION_SECONDS:
		return true
	var progress := elapsed / DialogueEffectsManager.POP_ANIMATION_DURATION_SECONDS
	var scale_value := lerpf(1.12, 1.0, ease(progress, -2.0))
	char_fx.transform = char_fx.transform.scaled_local(Vector2(scale_value, scale_value))
	return true

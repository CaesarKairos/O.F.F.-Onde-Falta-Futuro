extends Node

# Chave experimental: desative para manter o typewriter e remover apenas a
# apresentação expressiva, sem exibir as marcações no texto.
var effects_enabled := true

const HIGHLIGHT_COLOR := "#b52d22"
const DEFAULT_CPS := 30.0
const SLOW_CPS := 8.0
const FAST_CPS := 80.0
const POP_INTERVAL_SECONDS := 0.25
const POP_ANIMATION_DURATION_SECONDS := 0.16
const WHISPER_OPACITY := 0.60
const WHISPER_FONT_SIZE := 14
const DEFAULT_FONT_SIZE := 16
const WAVE_AMPLITUDE := 3.0
const WAVE_FREQUENCY := 1.0
const WAVE_CHARACTER_PHASE := 0.45
const IMPACT_INITIAL_SCALE := 1.5
const IMPACT_DURATION_SECONDS := 0.25

const OPEN_TAGS := {
	"[slow]": "slow",
	"[fast]": "fast",
	"[pop]": "pop",
	"[whisper]": "whisper",
	"[impact]": "impact",
}

const CLOSE_TAGS := {
	"[/slow]": "slow",
	"[/fast]": "fast",
	"[/pop]": "pop",
	"[/whisper]": "whisper",
	"[/impact]": "impact",
}


func parse(source: String) -> Dictionary:
	var characters: Array[Dictionary] = []
	var pauses: Dictionary = {}
	var stack: Array[String] = []
	var highlight := false
	var wave := false
	var index := 0

	while index < source.length():
		var escaped := false
		if source[index] == "\\" and index + 1 < source.length():
			var next_character := source[index + 1]
			if next_character in ["\\", "*", "~", "["]:
				index += 1
				escaped = true

		if not escaped:
			var pause_match := _parse_pause(source, index)
			if not pause_match.is_empty():
				pauses[characters.size()] = pause_match["milliseconds"]
				index = pause_match["next_index"]
				continue

			var matched_tag := false
			for markup in OPEN_TAGS:
				var close_markup: String = markup.insert(1, "/")
				if source.substr(index).begins_with(markup) and source.find(close_markup, index + markup.length()) >= 0:
					stack.append(OPEN_TAGS[markup])
					index += markup.length()
					matched_tag = true
					break
			if matched_tag:
				continue

			for markup in CLOSE_TAGS:
				if source.substr(index).begins_with(markup):
					var effect: String = CLOSE_TAGS[markup]
					var position := stack.rfind(effect)
					if position >= 0:
						stack.remove_at(position)
						index += markup.length()
						matched_tag = true
					break
			if matched_tag:
				continue

			if source[index] == "*" and (highlight or _has_unescaped_character(source, "*", index + 1)):
				highlight = not highlight
				index += 1
				continue
			if source[index] == "~" and (wave or _has_unescaped_character(source, "~", index + 1)):
				wave = not wave
				index += 1
				continue

		var active := stack.duplicate()
		if highlight:
			active.append("highlight")
		if wave:
			active.append("wave")
		characters.append({"character": source[index], "effects": active})
		index += 1

	var plain_text := ""
	for character_data in characters:
		plain_text += character_data["character"]
	if not effects_enabled:
		for character_data in characters:
			character_data["effects"] = []
		pauses.clear()

	var spans := _build_spans(characters)
	return {
		"source": source,
		"plain_text": plain_text,
		"bbcode": _build_bbcode(characters),
		"characters": characters,
		"spans": spans,
		"pauses": pauses,
		"pop_ranges": _ranges_for_effect(spans, "pop"),
		"impact_ranges": _ranges_for_effect(spans, "impact"),
	}


func strip_markup(source: String) -> String:
	return str(parse(source)["plain_text"])


func character_speed(character_data: Dictionary) -> float:
	var effects: Array = character_data.get("effects", [])
	# Slow e Fast são incompatíveis; a marcação aberta por último vence.
	for index in range(effects.size() - 1, -1, -1):
		if effects[index] == "slow":
			return SLOW_CPS
		if effects[index] == "fast":
			return FAST_CPS
	return DEFAULT_CPS


func punctuation_pause_seconds(character: String, next_character: String = "") -> float:
	if character == "," or character == ";" or character == ":":
		return 0.10
	if character in [".", "!", "?"]:
		if character == "." and next_character == ".":
			return 0.08
		return 0.20
	if character == "…":
		return 0.28
	return 0.0


func _parse_pause(source: String, index: int) -> Dictionary:
	if not source.substr(index).begins_with("[pause="):
		return {}
	var closing := source.find("]", index + 7)
	if closing < 0:
		return {}
	var value := source.substr(index + 7, closing - index - 7)
	if not value.is_valid_int():
		return {}
	return {
		"milliseconds": clampi(int(value), 0, 10000),
		"next_index": closing + 1,
	}


func _has_unescaped_character(source: String, character: String, from: int) -> bool:
	var found := source.find(character, from)
	while found >= 0:
		var backslashes := 0
		var cursor := found - 1
		while cursor >= 0 and source[cursor] == "\\":
			backslashes += 1
			cursor -= 1
		if backslashes % 2 == 0:
			return true
		found = source.find(character, found + 1)
	return false


func _build_spans(characters: Array[Dictionary]) -> Array[Dictionary]:
	var spans: Array[Dictionary] = []
	var effects := ["highlight", "wave", "impact", "slow", "fast", "pop", "whisper"]
	for effect in effects:
		var start := -1
		for index in range(characters.size() + 1):
			var active: bool = index < characters.size() and effect in characters[index]["effects"]
			if active and start < 0:
				start = index
			elif not active and start >= 0:
				spans.append({"effect": effect, "start": start, "end": index})
				start = -1
	return spans


func _ranges_for_effect(spans: Array[Dictionary], effect: String) -> Array[Dictionary]:
	var ranges: Array[Dictionary] = []
	for span in spans:
		if span["effect"] == effect:
			ranges.append(span)
	return ranges


func _build_bbcode(characters: Array[Dictionary]) -> String:
	var result := ""
	var current: Array = []
	for index in range(characters.size() + 1):
		var desired: Array = []
		if index < characters.size() and effects_enabled:
			desired = _visual_effects(characters[index]["effects"])
		if desired != current:
			for close_index in range(current.size() - 1, -1, -1):
				result += _close_bbcode(current[close_index])
			for effect in desired:
				result += _open_bbcode(effect, index, characters)
			current = desired
		if index < characters.size():
			result += _escape_bbcode(characters[index]["character"])
	return result


func _visual_effects(effects: Array) -> Array:
	var ordered: Array = []
	for effect in ["highlight", "whisper", "wave", "impact", "pop"]:
		if effect in effects:
			ordered.append(effect)
	return ordered


func _open_bbcode(effect: String, index: int, characters: Array[Dictionary]) -> String:
	match effect:
		"highlight": return "[color=%s]" % HIGHLIGHT_COLOR
		"whisper":
			var whisper_color := Color(1.0, 1.0, 1.0, WHISPER_OPACITY).to_html()
			return "[color=#%s][font_size=%d]" % [whisper_color, WHISPER_FONT_SIZE]
		"wave": return "[dialogue_wave start=%d]" % index
		"impact": return "[dialogue_impact start=%d]" % index
		"pop": return "[dialogue_pop start=%d]" % index
	return ""


func _close_bbcode(effect: String) -> String:
	match effect:
		"highlight": return "[/color]"
		"whisper": return "[/font_size][/color]"
		"wave": return "[/dialogue_wave]"
		"impact": return "[/dialogue_impact]"
		"pop": return "[/dialogue_pop]"
	return ""


func _escape_bbcode(character: String) -> String:
	if character == "[": return "[lb]"
	if character == "]": return "[rb]"
	return character

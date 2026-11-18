extends SceneTree

var failures: Array[String] = []
var effects_manager = preload("res://scripts/managers/dialogue_effects_manager.gd").new()


func _initialize() -> void:
	assert_equal(effects_manager.strip_markup("Lya, [impact]*ACORDA!*[/impact]"), "Lya, ACORDA!", "nested effects")
	assert_equal(effects_manager.strip_markup("~*surpresa*~"), "surpresa", "combined short markup")
	assert_equal(effects_manager.strip_markup("[slow]Hm...[/slow][pause=300] pai?"), "Hm... pai?", "pause")
	assert_equal(effects_manager.strip_markup("\\*literal\\* e \\~onda\\~"), "*literal* e ~onda~", "escaping")
	assert_equal(effects_manager.strip_markup("texto [slow]incompleto"), "texto [slow]incompleto", "unclosed tag")
	assert_equal(effects_manager.strip_markup("asterisco * solto"), "asterisco * solto", "unclosed shorthand")
	var parsed := effects_manager.parse("[slow]devagar[/slow][fast]rápido[/fast]")
	assert_equal(parsed["plain_text"], "devagarrápido", "consecutive effects")
	assert_equal(effects_manager.parse("")["plain_text"], "", "empty text")
	effects_manager.effects_enabled = false
	parsed = effects_manager.parse("[slow]*sem efeitos*[/slow][pause=300]")
	assert_equal(parsed["plain_text"], "sem efeitos", "disabled plain text")
	assert_equal(parsed["bbcode"], "sem efeitos", "disabled visual effects")
	assert_equal(parsed["spans"], [], "disabled timing effects")
	assert_equal(parsed["pauses"], {}, "disabled explicit pauses")
	effects_manager.effects_enabled = true
	print("DIALOGUE EFFECTS TESTS failures=%d" % failures.size())
	for failure in failures:
		push_error(failure)
	effects_manager.free()
	quit(1 if failures else 0)


func assert_equal(actual, expected, label: String) -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [label, expected, actual])

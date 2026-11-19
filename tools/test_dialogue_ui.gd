extends Node

var failures: Array[String] = []


func _ready() -> void:
	_test_custom_effect_api()
	var original_language: String = LocalizationManager.get_language()
	var message_ui = preload("res://scenes/ui/dialogue/message_ui.tscn").instantiate()
	add_child(message_ui)
	await get_tree().process_frame

	message_ui.show_dialogue("Bruno: [impact]*ACORDA!*[/impact] Tá ~sonhando~?")
	await get_tree().process_frame
	assert_true(message_ui.is_revealing(), "dialogue starts revealing")
	assert_equal(message_ui.dialogue_text.get_parsed_text(), "Bruno: ACORDA! Tá sonhando?", "formatted text remains readable")
	message_ui.reveal_all()
	assert_true(not message_ui.is_revealing(), "reveal all finishes playback")
	assert_equal(message_ui.dialogue_text.visible_characters, -1, "reveal all shows every character")

	LocalizationManager.set_language(LocalizationManager.LANGUAGE_PT)
	message_ui.show_message(
		"Objeto *importante*.",
		"*Important* object.",
		"Objeto *importante*."
	)
	await get_tree().process_frame
	assert_true(message_ui.is_message_open(), "interaction message opens outside narrative dialogue")
	assert_true(not message_ui.portrait.visible, "interaction message has no portrait")
	assert_equal(message_ui.dialogue_text.get_parsed_text(), "Objeto importante.", "interaction markup renders in Portuguese")
	message_ui.reveal_all()
	assert_true(message_ui.is_message_open(), "reveal all does not close interaction message")
	LocalizationManager.set_language(LocalizationManager.LANGUAGE_EN)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_equal(message_ui.dialogue_text.get_parsed_text(), "Important object.", "open interaction rerenders in English")
	LocalizationManager.set_language(LocalizationManager.LANGUAGE_ES)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_equal(message_ui.dialogue_text.get_parsed_text(), "Objeto importante.", "open interaction rerenders in Spanish")
	LocalizationManager.set_language(original_language)

	message_ui.show_choices("Escolha *agora*", [{"text": "*Sim*"}, {"text": "Não"}])
	await get_tree().process_frame
	assert_equal(message_ui.dialogue_text.get_parsed_text(), "Escolha agora", "choice prompt strips markup visually")
	assert_equal(message_ui.choice1.text, "Sim", "choice button strips markup")
	assert_true(message_ui.choice1.visible, "choice remains visible")

	message_ui.hide_dialog()
	assert_true(not message_ui.dialogue_box.visible, "dialogue closes cleanly")
	print("DIALOGUE UI TESTS failures=%d" % failures.size())
	for failure in failures:
		push_error(failure)
	get_tree().quit(1 if failures else 0)


func _test_custom_effect_api() -> void:
	var char_fx := CharFXTransform.new()
	char_fx.env = {"start": 3}
	char_fx.relative_index = 2
	char_fx.elapsed_time = 0.1
	assert_true(DialogueWaveEffect.new()._process_custom_fx(char_fx), "wave uses supported CharFX API")
	var pop_effect := DialoguePopEffect.new()
	pop_effect.trigger(5, 6)
	assert_true(pop_effect._process_custom_fx(char_fx), "pop uses supported CharFX API")


func assert_true(value: bool, label: String) -> void:
	if not value:
		failures.append("%s: expected true" % label)


func assert_equal(actual, expected, label: String) -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [label, expected, actual])

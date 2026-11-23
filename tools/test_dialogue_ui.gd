extends Node

var failures: Array[String] = []


func _ready() -> void:
	_test_custom_effect_api()
	var original_language: String = LocalizationManager.get_language()
	var message_ui = preload("res://scenes/ui/dialogue/message_ui.tscn").instantiate()
	add_child(message_ui)
	await get_tree().process_frame

	_test_portraits(message_ui)
	_test_dialogue_images()

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


func _test_portraits(message_ui) -> void:
	var lyanna_portraits: Dictionary = message_ui.portraits["lyanna"]
	assert_equal(lyanna_portraits.size(), 5, "all Lyanna expressions load")
	for expression in ["normal", "feliz", "triste", "brava", "confusa"]:
		assert_true(lyanna_portraits.has(expression), "Lyanna expression %s loads" % expression)
		assert_true(lyanna_portraits[expression] != null, "Lyanna expression %s has texture" % expression)

	message_ui.set_portrait("Lyanna", "feliz")
	assert_equal(message_ui.portrait.texture, lyanna_portraits["feliz"], "JSON expression selects portrait")
	message_ui.set_portrait("Lyanna")
	assert_equal(message_ui.portrait.texture, lyanna_portraits["normal"], "missing image defaults to normal")
	message_ui.set_portrait("Lyanna", "inexistente")
	assert_equal(message_ui.portrait.texture, lyanna_portraits["normal"], "unknown expression falls back to normal")
	message_ui.set_portrait("Lyanna", "brava")
	message_ui.set_portrait("Lyanna", "triste")
	assert_equal(message_ui.portrait.texture, lyanna_portraits["triste"], "consecutive expressions replace each other")
	message_ui.set_portrait("Bruno", "feliz")
	assert_equal(message_ui.portrait.texture, message_ui.portraits["bruno"]["normal"], "Bruno falls back to static portrait")
	message_ui.set_portrait("Cecília", "brava")
	assert_equal(message_ui.portrait.texture, message_ui.portraits["cecilia"]["normal"], "Cecilia falls back to static portrait")
	message_ui.set_portrait("")
	assert_true(not message_ui.portrait.visible, "unknown character hides portrait")


func _test_dialogue_images() -> void:
	var allowed := ["normal", "feliz", "triste", "brava", "confusa"]
	var directory := DirAccess.open("res://data/dialogues/chapter_01")
	assert_true(directory != null, "chapter dialogue directory opens")
	if directory == null:
		return
	for filename in directory.get_files():
		if filename.get_extension().to_lower() != "json":
			continue
		var file := FileAccess.open("res://data/dialogues/chapter_01/%s" % filename, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		assert_true(data is Dictionary, "%s parses" % filename)
		if not data is Dictionary:
			continue
		for node_id in data.get("nodes", {}):
			var dialogue_node: Dictionary = data["nodes"][node_id]
			if str(dialogue_node.get("speaker", "")).to_lower() == "lyanna":
				assert_true(dialogue_node.has("image"), "%s:%s defines image" % [filename, node_id])
				assert_true(str(dialogue_node.get("image", "")) in allowed, "%s:%s uses known image" % [filename, node_id])


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

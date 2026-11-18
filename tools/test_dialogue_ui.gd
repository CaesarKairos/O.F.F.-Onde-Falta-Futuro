extends Node

var failures: Array[String] = []


func _ready() -> void:
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


func assert_true(value: bool, label: String) -> void:
	if not value:
		failures.append("%s: expected true" % label)


func assert_equal(actual, expected, label: String) -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [label, expected, actual])

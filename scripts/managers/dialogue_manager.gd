extends Node

var dialogue_data: Dictionary = {}

var current_node_id: String = ""
var current_node: Dictionary = {}

var current_choices: Array = []

var dialogue_active := false
var just_started := false

func load_dialogues(path: String) -> bool:

	var file = FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("Não foi possível abrir o arquivo: " + path)
		return false

	var parsed = JSON.parse_string(
		file.get_as_text()
	)

	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("JSON inválido: " + path)
		return false

	dialogue_data = parsed

	return true


func start_dialog(dialogue_path: String, start_id: String) -> void:

	if not load_dialogues(dialogue_path):
		return

	dialogue_active = true
	just_started = true

	current_node_id = start_id
	current_node = {}

	_show_current_node()

	await get_tree().process_frame

	just_started = false


func _get_node(id: String) -> Dictionary:

	if not dialogue_data.has("nodes"):
		return {}

	var nodes = dialogue_data["nodes"]

	if typeof(nodes) != TYPE_DICTIONARY:
		return {}

	return nodes.get(id, {})


func _apply_node_effects(node: Dictionary) -> void:

	if node.has("set_flags"):

		for flag_name in node["set_flags"]:
			GameState.set_flag(flag_name)

	if node.has("set_flag"):
		GameState.set_flag(node["set_flag"])

	if node.has("set_story_stage"):
		GameState.story_stage = int(node["set_story_stage"])

	if node.has("set_scene"):
		GameState.scene = int(node["set_scene"])


func _choice_is_available(choice: Dictionary) -> bool:

	if choice.has("required_flag"):

		if not GameState.has_flag(
			str(choice["required_flag"])
		):
			return false

	if choice.has("blocked_flag"):

		if GameState.has_flag(
			str(choice["blocked_flag"])
		):
			return false

	return true


func _show_current_node() -> void:

	current_node = _get_node(
		current_node_id
	)

	if current_node.is_empty():
		end_dialog()
		return

	_apply_node_effects(current_node)

	var ui = get_tree().get_first_node_in_group(
		"message_ui"
	)

	if ui == null:
		return

	var node_type: String = str(
		current_node.get(
			"type",
			"dialogue"
		)
	)

	match node_type:

		"dialogue":

			var speaker := str(
				current_node.get(
					"speaker",
					""
				)
			)

			var text := str(
				current_node.get(
					"text",
					""
				)
			)

			if speaker != "":
				ui.show_dialogue(
					"%s: %s" % [
						speaker,
						text
					]
				)
			else:
				ui.show_dialogue(text)

		"choice":

			var options = current_node.get(
				"options",
				[]
			)

			if options.is_empty():
				options = current_node.get(
					"choices",
					[]
				)

			current_choices.clear()

			for option in options:

				if _choice_is_available(option):
					current_choices.append(option)

			ui.show_choices(
				str(
					current_node.get(
						"text",
						""
					)
				),
				current_choices
			)

		"end":

			end_dialog()


func can_continue() -> bool:

	if not dialogue_active:
		return false

	if just_started:
		return false

	return current_node.get(
		"type",
		"dialogue"
	) == "dialogue"


func next_dialog() -> void:

	if not dialogue_active:
		return

	if current_node.is_empty():
		end_dialog()
		return

	if current_node.get(
		"type",
		"dialogue"
	) != "dialogue":
		return

	if current_node.has("next"):

		current_node_id = str(
			current_node["next"]
		)

		_show_current_node()

	else:

		end_dialog()


func select_choice(choice_index: int) -> void:

	if not dialogue_active:
		return

	if choice_index < 0:
		return

	if choice_index >= current_choices.size():
		return

	var chosen = current_choices[
		choice_index
	]

	if chosen.has("set_flags"):

		for flag_name in chosen["set_flags"]:
			GameState.set_flag(flag_name)

	if chosen.has("set_flag"):
		GameState.set_flag(
			chosen["set_flag"]
		)

	if chosen.has("set_story_stage"):
		GameState.story_stage = int(
			chosen["set_story_stage"]
		)

	if chosen.has("set_scene"):
		GameState.scene = int(
			chosen["set_scene"]
		)

	if chosen.has("next"):

		current_node_id = str(
			chosen["next"]
		)

		_show_current_node()

	else:

		end_dialog()


func end_dialog() -> void:

	dialogue_active = false
	just_started = false

	current_node_id = ""
	current_node = {}

	current_choices.clear()

	var ui = get_tree().get_first_node_in_group(
		"message_ui"
	)

	if ui != null:
		ui.hide_dialog()

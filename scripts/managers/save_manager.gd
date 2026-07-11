extends Node

const SAVE_PATH := "user://save_game.json"

func _process(_delta):

	if Input.is_action_just_pressed("save_game"):
		save_game()

	if Input.is_action_just_pressed("load_game"):
		load_game()


func save_game() -> void:

	var player := get_tree().get_first_node_in_group("player")

	var player_position := Vector2.ZERO

	if player != null:
		player_position = player.global_position

	var save_data := {

		"chapter": GameState.chapter,
		"scene": GameState.scene,
		"story_stage": GameState.story_stage,

		"flags": GameState.flags,
		"inventory": GameState.inventory,

		"scene_path": get_tree().current_scene.scene_file_path,

		"player_position_x": player_position.x,
		"player_position_y": player_position.y

	}

	var file := FileAccess.open(
		SAVE_PATH,
		FileAccess.WRITE
	)

	file.store_string(
		JSON.stringify(save_data, "\t")
	)

	print("===== SAVE REALIZADO =====")
	print(save_data)


func load_game() -> void:

	if !FileAccess.file_exists(SAVE_PATH):

		print("Nenhum save encontrado.")
		return

	var file := FileAccess.open(
		SAVE_PATH,
		FileAccess.READ
	)

	var data = JSON.parse_string(
		file.get_as_text()
	)

	if typeof(data) != TYPE_DICTIONARY:

		push_error("Save corrompido.")
		return

	GameState.chapter = data["chapter"]
	GameState.scene = data["scene"]
	GameState.story_stage = data["story_stage"]

	GameState.flags = data["flags"]
	GameState.inventory = data["inventory"]

	var scene_path = data["scene_path"]

	SceneManager.goto_scene(scene_path)

	await get_tree().process_frame

	var player := get_tree().get_first_node_in_group("player")

	if player:

		player.global_position = Vector2(
			data["player_position_x"],
			data["player_position_y"]
		)

	print("===== SAVE CARREGADO =====")
	print(data)

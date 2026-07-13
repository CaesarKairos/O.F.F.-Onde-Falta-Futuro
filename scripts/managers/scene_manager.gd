extends Node

var current_scene_path := ""
var next_spawn := ""

func goto_scene(scene_path: String, spawn_name: String = "") -> void:

	current_scene_path = scene_path
	next_spawn = spawn_name

	call_deferred("_change_scene", scene_path)


func _change_scene(scene_path: String) -> void:

	get_tree().change_scene_to_file(scene_path)

	await get_tree().process_frame

	if next_spawn == "":
		return

	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		push_warning("Player não encontrado.")
		return

	var spawn_points = get_tree().current_scene.get_node_or_null("SpawnPoints")

	if spawn_points == null:
		push_warning("SpawnPoints não encontrado na cena.")
		return

	var spawn = spawn_points.get_node_or_null(next_spawn)

	if spawn == null:
		push_warning("Spawn '%s' não encontrado." % next_spawn)
		return

	player.global_position = spawn.global_position

	next_spawn = ""

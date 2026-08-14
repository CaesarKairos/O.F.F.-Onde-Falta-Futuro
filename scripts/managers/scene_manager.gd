extends Node

var current_scene_path := ""
var next_spawn := ""

func goto_scene(scene_path: String, spawn_name: String = "") -> void:

	current_scene_path = scene_path
	next_spawn = spawn_name

	call_deferred("_change_scene", scene_path)


func _change_scene(scene_path: String) -> void:

	# REGRA IMPORTANTE: ao trocar de cena por uma porta, o Player é SEMPRE
	# reposicionado na posição do Marker2D dentro de SpawnPoints cujo nome
	# bate com destination_spawn. A posição salva no nó Player da cena só é
	# usada quando a cena é aberta isolada no editor (F6). Para ajustar onde
	# a jogadora aparece, edite o Marker2D — e copie o valor para o nó Player
	# apenas para manter o teste isolado (F6) visualmente consistente.

	if next_spawn == "":
		get_tree().change_scene_to_file(scene_path)
		return

	var packed_scene: PackedScene = load(scene_path)

	if packed_scene == null:
		push_warning("Não foi possível carregar a cena '%s'." % scene_path)
		next_spawn = ""
		return

	var new_scene: Node = packed_scene.instantiate()

	var player: Node2D = _find_player_in_scene(new_scene)

	if player == null:
		push_warning("Player não encontrado na cena '%s'." % scene_path)
		new_scene.queue_free()
		next_spawn = ""
		return

	var spawn_points = new_scene.get_node_or_null("SpawnPoints")

	if spawn_points == null:
		push_warning("SpawnPoints não encontrado na cena.")
		new_scene.queue_free()
		next_spawn = ""
		return

	var spawn = spawn_points.get_node_or_null(next_spawn)

	if spawn == null:
		push_warning("Spawn '%s' não encontrado." % next_spawn)
		new_scene.queue_free()
		next_spawn = ""
		return

	var old_scene = get_tree().current_scene

	if old_scene != null:
		old_scene.free()

	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene

	# Rede de segurança: garante que nenhum diálogo fique "preso" ao trocar
	# de cena (ex.: se um diálogo anterior não chamou end_dialog()).
	DialogueManager.dialogue_active = false

	# Posiciona o player antes do primeiro frame renderizado.
	player.global_position = spawn.global_position

	next_spawn = ""


func _find_player_in_scene(node: Node) -> Node2D:

	if node is CharacterBody2D and node.is_in_group("player"):
		return node

	for child in node.get_children():
		var found = _find_player_in_scene(child)
		if found != null:
			return found

	return null

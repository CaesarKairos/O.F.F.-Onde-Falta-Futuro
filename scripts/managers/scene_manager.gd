extends Node

var current_scene_path := ""

func goto_scene(scene_path: String) -> void:
	current_scene_path = scene_path
	call_deferred("_change_scene", scene_path)

func _change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)

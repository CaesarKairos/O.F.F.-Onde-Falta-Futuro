extends Area2D

@export_file("*.tscn")
var destination_scene := ""

@export
var destination_spawn := ""

var player_inside := false


func _ready() -> void:

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta):

	if !player_inside:
		return

	if Input.is_action_just_pressed("interact"):

		if destination_scene == "":
			return

		SceneManager.goto_scene(
			destination_scene,
			destination_spawn
		)


func _on_body_entered(body):

	if body.is_in_group("player"):
		player_inside = true


func _on_body_exited(body):

	if body.is_in_group("player"):
		player_inside = false

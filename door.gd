extends Area2D

@export_file("*.tscn")
var destination_scene := ""

var player_inside := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta):

	if player_inside and Input.is_action_just_pressed("interact"):

		if destination_scene != "":
			SceneManager.goto_scene(destination_scene)


func _on_body_entered(body):

	if body.name == "Player":
		player_inside = true


func _on_body_exited(body):

	if body.name == "Player":
		player_inside = false

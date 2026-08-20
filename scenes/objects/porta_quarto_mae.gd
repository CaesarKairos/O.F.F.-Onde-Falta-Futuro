extends "res://scenes/components/interactable.gd"

@onready var sprite: Sprite2D = $Sprite2D

@export var opacity_normal := 1.0
@export var opacity_player_near := 0.5
@export var fade_duration := 0.2


func _ready():
	super._ready()
	sprite.modulate.a = opacity_normal


func _on_body_entered(body):
	super._on_body_entered(body)

	if body.name == "Player":
		var tween = create_tween()
		tween.tween_property(
			sprite,
			"modulate:a",
			opacity_player_near,
			fade_duration
		)


func _on_body_exited(body):
	super._on_body_exited(body)

	if body.name == "Player":
		var tween = create_tween()
		tween.tween_property(
			sprite,
			"modulate:a",
			opacity_normal,
			fade_duration
		)

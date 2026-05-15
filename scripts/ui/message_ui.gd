extends CanvasLayer

@onready var label = $Label

func show_message(texto):

	label.text = texto
	label.visible = true

	await get_tree().create_timer(2).timeout

	label.visible = false

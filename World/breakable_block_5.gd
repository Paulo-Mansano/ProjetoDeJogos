extends StaticBody2D

@export var meio_quebrada_texture: Texture2D
@export var quebrada_texture: Texture2D

@onready var sprite = $Sprite2D

var quebrando := false

func take_damage():
	if quebrando:
		return

	quebrando = true

	sprite.texture = meio_quebrada_texture
	await get_tree().create_timer(0.12).timeout

	sprite.texture = quebrada_texture
	await get_tree().create_timer(0.12).timeout

	queue_free()

extends StaticBody2D

@export var life := 2
@export var meio_quebrada_texture: Texture2D
@export var quebrada_texture: Texture2D

@onready var sprite = $Sprite2D

func take_damage():
	life -= 1

	if life == 1:
		# Primeiro tiro
		sprite.texture = meio_quebrada_texture

	elif life <= 0:
		# Segundo tiro
		sprite.texture = quebrada_texture

		await get_tree().create_timer(0.15).timeout

		queue_free()

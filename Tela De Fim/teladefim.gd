extends Control

func _ready():
	# Cria um temporizador de 5 segundos e, quando terminar, fecha o jogo
	await get_tree().create_timer(5.0).timeout
	get_tree().quit()

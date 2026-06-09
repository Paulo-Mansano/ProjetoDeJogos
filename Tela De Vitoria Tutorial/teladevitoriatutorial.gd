extends CanvasLayer

func _ready():
	# A contagem só começa quando a tela de vitória aparece
	await get_tree().create_timer(5.0).timeout
	
	# Troca para a Fase 1
	get_tree().change_scene_to_file("res://TelaFase1/telaprafase1.tscn")

extends CanvasLayer

func _ready():
	# A contagem só começa quando a tela de vitória aparece
	await get_tree().create_timer(5.0).timeout
	
	# Troca para a Fase 2
	get_tree().change_scene_to_file("res://Tela De Fim/teladefim.tscn")

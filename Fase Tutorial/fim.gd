extends Area2D

var tela_vitoria = preload("res://Tela De Vitoria Tutorial/teladevitoriatutorial.tscn")

func _on_body_entered(body):
	if body.name == "Player":
		var nova_tela = tela_vitoria.instantiate()
		get_tree().current_scene.add_child(nova_tela)
		body.queue_free()

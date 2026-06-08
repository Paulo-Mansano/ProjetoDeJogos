extends Control


func _ready():
	$ButtonTutorial.grab_focus()


func _on_button_tutorial_pressed():
	get_tree().change_scene_to_file("res://World/world.tscn")


func _on_button_fase1_pressed():
	get_tree().change_scene_to_file("res://World/world_fase1.tscn")


func _on_button_voltar_pressed():
	get_tree().change_scene_to_file("res://telainicial/tela_inicial.tscn")

func _input(event: InputEvent) -> void:
	# "ui_cancel" é mapeado por padrão para a tecla ESC no Godot
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

extends Control


func _ready():
	$ButtonTutorial.grab_focus()


func _on_button_tutorial_pressed():
	get_tree().change_scene_to_file("res://telainicial/tutorial.tscn")


func _on_button_fase1_pressed():
	get_tree().change_scene_to_file("res://telainicial/fase1.tscn")


func _on_button_voltar_pressed():
	get_tree().change_scene_to_file("res://telainicial/tela_inicial.tscn")

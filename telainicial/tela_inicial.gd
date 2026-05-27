extends Control


func _ready():
	$ButtonJogar.grab_focus()


func _on_button_jogar_pressed():
	get_tree().change_scene_to_file("res://telainicial/tela_inicial.tscn")

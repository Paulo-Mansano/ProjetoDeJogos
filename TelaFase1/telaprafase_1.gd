extends CanvasLayer


func _ready():
	$ButtonFase1.grab_focus()
	# Adicione a linha abaixo para conectar o botão da Fase 1:
	$ButtonFase1.pressed.connect(_on_button_fase1_pressed) 
	
	$ButtonVoltar.pressed.connect(_on_button_voltar_pressed)


func _on_button_fase1_pressed():
	get_tree().change_scene_to_file("res://Fase1/world_fase1.tscn")

func _on_button_voltar_pressed():
	get_tree().change_scene_to_file("res://telainicial/tela_inicial.tscn")


func _input(event: InputEvent) -> void:
	# "ui_cancel" é mapeado por padrão para a tecla ESC no Godot
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

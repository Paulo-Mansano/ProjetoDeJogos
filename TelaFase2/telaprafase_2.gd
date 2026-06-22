extends CanvasLayer


func _ready():
	$ButtonFase2.grab_focus()
	$ButtonVoltar.pressed.connect(_on_button_voltar_pressed)


func _on_button_fase2_pressed():
	get_tree().change_scene_to_file("res://TelaFase2/telaprafase_2.tscn")

func _on_button_voltar_pressed():
	get_tree().change_scene_to_file("res://telainicial/tela_inicial.tscn")


func _input(event: InputEvent) -> void:
	# "ui_cancel" é mapeado por padrão para a tecla ESC no Godot
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

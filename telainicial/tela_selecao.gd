extends Control

@onready var lista_fases: VBoxContainer = $ListaFases
@onready var template: Button = $ListaFases/BotaoTemplate


func _ready():
	_montar_lista_de_fases()


# Gera um botao por fase a partir do GameManager, destravando ou
# bloqueando conforme o progresso salvo.
func _montar_lista_de_fases() -> void:
	var primeiro_desbloqueado: Button = null

	for indice in GameManager.FASES.size():
		var fase = GameManager.FASES[indice]
		var botao: Button = template.duplicate()
		botao.visible = true
		lista_fases.add_child(botao)

		if GameManager.esta_desbloqueada(indice):
			botao.text = fase["nome"]
			botao.disabled = false
			botao.pressed.connect(_on_fase_pressed.bind(indice))
			if primeiro_desbloqueado == null:
				primeiro_desbloqueado = botao
		else:
			# Fase travada: cadeado, mais escura e nao clicavel.
			botao.text = "🔒 " + fase["nome"]
			botao.disabled = true
			botao.modulate = Color(0.45, 0.45, 0.45)

	# Foco inicial na primeira fase jogavel (navegacao por teclado/controle).
	if primeiro_desbloqueado:
		primeiro_desbloqueado.grab_focus()


func _on_fase_pressed(indice: int) -> void:
	GameManager.iniciar_fase(indice)


func _on_button_voltar_pressed():
	get_tree().change_scene_to_file("res://telainicial/tela_inicial.tscn")


func _input(event: InputEvent) -> void:
	# "ui_cancel" é mapeado por padrão para a tecla ESC no Godot
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

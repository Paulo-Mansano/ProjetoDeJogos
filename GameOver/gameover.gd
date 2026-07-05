extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Conecta o botão de jogar novamente
	$ButtonJogarNovamente.pressed.connect(_on_button_pressed)
	
	$ButtonVoltar.pressed.connect(_on_button_voltar_pressed)

func _on_button_voltar_pressed():
	get_tree().change_scene_to_file("res://telainicial/tela_inicial.tscn")

func _on_button_pressed():
	# Isso recarrega automaticamente a fase em que o jogador estava quando morreu
	get_tree().reload_current_scene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	# "ui_cancel" é mapeado por padrão para a tecla ESC no Godot
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
		
	# "ui_accept" é mapeado por padrão para a tecla ENTER e ESPAÇO no Godot
	if event.is_action_pressed("ui_accept"):
		_on_button_pressed()

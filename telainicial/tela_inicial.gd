extends Control

# ── Nós da cena ─────────────────────────────────────────────
@onready var titulo      : Label  = $Titulo
@onready var btn_jogar   : Button = $ButtonJogar
@onready var label_dica  : Label  = $LabelDica

# Caminho da próxima cena (mantido igual ao original)
const PROXIMA_CENA := "res://telainicial/tela_selecao.tscn"

var _dica_tween : Tween


func _ready() -> void:
	_estado_inicial()
	_animar_entrada()
	_piscar_dica()
	btn_jogar.mouse_entered.connect(_hover_jogar_on)
	btn_jogar.mouse_exited.connect(_hover_jogar_off)


# ── Estado inicial: tudo invisível antes da animação ────────
func _estado_inicial() -> void:
	titulo.modulate.a       = 0.0
	titulo.position.y      -= 20.0

	btn_jogar.modulate.a    = 0.0
	btn_jogar.scale         = Vector2(0.82, 0.82)

	label_dica.modulate.a   = 0.0


# ── Animação de entrada ──────────────────────────────────────
func _animar_entrada() -> void:
	var t := create_tween().set_parallel(false)

	# Título desce suavemente
	t.tween_property(titulo, "modulate:a", 1.0, 0.5)
	t.parallel().tween_property(titulo, "position:y",
		titulo.position.y + 20.0, 0.5) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# Botão aparece com bounce
	t.tween_interval(0.15)
	t.tween_property(btn_jogar, "modulate:a", 1.0, 0.4)
	t.parallel().tween_property(btn_jogar, "scale",
		Vector2.ONE, 0.4) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# Dica aparece por último
	t.tween_interval(0.2)
	t.tween_property(label_dica, "modulate:a", 0.6, 0.4)

	# Foca o botão só após aparecer
	t.tween_callback(btn_jogar.grab_focus)


# ── Hover no botão ───────────────────────────────────────────
func _hover_jogar_on() -> void:
	var t := create_tween()
	t.tween_property(btn_jogar, "scale", Vector2(1.07, 1.07), 0.1) \
		.set_ease(Tween.EASE_OUT)


func _hover_jogar_off() -> void:
	var t := create_tween()
	t.tween_property(btn_jogar, "scale", Vector2.ONE, 0.12) \
		.set_ease(Tween.EASE_OUT)


# ── Dica piscando ────────────────────────────────────────────
func _piscar_dica() -> void:
	_dica_tween = create_tween().set_loops()
	_dica_tween.tween_property(label_dica, "modulate:a", 0.15, 1.1)
	_dica_tween.tween_property(label_dica, "modulate:a", 0.65, 1.1)


# ── Botão JOGAR pressionado ──────────────────────────────────
func _on_button_jogar_pressed() -> void:
	if _dica_tween:
		_dica_tween.kill()
	btn_jogar.mouse_exited.disconnect(_hover_jogar_off)

	var t := create_tween().set_parallel(true)
	t.tween_property(titulo,     "modulate:a", 0.0, 0.3)
	t.tween_property(btn_jogar,  "modulate:a", 0.0, 0.25)
	t.tween_property(label_dica, "modulate:a", 0.0, 0.2)
	t.chain().tween_callback(_ir_para_proxima_cena)


func _ir_para_proxima_cena() -> void:
	get_tree().change_scene_to_file(PROXIMA_CENA)
	
	
func _input(event: InputEvent) -> void:
	# "ui_cancel" é mapeado por padrão para a tecla ESC no Godot
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

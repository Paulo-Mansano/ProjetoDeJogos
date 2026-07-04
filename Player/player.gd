extends CharacterBody2D

@export var torpedo_scene: PackedScene
@onready var aim_line = $AimLine

# --- MUNICAO (TIROS) ---
@export var municao_inicial: int = 5  # Tiros com que o player comeca a fase
var municao: int
var hud_label: Label

# --- VARIÁVEIS DE VELOCIDADE ---
const SPEED = 110.0
const JUMP_VELOCITY = -300.0
const ICE_SPEED = 250.0 # Limite maior exclusivo para o gelo
var tela_game_over = preload("res://GameOver/gameover.tscn")


# --- VARIÁVEIS DO GELO (Editáveis no Inspector) ---
@export var accelerationValue = 0.01
@export var slideValue = 0.01
@export var fullStopValue = 15

# --- COYOTE JUMP ---
@export var coyote_time: float = 0.12
var coyote_timer: float = 0.0

# --- REFERÊNCIAS DE NÓS ---
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var floor_ray_cast = $floorRayCast
@onready var floor_ray_cast_2 = $floorRayCast2
@onready var floor_ray_cast_3 = $floorRayCast3

# --- SISTEMA ---
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumped_from_ice: bool = false
var _frames_on_non_ice: int = 999

func _ready():
	municao = municao_inicial
	_criar_hud()
	_atualizar_hud()

func _physics_process(delta):
	# 1. Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Coyote timer + memória do gelo
	if is_on_floor():
		coyote_timer = coyote_time
		if _is_on_ice():
			_frames_on_non_ice = 0
			jumped_from_ice = true
		else:
			_frames_on_non_ice = min(_frames_on_non_ice + 1, 999)
			if _frames_on_non_ice >= 4:
				jumped_from_ice = false
	else:
		_frames_on_non_ice = 0
		coyote_timer = max(coyote_timer - delta, 0.0)

	# 3. Pulo (com coyote)
	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")) and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0

	# 3. Direção do Input (-1, 0 ou 1)
	var input_axis = Input.get_axis("ui_left", "ui_right")
	
	# 4. Máquina de Estados de Movimento
	if is_on_floor():
		# Se estiver numa rampa (ângulo maior que quase zero)
		if get_floor_angle() > 0.1: 
			_slope_movement()
		# Se o raio detectar o bloco de gelo
		elif _is_on_ice():
			_movement_on_ice(input_axis)
		# Chão normal de neve
		else:
			_normal_movement(input_axis)
	else:
		# Se estiver no ar, checa de onde veio
		if jumped_from_ice:
			_air_ice_movement(input_axis)
		else:
			_normal_movement(input_axis)

	# 5. Aplica a física e as animações
	move_and_slide()
	update_animations(input_axis)
	
	# 6. Mecânica de Morte por Queda
	if global_position.y > 350:
		var nova_tela = tela_game_over.instantiate()
		get_tree().current_scene.add_child(nova_tela)
		queue_free()


# --- FUNÇÕES DE MOVIMENTO ---

func _slope_movement():
	# Descobre para qual lado a rampa desce (1 = direita, -1 = esquerda)
	var downhill_direction = sign(get_floor_normal().x)
	
	# Força o personagem ladeira abaixo roubando o controle horizontal
	velocity.x = lerp(velocity.x, downhill_direction * 350.0, 0.08)

func _movement_on_ice(direction):
	if direction:
		# Acelera até o limite do gelo (250)
		velocity.x = lerp(velocity.x, direction * ICE_SPEED, accelerationValue)
	else:
		# Desliza até parar
		velocity.x = lerp(velocity.x, 0.0, slideValue)
		if abs(velocity.x) < fullStopValue:
			velocity.x = 0

func _air_ice_movement(direction):
	# Permite pouco controle no ar, mantendo a alta velocidade do gelo
	if direction:
		velocity.x = lerp(velocity.x, direction * ICE_SPEED, accelerationValue * 0.5)
	else:
		velocity.x = lerp(velocity.x, 0.0, slideValue * 0.2)

func _normal_movement(direction):
	if direction:
		# Freia suavemente se vier voando rápido do gelo para a terra
		if abs(velocity.x) > SPEED:
			velocity.x = move_toward(velocity.x, direction * SPEED, 5.0)
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

# --- FUNÇÕES AUXILIARES ---

func update_animations(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h = input_axis < 0
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
		
	if not is_on_floor():
		animated_sprite_2d.play("jump")

func _is_on_ice():
	for ray in [floor_ray_cast, floor_ray_cast_2, floor_ray_cast_3]:
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider and collider.name == "iceBlocks":
				return true
	return false

# --- TORPEDO ---

func _process(_delta):
	var direction = (get_global_mouse_position() - global_position).normalized()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		aim_line.visible = true
		aim_line.points = [Vector2.ZERO, direction * 100]
	else:
		aim_line.visible = false

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_W:
		if coyote_timer > 0:
			velocity.y = JUMP_VELOCITY
			coyote_timer = 0.0
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			shoot_torpedo()

func shoot_torpedo():
	if torpedo_scene == null:
		return
	# Sem municao, nao atira.
	if municao <= 0:
		return
	municao -= 1
	_atualizar_hud()
	var torpedo = torpedo_scene.instantiate()
	get_parent().add_child(torpedo)
	torpedo.global_position = global_position
	torpedo.direction = (get_global_mouse_position() - global_position).normalized()

# --- MUNICAO / NOZES ---

# Chamada pela Noz (pickup) quando o player a coleta.
func coletar_noz():
	municao += 1
	_atualizar_hud()

# --- HUD (contador de tiros) ---

func _criar_hud():
	var camada := CanvasLayer.new()
	add_child(camada)

	# Caixa no canto superior DIREITO: [icone noz] [numero]x
	var caixa := HBoxContainer.new()
	caixa.add_theme_constant_override("separation", 2)
	camada.add_child(caixa)
	caixa.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 6)
	# Cresce para a esquerda (para dentro da tela), nao para fora.
	caixa.grow_horizontal = Control.GROW_DIRECTION_BEGIN

	# Icone da noz (usa o primeiro quadro da spritesheet).
	var icone := TextureRect.new()
	var noz_tex := AtlasTexture.new()
	noz_tex.atlas = load("res://Design/Noz/noz.png")
	noz_tex.region = Rect2(0, 0, 227, 219)
	icone.texture = noz_tex
	icone.custom_minimum_size = Vector2(14, 14)
	icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	caixa.add_child(icone)

	hud_label = Label.new()
	hud_label.add_theme_font_size_override("font_size", 12)
	#cor da pontuação
	hud_label.add_theme_color_override("font_color", Color.BLACK)
	hud_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caixa.add_child(hud_label)

func _atualizar_hud():
	if hud_label:
		hud_label.text = "%dx" % municao

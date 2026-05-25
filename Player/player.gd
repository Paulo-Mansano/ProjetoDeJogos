extends CharacterBody2D

# --- VARIÁVEIS DE VELOCIDADE ---
const SPEED = 110.0
const JUMP_VELOCITY = -300.0
const ICE_SPEED = 250.0 # Limite maior exclusivo para o gelo

# --- VARIÁVEIS DO GELO (Editáveis no Inspector) ---
@export var accelerationValue = 0.01
@export var slideValue = 0.01
@export var fullStopValue = 15

# --- REFERÊNCIAS DE NÓS ---
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var floor_ray_cast = $floorRayCast

# --- SISTEMA ---
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumped_from_ice = false # Memória para manter o embalo no ar

func _physics_process(delta):
	# 1. Gravidade e Memória do Chão
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Salva se o jogador pisou no gelo antes de pular
		jumped_from_ice = _is_on_ice()

	# 2. Pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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
	
	# 6. Mecânica de Morte por Queda (ajuste o 350 se necessário)
	if global_position.y > 350:
		get_tree().reload_current_scene()

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
	if not floor_ray_cast.is_colliding():
		return false
		
	var collider = floor_ray_cast.get_collider()
	if not collider: return false
	
	# Nome exato do TileMap de gelo
	return collider.name == "iceBlocks"

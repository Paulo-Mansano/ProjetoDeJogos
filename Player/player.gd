extends CharacterBody2D

const SPEED = 110.0
const JUMP_VELOCITY = -300.0

# Nova constante: Limite de velocidade MUITO maior para o gelo
const ICE_SPEED = 250.0 

# Variáveis para o gelo (editáveis no Inspector)
@export var accelerationValue = 0.01
@export var slideValue = 0.01
@export var fullStopValue = 15

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var floor_ray_cast = $floorRayCast

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Variável de memória: grava se o jogador pisou no gelo antes de voar
var jumped_from_ice = false

func _physics_process(delta):
	# Aplica a gravidade e atualiza a memória do chão
	if not is_on_floor():
		velocity.y += gravity * delta
		
		# --- NOVO: LIMITADOR DE DESLIZAMENTO NA RAMPA ---
		# Quando a rampa for lida como parede e ele estiver caindo (velocity.y > 0)
		if is_on_wall_only() and velocity.y > 0:
			# Impede que ele ultrapasse a velocidade de 250 durante o slide
			if velocity.y > 250.0:
				velocity.y = 250.0
	else:
		# Se estiver no chão, ele grava exatamente em que tipo de chão está
		jumped_from_ice = _is_on_ice()

	# Pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_axis = Input.get_axis("ui_left", "ui_right")
	
	# Controle de Movimento Inteligente
	if is_on_floor():
		if _is_on_ice():
			_movement_on_ice(input_axis)
		else:
			_normal_movement(input_axis)
	else:
		# Se estiver NO AR, verifica de onde veio o pulo
		if jumped_from_ice:
			_air_ice_movement(input_axis)
		else:
			_normal_movement(input_axis)

	move_and_slide()
	update_animations(input_axis)
	
	# Sistema de morte por queda
	if global_position.y > 350:
		get_tree().reload_current_scene()

func _movement_on_ice(direction):
	if direction:
		# Agora o limite de aceleração puxa para o ICE_SPEED (250) e não mais SPEED (110)
		velocity.x = lerp(velocity.x, direction * ICE_SPEED, accelerationValue)
	else:
		velocity.x = lerp(velocity.x, 0.0, slideValue)
		
		# Uso do abs() para garantir que a parada funcione tanto para a direita quanto para a esquerda
		if abs(velocity.x) < fullStopValue: 
			velocity.x = 0

func _air_ice_movement(direction):
	# Função nova: Mantém a inércia do gelo enquanto estiver voando
	if direction:
		# Permite controle no ar, mas mantendo a velocidade alta do gelo
		velocity.x = lerp(velocity.x, direction * ICE_SPEED, accelerationValue * 0.5)
	else:
		# Escorregamento no ar (quase não perde velocidade)
		velocity.x = lerp(velocity.x, 0.0, slideValue * 0.2)

func _normal_movement(direction):
	if direction:
		# Suaviza a perda de velocidade caso o player caia muito rápido do gelo para a terra
		if abs(velocity.x) > SPEED:
			velocity.x = move_toward(velocity.x, direction * SPEED, 5.0)
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		

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
	
	return collider.name == "iceBlocks"
	

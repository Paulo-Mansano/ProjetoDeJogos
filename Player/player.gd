extends CharacterBody2D

const SPEED = 110.0
const JUMP_VELOCITY = -300.0

# Variáveis para o gelo (editáveis no Inspector)
@export var accelerationValue = 0.01
@export var slideValue = 0.01
@export var fullStopValue = 15

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var floor_ray_cast = $floorRayCast

# Puxa a gravidade das configurações do projeto
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Aplica a gravidade
	if not is_on_floor():
		velocity.y += gravity * delta

	# Pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Pega a direção do input (-1, 0 ou 1)
	var input_axis = Input.get_axis("ui_left", "ui_right")
	
	# Verifica o tipo de chão e aplica o movimento correspondente
	if _is_on_ice():
		_movement_on_ice(input_axis)
	else:
		_normal_movement(input_axis)

	move_and_slide()
	update_animations(input_axis)

func _movement_on_ice(direction):
	if direction:
		# lerp suaviza a transição até a velocidade máxima (aceleração no gelo)
		velocity.x = lerp(velocity.x, direction * SPEED, accelerationValue)
	else:
		# lerp suaviza a parada (o escorregão)
		velocity.x = lerp(velocity.x, 0.0, slideValue)
		
		# Para o personagem totalmente se ele estiver quase parando
		if velocity.x < fullStopValue and velocity.x > -fullStopValue: 
			velocity.x = 0

func _normal_movement(direction):
	if direction:
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
	# Verifica se o raycast está efetivamente encostando em algo
	if not floor_ray_cast.is_colliding():
		return false
		
	var collider = floor_ray_cast.get_collider()
	if not collider: return false
	
	# Checa se o objeto que ele está pisando tem o nome exato "iceBlocks"
	return collider.name == "iceBlocks"

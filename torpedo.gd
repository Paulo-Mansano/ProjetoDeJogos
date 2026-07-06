extends Area2D

@export var speed := 300.0
@export var gravity_force := 500.0
@export var lifetime := 3.0

var velocity := Vector2.ZERO

func _ready():
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func shoot(direction: Vector2):
	velocity = direction.normalized() * speed
	rotation = velocity.angle()

func _physics_process(delta):
	velocity.y += gravity_force * delta
	global_position += velocity * delta
	rotation = velocity.angle()

func _on_body_entered(body):
	if body.is_in_group("breakable"):
		if body.has_method("take_damage"):
			body.take_damage()
		else:
			body.queue_free()

	queue_free()

	queue_free()

extends Area2D

@export var speed := 300.0
var direction := Vector2.RIGHT

func _ready():
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("breakable"):
		body.queue_free()

	queue_free()

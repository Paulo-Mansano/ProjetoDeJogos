extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ButtonJogarNovamente.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	# Aqui vai o código da viagem
	get_tree().change_scene_to_file("res://World/world.tscn")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

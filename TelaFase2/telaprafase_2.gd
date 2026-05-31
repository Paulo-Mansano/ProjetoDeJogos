extends CanvasLayer


func _ready():
	$ButtonFase2.grab_focus()


func _on_button_fase2_pressed():
	get_tree().change_scene_to_file("res://TelaFase2/telaprafase_2.tscn")

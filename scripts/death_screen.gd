extends Node2D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_try_again_pressed():
	get_tree().change_scene_to_file("res://Scenes/world.tscn")


func _on_quit_pressed():
	get_tree().quit()

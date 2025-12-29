extends Control

func _on_try_again_button_pressed():
	get_tree().change_scene_to_file("res://scenes/core/Game.tscn")

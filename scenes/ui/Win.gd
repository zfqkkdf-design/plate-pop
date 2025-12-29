extends Control

func _on_play_button_pressed():
	AudioManager.play_sfx("sfx_click")
	get_tree().change_scene_to_file("res://scenes/core/Game.tscn")

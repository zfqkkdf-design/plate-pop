extends Control

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/core/Game.tscn")

func _on_setting_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/Settings.tscn")

func _on_how_to_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/HowToPlay.tscn")

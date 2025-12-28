extends Control

@onready var music_check = $VBoxContainer/MusicPanel/MusicCheck
@onready var sound_check = $VBoxContainer/SoundPanel/SoundCheck
@onready var vibration_check = $VBoxContainer/VibrationPanel/VibrationCheck

func _ready():
	# Initialize state (could load from a global config/save file)
	music_check.button_pressed = true
	sound_check.button_pressed = true
	vibration_check.button_pressed = true

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/core/Game.tscn")

func _on_music_check_toggled(toggled_on):
	# TODO: Implement actual music toggle logic
	print("Music toggled: ", toggled_on)

func _on_sound_check_toggled(toggled_on):
	# TODO: Implement actual sound toggle logic
	print("Sound toggled: ", toggled_on)

func _on_vibration_check_toggled(toggled_on):
	# TODO: Implement actual vibration toggle logic
	print("Vibration toggled: ", toggled_on)


func _on_play_button_pressed() -> void:
	pass # Replace with function body.

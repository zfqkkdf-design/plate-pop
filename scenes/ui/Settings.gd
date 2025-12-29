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
	AudioManager.play_sfx("sfx_click")
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _on_music_check_toggled(toggled_on):
	AudioManager.set_music_enabled(toggled_on)
	AudioManager.play_sfx("sfx_click")
	print("Music toggled: ", toggled_on)

func _on_sound_check_toggled(toggled_on):
	AudioManager.set_sfx_enabled(toggled_on)
	AudioManager.play_sfx("sfx_click")
	print("Sound toggled: ", toggled_on)

func _on_vibration_check_toggled(toggled_on):
	AudioManager.set_vibration_enabled(toggled_on)
	AudioManager.play_sfx("sfx_click")
	if toggled_on:
		AudioManager.vibrate()
	print("Vibration toggled: ", toggled_on)


func _on_play_button_pressed() -> void:
	AudioManager.play_sfx("sfx_click")
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

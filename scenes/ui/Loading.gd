extends Control

@onready var progress_bar = $ProgressBar
@onready var get_ready_button = $GetReadyButton

func _ready():
	get_ready_button.hide()
	progress_bar.value = 0
	
	# Simulate loading
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", 100, 1.0) # 1 seconds loading
	tween.tween_callback(_on_loading_complete)

func _on_loading_complete():
	progress_bar.hide()
	get_ready_button.show()

func _on_get_ready_button_pressed():
	# Change to Game scene
	get_tree().change_scene_to_file("res://scenes/core/Game.tscn")

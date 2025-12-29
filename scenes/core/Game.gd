extends Node2D

@onready var wave_manager = $WaveManager
@onready var time_bar = $HUD/TimeBar
@onready var projectiles_container = $Entities/Projectiles
@onready var arrow_spawn_point = $Player/ArrowSpawnPoint
@onready var bow_sprite = $Player/Bow
@onready var pause_button = $HUD/PauseButton
@onready var bow_anim = $BowAnimationPlayer
@onready var pause_menu = $HUD/PauseMenu
@onready var resume_button = $HUD/PauseMenu/ResumeButton
@onready var menu_button = $HUD/PauseMenu/MenuButton

var projectile_scene = preload("res://scenes/entities/Projectile.tscn")
var game_duration: float = 40.0
var time_left: float = 40.0
var is_game_active: bool = false
var is_charging: bool = false

# Bow textures
var bow_charged_texture = preload("res://assets/sprites/player/лукзаряжен.png")
var bow_empty_texture = preload("res://assets/sprites/player/лук.png")

func _ready():
	# Setup UI
	time_left = game_duration
	time_bar.max_value = game_duration
	time_bar.value = time_left
	
	# Setup Signals
	wave_manager.spawn_container = $Entities/Saucers
	wave_manager.all_waves_complete.connect(_on_victory)
	
	pause_button.pressed.connect(_on_pause_button_pressed)
	resume_button.pressed.connect(_on_resume_button_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)
	
	start_game()

func start_game():
	is_game_active = true
	wave_manager.start_waves()

func _process(delta):
	if not is_game_active: return
	
	time_left -= delta
	time_bar.value = time_left
	
	if time_left <= 0:
		_on_game_over()

func _unhandled_input(event):
	if not is_game_active: return
	
	if event is InputEventScreenTouch:
		if event.pressed:
			start_charging()
		elif not event.pressed:
			shoot_arrow()
			
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_charging()
			else:
				shoot_arrow()

func start_charging():
	if is_charging: return
	is_charging = true
	bow_anim.play("charge")
	AudioManager.play_sfx("sfx_bow_charge")

func shoot_arrow():
	if not is_charging: return
	is_charging = false
	
	# Create arrow
	var arrow = projectile_scene.instantiate()
	arrow.global_position = arrow_spawn_point.global_position
	projectiles_container.add_child(arrow)
	
	# Play shoot animation
	bow_anim.play("shoot")
	AudioManager.play_sfx("sfx_bow_shoot")

func _on_victory():
	if not is_game_active: return
	is_game_active = false
	AudioManager.play_sfx("sfx_win")
	print("Victory!")
	call_deferred("change_to_win_scene")

func _on_game_over():
	if not is_game_active: return
	is_game_active = false
	AudioManager.play_sfx("sfx_lose")
	print("Game Over!")
	call_deferred("change_to_lose_scene")

func change_to_win_scene():
	get_tree().change_scene_to_file("res://scenes/ui/Win.tscn")

func change_to_lose_scene():
	get_tree().change_scene_to_file("res://scenes/ui/Lose.tscn")

func _on_pause_button_pressed():
	AudioManager.play_sfx("sfx_click")
	get_tree().paused = true
	pause_menu.visible = true

func _on_resume_button_pressed():
	AudioManager.play_sfx("sfx_click")
	get_tree().paused = false
	pause_menu.visible = false

func _on_menu_button_pressed():
	AudioManager.play_sfx("sfx_click")
	get_tree().paused = false

	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

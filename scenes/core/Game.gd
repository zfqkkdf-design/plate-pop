extends Node2D

@onready var wave_manager = $WaveManager
@onready var time_bar = $HUD/TimeBar
@onready var projectiles_container = $Entities/Projectiles
@onready var arrow_spawn_point = $Player/ArrowSpawnPoint
@onready var bow_sprite = $Player/Bow
@onready var pause_button = $HUD/PauseButton

var projectile_scene = preload("res://scenes/entities/Projectile.tscn")
var game_duration: float = 40.0
var time_left: float = 40.0
var is_game_active: bool = false

func _ready():
	# Setup UI
	time_left = game_duration
	time_bar.max_value = game_duration
	time_bar.value = time_left
	
	# Setup Signals
	wave_manager.spawn_container = $Entities/Saucers
	wave_manager.all_waves_complete.connect(_on_victory)
	
	pause_button.pressed.connect(_on_pause_button_pressed)
	
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
	
	if event is InputEventScreenTouch and event.pressed:
		shoot_arrow()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		shoot_arrow()

func shoot_arrow():
	var arrow = projectile_scene.instantiate()
	arrow.global_position = arrow_spawn_point.global_position
	projectiles_container.add_child(arrow)

func _on_victory():
	if not is_game_active: return
	is_game_active = false
	print("Victory!")
	call_deferred("change_to_win_scene")

func _on_game_over():
	if not is_game_active: return
	is_game_active = false
	print("Game Over!")
	call_deferred("change_to_lose_scene")

func change_to_win_scene():
	get_tree().change_scene_to_file("res://scenes/ui/Win.tscn")

func change_to_lose_scene():
	get_tree().change_scene_to_file("res://scenes/ui/Lose.tscn")

func _on_pause_button_pressed():
	get_tree().paused = not get_tree().paused

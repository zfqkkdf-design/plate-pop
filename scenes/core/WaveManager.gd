extends Node

signal all_waves_complete
signal wave_progress_updated(remaining: int, total: int)

@export var spawn_container: Node2D
@export var spawn_y_range: Vector2 = Vector2(150, 450)
@export var screen_width: float = 648.0 # Default Godot width, will update in _ready

var current_wave_index: int = 0
var saucers_to_destroy: int = 0
var total_saucers_in_wave: int = 0

var saucer_scene = preload("res://scenes/entities/Saucer.tscn")

# Wave configurations
var waves = [
	{
		"count": 5,
		"speed_min": 100.0,
		"speed_max": 200.0,
		"types": [0] # Horizontal
	},
	{
		"count": 7,
		"speed_min": 200.0,
		"speed_max": 300.0,
		"types": [0, 1] # Horizontal, Diagonal
	},
	{
		"count": 10,
		"speed_min": 300.0,
		"speed_max": 400.0,
		"types": [0, 1, 2] # All types
	}
]

func _ready():
	screen_width = get_viewport().get_visible_rect().size.x

func start_waves():
	current_wave_index = 0
	start_wave(current_wave_index)

func start_wave(index: int):
	if index >= waves.size():
		all_waves_complete.emit()
		return
	
	var wave_data = waves[index]
	saucers_to_destroy = wave_data["count"]
	total_saucers_in_wave = wave_data["count"]
	
	emit_signal("wave_progress_updated", saucers_to_destroy, total_saucers_in_wave)
	
	# Spawn initial batch
	for i in range(wave_data["count"]):
		# Stagger spawns
		get_tree().create_timer(i * 1.5).timeout.connect(func(): spawn_saucer(wave_data))

func spawn_saucer(wave_data):
	if saucers_to_destroy <= 0: return # Stop spawning if done (edge case)

	var saucer = saucer_scene.instantiate()
	spawn_container.add_child(saucer)
	
	# Configure
	var speed = randf_range(wave_data["speed_min"], wave_data["speed_max"])
	var type_idx = wave_data["types"].pick_random()
	
	saucer.speed = speed
	saucer.movement_type = type_idx
	
	# Position
	var from_left = randf() > 0.5
	var y_pos = randf_range(spawn_y_range.x, spawn_y_range.y)
	
	# Adjust y_pos to stay within reasonable bounds
	
	if from_left:
		saucer.position = Vector2(-50, y_pos)
		saucer.direction = Vector2.RIGHT
		if type_idx == 1: # Diagonal
			# Random slope
			var slope = randf_range(-0.5, 0.5)
			saucer.direction = Vector2(1, slope).normalized()
	else:
		saucer.position = Vector2(screen_width + 50, y_pos)
		saucer.direction = Vector2.LEFT
		if type_idx == 1: # Diagonal
			var slope = randf_range(-0.5, 0.5)
			saucer.direction = Vector2(-1, slope).normalized()
			
	# Random texture
	var colors = ["blue", "green", "orange", "pink", "yellow"]
	var color = colors.pick_random()
	saucer.get_node("Sprite2D").texture = load("res://assets/sprites/saucers/projectiles/plate_" + color + ".png")
	
	# Connect signals
	saucer.destroyed.connect(_on_saucer_destroyed)
	saucer.exited_screen.connect(_on_saucer_exited)

func _on_saucer_destroyed():
	saucers_to_destroy -= 1
	emit_signal("wave_progress_updated", saucers_to_destroy, total_saucers_in_wave)
	
	if saucers_to_destroy <= 0:
		# Wave Complete
		await get_tree().create_timer(1.0).timeout
		current_wave_index += 1
		start_wave(current_wave_index)

func _on_saucer_exited():
	# Spawn replacement for escaped saucer
	if saucers_to_destroy > 0:
		spawn_saucer(waves[current_wave_index])

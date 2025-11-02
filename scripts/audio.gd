extends Node

# Enhanced Audio Manager with pitch and volume control
# Code adapted from KidsCanCode, enhanced for AAA audio feedback

var num_players = 12
var bus = "master"

var available = []  # The available players.
var queue = []  # The queue of sounds to play (now stores dictionaries with parameters).

func _ready():
	for i in num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)

		available.append(p)

		p.volume_db = -10
		p.finished.connect(_on_stream_finished.bind(p))
		p.bus = bus


func _on_stream_finished(stream):
	available.append(stream)


## Play a sound with optional pitch and volume control
## @param sound_path: Path to the sound file (String)
## @param pitch: Pitch modification (Float, default 1.0 = normal)
##               - 1.0 = normal pitch
##               - 1.2 = 20% higher (excited, energetic)
##               - 0.8 = 20% lower (heavy, slow)
## @param volume_db: Volume in decibels (Float, default 0.0 = use player default)
## @param random_pitch: Add random variation to pitch (Bool, default false)
func play(sound_path: String, pitch: float = 1.0, volume_db: float = 0.0, random_pitch: bool = false):
	# Create sound data dictionary
	var sound_data = {
		"path": sound_path,
		"pitch": pitch,
		"volume": volume_db,
		"random_pitch": random_pitch
	}

	queue.append(sound_data)


func _process(_delta):
	if not queue.is_empty() and not available.is_empty():
		var sound_data = queue.pop_front()
		var player = available.pop_front()

		# Load and configure the player
		player.stream = load(sound_data["path"])

		# Apply pitch (with optional random variation)
		if sound_data["random_pitch"]:
			# Add slight random variation for organic feel
			player.pitch_scale = sound_data["pitch"] * randf_range(0.95, 1.05)
		else:
			player.pitch_scale = sound_data["pitch"]

		# Apply volume (0.0 means use default -10dB)
		if sound_data["volume"] != 0.0:
			player.volume_db = sound_data["volume"]
		else:
			player.volume_db = -10  # Default volume

		# Play the sound
		player.play()

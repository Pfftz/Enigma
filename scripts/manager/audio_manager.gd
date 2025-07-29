extends Node

# Audio Manager - Centralized audio control for the game
# Manages both background music and sound effects

# --- Sound Effect Categories ---
enum SFXCategory {
	UI,
	OBJECT,
	TITLE_SCREEN,
	GAMEPLAY
}

# --- Constants ---
const SFX_EXTENSION: String = ".wav"
const DEFAULT_FADE_DURATION: float = 1.0

# --- SFX Paths by Category ---
const SFX_PATHS: Dictionary = {
	SFXCategory.UI: "res://sfx/ui/",
	SFXCategory.OBJECT: "res://sfx/object/",
	SFXCategory.TITLE_SCREEN: "res://sfx/title_screen/",
	SFXCategory.GAMEPLAY: "res://sfx/"
}

# --- Volume Settings ---
var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0

# --- References to child nodes ---
@onready var bg_music_player: AudioStreamPlayer = $BGMusic
@onready var sfx_player: AudioStreamPlayer = $SFXMusic

# --- SFX Management ---
var sfx_pool: Array[AudioStreamPlayer] = []
var max_sfx_players: int = 8

#==============================================================================
# INITIALIZATION
#==============================================================================

func _ready() -> void:
	# Set up audio buses
	if bg_music_player:
		bg_music_player.bus = "Music"
	if sfx_player:
		sfx_player.bus = "SFX"
	
	# Create additional SFX players for overlapping sounds
	_create_sfx_pool()
	
	# Load settings if available
	_load_audio_settings()

func _create_sfx_pool() -> void:
	for i in range(max_sfx_players):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_pool.append(player)

#==============================================================================
# BACKGROUND MUSIC CONTROL
#==============================================================================

func play_bg_music(track_id: int) -> void:
	if bg_music_player and bg_music_player.has_method("play_track"):
		bg_music_player.play_track(track_id)

func set_bg_track(track_id: int) -> void:
	if bg_music_player and bg_music_player.has_method("set_track"):
		bg_music_player.set_track(track_id)

func play_bg_stream(path: String) -> void:
	if bg_music_player and bg_music_player.has_method("play_stream"):
		bg_music_player.play_stream(path)

func pause_bg_music() -> void:
	if bg_music_player and bg_music_player.has_method("pause"):
		bg_music_player.pause()

func resume_bg_music() -> void:
	if bg_music_player and bg_music_player.has_method("resume"):
		bg_music_player.resume()

func stop_bg_music() -> void:
	if bg_music_player:
		bg_music_player.stop()

func fade_out_bg_music(_duration: float = DEFAULT_FADE_DURATION) -> void:
	if bg_music_player and bg_music_player.has_method("decrease_volume"):
		bg_music_player.decrease_volume()

func fade_in_bg_music(_duration: float = DEFAULT_FADE_DURATION) -> void:
	if bg_music_player and bg_music_player.has_method("increase_volume"):
		bg_music_player.increase_volume()

func mute_bg_music() -> void:
	if bg_music_player and bg_music_player.has_method("mute"):
		bg_music_player.mute()

func unmute_bg_music() -> void:
	if bg_music_player and bg_music_player.has_method("unmute"):
		bg_music_player.unmute()

func set_bg_pitch(pitch: float) -> void:
	if bg_music_player and bg_music_player.has_method("set_pitch"):
		bg_music_player.set_pitch(pitch)

func get_current_bg_track() -> String:
	if bg_music_player and bg_music_player.has_method("get_stream_path"):
		return bg_music_player.get_stream_path()
	return "NONE"

#==============================================================================
# SOUND EFFECTS CONTROL
#==============================================================================

func play_sfx(sound_name: String, category: SFXCategory = SFXCategory.GAMEPLAY, volume: float = 1.0, pitch: float = 1.0) -> void:
	var full_path = SFX_PATHS.get(category, "res://sfx/") + sound_name
	if not full_path.ends_with(SFX_EXTENSION):
		full_path += SFX_EXTENSION
	
	var player = _get_available_sfx_player()
	if player:
		player.stream = load(full_path)
		player.volume_db = linear_to_db(volume * sfx_volume * master_volume)
		player.pitch_scale = pitch
		player.play()

func play_sfx_direct_path(path: String, volume: float = 1.0, pitch: float = 1.0) -> void:
	var player = _get_available_sfx_player()
	if player:
		player.stream = load(path)
		player.volume_db = linear_to_db(volume * sfx_volume * master_volume)
		player.pitch_scale = pitch
		player.play()

func play_ui_sound(sound_name: String, volume: float = 1.0) -> void:
	play_sfx(sound_name, SFXCategory.UI, volume)

func play_object_sound(sound_name: String, volume: float = 1.0) -> void:
	play_sfx(sound_name, SFXCategory.OBJECT, volume)

func play_title_sound(sound_name: String, volume: float = 1.0) -> void:
	play_sfx(sound_name, SFXCategory.TITLE_SCREEN, volume)

func stop_all_sfx() -> void:
	if sfx_player:
		sfx_player.stop()
	for player in sfx_pool:
		if player.playing:
			player.stop()

func _get_available_sfx_player() -> AudioStreamPlayer:
	# First try the main SFX player
	if sfx_player and not sfx_player.playing:
		return sfx_player
	
	# Then try the pool
	for player in sfx_pool:
		if not player.playing:
			return player
	
	# If all are busy, use the oldest one (first in pool)
	if sfx_pool.size() > 0:
		return sfx_pool[0]
	
	return null

#==============================================================================
# VOLUME CONTROL
#==============================================================================

func set_master_volume(volume: float) -> void:
	master_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
	_save_audio_settings()

func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_volume))
	_save_audio_settings()

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume))
	_save_audio_settings()

func get_master_volume() -> float:
	return master_volume

func get_music_volume() -> float:
	return music_volume

func get_sfx_volume() -> float:
	return sfx_volume

#==============================================================================
# SETTINGS PERSISTENCE
#==============================================================================

func _save_audio_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.save("user://audio_settings.cfg")

func _load_audio_settings() -> void:
	var config = ConfigFile.new()
	if config.load("user://audio_settings.cfg") == OK:
		master_volume = config.get_value("audio", "master_volume", 1.0)
		music_volume = config.get_value("audio", "music_volume", 1.0)
		sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
		
		# Apply loaded settings
		set_master_volume(master_volume)
		set_music_volume(music_volume)
		set_sfx_volume(sfx_volume)

#==============================================================================
# UTILITY FUNCTIONS
#==============================================================================

func is_music_playing() -> bool:
	return bg_music_player and bg_music_player.playing

func is_sfx_playing() -> bool:
	if sfx_player and sfx_player.playing:
		return true
	
	for player in sfx_pool:
		if player.playing:
			return true
	
	return false

func pause_all_audio() -> void:
	pause_bg_music()
	# Note: SFX typically don't need pausing as they're short

func resume_all_audio() -> void:
	resume_bg_music()

func mute_all_audio() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)

func unmute_all_audio() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)

# Convenience functions for common game sounds
func play_button_press() -> void:
	play_ui_sound("button_press")

func play_button_hover() -> void:
	play_ui_sound("button_hover")

func play_error_sound() -> void:
	play_ui_sound("error")

func play_success_sound() -> void:
	play_ui_sound("success")

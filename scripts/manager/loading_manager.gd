extends Node

## Loading Manager - Handles all loading screen operations
## This is an autoload/singleton

const LOADING_SCREEN_SCENE = preload("res://scenes/ui/loading_screen.tscn")

var current_loading_screen: Control = null
var is_loading: bool = false

# Default loading presets (you can create more)
var default_warp_preset: LoadingPreset
var default_sleep_preset: LoadingPreset
var default_new_game_preset: LoadingPreset

func _ready() -> void:
	# Create default presets if they don't exist
	_create_default_presets()

func _create_default_presets() -> void:
	"""Create default loading presets"""
	# Default warp preset
	default_warp_preset = LoadingPreset.new()
	default_warp_preset.loading_image = null # No image by default
	default_warp_preset.use_timer = true
	default_warp_preset.randomize_time = true
	default_warp_preset.loading_timer = 2.0
	default_warp_preset.fade_color = Color.BLACK
	
	# Default sleep preset
	default_sleep_preset = LoadingPreset.new()
	default_sleep_preset.loading_image = null
	default_sleep_preset.use_timer = true
	default_sleep_preset.randomize_time = false
	default_sleep_preset.loading_timer = 3.0
	default_sleep_preset.fade_color = Color.BLACK
	
	# Default new game preset
	default_new_game_preset = LoadingPreset.new()
	default_new_game_preset.loading_image = null
	default_new_game_preset.use_timer = true
	default_new_game_preset.randomize_time = true
	default_new_game_preset.loading_timer = 4.0
	default_new_game_preset.fade_color = Color.BLACK

func show_loading_screen(preset: LoadingPreset, target_scene: String, loading_text: String = "Loading...") -> void:
	"""Show loading screen with given preset and target scene"""
	if is_loading:
		print("Loading already in progress!")
		return
	
	is_loading = true
	
	# Create loading screen
	current_loading_screen = LOADING_SCREEN_SCENE.instantiate()
	
	# Add to scene tree at highest level
	get_tree().current_scene.add_child(current_loading_screen)
	current_loading_screen.z_index = 1000 # Ensure it's on top
	
	# Setup loading screen
	current_loading_screen.setup_loading(preset, target_scene)
	current_loading_screen.set_loading_text(loading_text)
	
	# Connect finished signal
	current_loading_screen.loading_finished.connect(_on_loading_finished)

func _on_loading_finished() -> void:
	"""Called when loading is complete"""
	is_loading = false
	
	if current_loading_screen:
		current_loading_screen.queue_free()
		current_loading_screen = null

# Convenience functions for common loading scenarios

func warp_with_loading(target_scene: String, preset: LoadingPreset = null) -> void:
	"""Show loading screen for scene warping"""
	var loading_preset = preset if preset else default_warp_preset
	show_loading_screen(loading_preset, target_scene, "Entering area...")

func sleep_with_loading(target_scene: String, preset: LoadingPreset = null) -> void:
	"""Show loading screen for sleep transition"""
	var loading_preset = preset if preset else default_sleep_preset
	show_loading_screen(loading_preset, target_scene, "Sleeping...")

func new_game_with_loading(target_scene: String, preset: LoadingPreset = null) -> void:
	"""Show loading screen for new game"""
	var loading_preset = preset if preset else default_new_game_preset
	show_loading_screen(loading_preset, target_scene, "Starting new game...")

func continue_game_with_loading(target_scene: String, preset: LoadingPreset = null) -> void:
	"""Show loading screen for continue game"""
	var loading_preset = preset if preset else default_new_game_preset
	show_loading_screen(loading_preset, target_scene, "Loading save data...")

# Alternative: Load scene without loading screen (for quick transitions)
func change_scene_instant(target_scene: String) -> void:
	"""Change scene instantly without loading screen"""
	get_tree().change_scene_to_file(target_scene)

extends Control
class_name LoadingScreen

## Loading Screen with customizable image, timing, and fade effects
## Supports both timer-based and resource loading progress

@onready var loading_image: TextureRect = $CenterContainer/VBoxContainer/LoadingImage
@onready var loading_text: Label = $CenterContainer/VBoxContainer/LoadingText
@onready var progress_bar: ProgressBar = $CenterContainer/VBoxContainer/ProgressBar
@onready var timer: Timer = $Timer
@onready var fade_rect: ColorRect = $FadeRect
@onready var background: Panel = $Background

var loading_preset: LoadingPreset
var target_scene_path: String = ""
var fade_in_complete: bool = false
var loading_complete: bool = false

signal loading_finished

func _ready() -> void:
	# Ensure we start fully faded in
	fade_rect.color.a = 1.0
	
	# Hide progress bar initially
	progress_bar.visible = false
	
	# Start fade in animation
	_fade_in()

func setup_loading(preset: LoadingPreset, scene_path: String) -> void:
	"""Setup the loading screen with a preset and target scene"""
	loading_preset = preset
	target_scene_path = scene_path
	
	if loading_preset:
		# Set loading image
		if loading_preset.loading_image:
			loading_image.texture = loading_preset.loading_image
			loading_image.visible = true
		else:
			loading_image.visible = false
		
		# Set background color
		if background and background.has_theme_stylebox_override("panel"):
			var style_box = background.get_theme_stylebox("panel") as StyleBoxFlat
			if style_box:
				style_box.bg_color = loading_preset.fade_color
		
		# Setup timer if enabled
		if loading_preset.use_timer:
			progress_bar.visible = true
			
			var final_time = loading_preset.loading_timer
			if loading_preset.randomize_time:
				# Add random variation (±1 second)
				final_time += randf_range(-1.0, 1.0)
				final_time = max(0.5, final_time) # Minimum 0.5 seconds
			
			timer.wait_time = final_time
			timer.timeout.connect(_on_timer_finished)
			
			# Start progress animation
			_animate_progress_bar()
		else:
			# Use resource loading progress
			progress_bar.visible = true
			_start_resource_loading()

func _fade_in() -> void:
	"""Fade in the loading screen"""
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, 0.3)
	await tween.finished
	fade_in_complete = true
	
	# Start loading process after fade in
	if loading_preset:
		if loading_preset.use_timer:
			timer.start()
		else:
			_start_resource_loading()

func _animate_progress_bar() -> void:
	"""Animate progress bar during timer-based loading"""
	if not loading_preset or not loading_preset.use_timer:
		return
	
	progress_bar.value = 0.0
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", 1.0, timer.wait_time)

func _start_resource_loading() -> void:
	"""Start actual resource loading with progress tracking"""
	if target_scene_path == "":
		_finish_loading()
		return
	
	# Use ResourceLoader for progress tracking
	ResourceLoader.load_threaded_request(target_scene_path)
	_update_loading_progress()

func _update_loading_progress() -> void:
	"""Update progress bar based on resource loading"""
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(target_scene_path, progress)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = progress[0] if progress.size() > 0 else 0.0
			# Continue checking progress
			await get_tree().create_timer(0.1).timeout
			_update_loading_progress()
		
		ResourceLoader.THREAD_LOAD_LOADED:
			progress_bar.value = 1.0
			await get_tree().create_timer(0.2).timeout # Brief pause at 100%
			_finish_loading()
		
		ResourceLoader.THREAD_LOAD_FAILED:
			print("ERROR: Failed to load scene: ", target_scene_path)
			_finish_loading()
		
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			print("ERROR: Invalid resource: ", target_scene_path)
			_finish_loading()

func _on_timer_finished() -> void:
	"""Called when timer-based loading finishes"""
	loading_complete = true
	_finish_loading()

func _finish_loading() -> void:
	"""Finish loading and transition to target scene"""
	loading_complete = true
	
	# Fade out
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.3)
	await tween.finished
	
	# Emit signal and change scene
	loading_finished.emit()
	
	if target_scene_path != "":
		# Use the actual resource if we loaded it threaded
		var loaded_resource = ResourceLoader.load_threaded_get(target_scene_path)
		if loaded_resource:
			get_tree().change_scene_to_packed(loaded_resource)
		else:
			get_tree().change_scene_to_file(target_scene_path)
	else:
		# No scene to load, just remove loading screen
		queue_free()

func set_loading_text(text: String) -> void:
	"""Update the loading text"""
	loading_text.text = text

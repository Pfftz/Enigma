extends Node3D

#==============================================================================
# TITLE SCREEN MENU - File Select Style
#==============================================================================
# 
# This script implements a Petscop-style file select menu for the title screen
# with the following options:
# - New Game: Starts a fresh playthrough
# - Continue: Available only after completing the game once
# - Settings: Opens settings menu (TODO: implement)
# - Quit Game: Exits the application
#
# The Continue option is automatically hidden/disabled when the player
# hasn't completed the game yet. Use mark_game_completed() to unlock it.
#
#==============================================================================

# --- Loading Presets ---
@export var new_game_loading_preset: LoadingPreset ## Loading preset for new game (assign in inspector)
@export var continue_loading_preset: LoadingPreset ## Loading preset for continue game (assign in inspector)

# --- Konfigurasi ---
const READING_CARD_WAIT = 2.5

# --- Screen Configuration for 16:9 (1152x648) ---
const SCREEN_WIDTH = 1152
const SCREEN_HEIGHT = 648
const MENU_OFFSCREEN_X = SCREEN_WIDTH + 100 # Start off-screen to the right
const MENU_CENTER_X = 376 # Center position for menu (576 - 100 for proper centering)

# --- Variabel State ---
var title_stage: int = 0 # State machine: 0:Title, 1:MainMenu
var selected_option: int = 0 # 0=NewGame, 1=Continue, 2=Settings, 3=Quit
var enable_selection: bool = true
var game_completed: bool = false # Flag untuk menampilkan Continue
var in_settings_menu: bool = false # Track if we're in settings submenu
var current_settings_menu: Node = null # Reference to active settings menu

# --- Variabel Animasi & Timer ---
var logo_timer: float = 0
var timer: int = 0

# --- Menu Options ---
var menu_options: Array[String] = ["New Game", "Continue", "Settings", "Quit Game"]

# --- Referensi Node (@onready) ---
@onready var logo_gift: Sprite3D = %LogoGift
@onready var start_button: Sprite2D = %StartButton
@onready var card_timer: Timer = $CardTimer
@onready var logo_mesh: MeshInstance3D = %LogoMesh
@onready var road_mesh: MeshInstance3D = %RoadMesh
@onready var file_select: Marker2D = %FileSelect
@onready var files: Marker2D = %Files

#==============================================================================
# FUNGSI UTAMA
#==============================================================================

func _ready() -> void:
	# Hide the old UI container to prevent overlay
	$UI_Container.visible = false
	
	# Inisialisasi file select menu
	_setup_file_select_menu()
	_check_game_completion()
	
	# Setup audio dan environment
	$Song.play()
	if AudioManager.get_current_bg_track() != "res://sounds/OST/Kosan.wav":
		AudioManager.pause_bg_music()
	
	get_tree().paused = false
	Global.is_game_paused = false
	Global.can_pause = false
	
	RenderingServer.global_shader_parameter_set("fog_enabled", true)
	RenderingServer.global_shader_parameter_set("fog_color", Vector3.ONE)
	RenderingServer.global_shader_parameter_set("fog_size", 25.0)

func _process(delta: float) -> void:
	_update_animations(delta)
	
	match title_stage:
		0: _state_title_screen()
		1: _state_main_menu()

#==============================================================================
# LOGIKA STATE & SINYAL
#==============================================================================

func _state_title_screen() -> void:
	start_button.visible = bool(int(timer < 24) * int(title_stage == 0))
	
	if Input.is_action_just_pressed("pressed_start") && title_stage == 0:
		if start_button.frame_coords.y != 1:
			$PressedStart.play()
		
		selected_option = 0
		start_button.frame_coords.y = 1
		card_timer.wait_time = READING_CARD_WAIT + randf_range(0.0, 2.0)
		card_timer.start()
		
		await card_timer.timeout
		
		await _animate_logo_transition()
		title_stage = 1

func _state_main_menu() -> void:
	if title_stage == 1:
		# Update visual untuk setiap menu item
		for i in range(files.get_child_count()):
			var file = files.get_child(i)
			if file.has_method("get_child"):
				var icon = file.get_node_or_null("Icon")
				var file_name_label = file.get_node_or_null("FileName")
				
				if icon:
					icon.visible = (i == selected_option)
				
				if file_name_label:
					if i == selected_option:
						file_name_label.modulate = Color.WHITE
					else:
						file_name_label.modulate = Color(0.7, 0.7, 0.7)
		
		# Input handling
		if Input.is_action_just_pressed("pressed_down") && selected_option < _get_available_options_count() - 1 && enable_selection:
			_select_option()
		
		if Input.is_action_just_pressed("pressed_up") && selected_option > 0 && enable_selection:
			_select_option(true)
		
		if Input.is_action_just_pressed("pressed_action") && abs(file_select.position.x - MENU_CENTER_X) < 50:
			_execute_selected_option()
		
		if Input.is_action_just_pressed("pressed_triangle"):
			_return_to_title()
		
		# Handle escape key to close settings menu if open
		if Input.is_action_just_pressed("ui_cancel") and in_settings_menu:
			_on_return_from_settings()

#==============================================================================
# SETUP DAN KONFIGURASI MENU
#==============================================================================

func _setup_file_select_menu() -> void:
	# Hide file select off-screen initially (adjusted for 16:9)
	file_select.position.x = MENU_OFFSCREEN_X
	
	# Setup menu options based on available file slots
	for i in range(files.get_child_count()):
		var file = files.get_child(i)
		var file_name_label = file.get_node_or_null("FileName")
		var icon = file.get_node_or_null("Icon")
		var counter_origin = file.get_node_or_null("CounterOrigin")
		var panic = file.get_node_or_null("Panic")
		
		if file_name_label:
			if i < menu_options.size():
				file_name_label.text = menu_options[i]
			else:
				file.visible = false
		
		if icon:
			icon.visible = false
		
		if counter_origin:
			counter_origin.visible = false
		
		if panic:
			panic.visible = false

func _check_game_completion() -> void:
	# Use GameState to check completion instead of file check
	game_completed = GameState.is_game_completed()
	
	# Update Continue button visibility/state
	if files.get_child_count() > 1:
		var continue_option = files.get_child(1) # Index 1 = Continue
		if not game_completed:
			continue_option.modulate = Color(0.5, 0.5, 0.5, 0.5) # Dim out
		else:
			continue_option.modulate = Color.WHITE # Make it fully visible

func _has_completed_game() -> bool:
	# Use GameState instead of file check
	return GameState.is_game_completed()

func _get_available_options_count() -> int:
	# Hitung opsi yang tersedia (Continue mungkin disembunyikan)
	var count = menu_options.size()
	if not game_completed:
		# Skip Continue option jika game belum selesai
		# Tapi tetap biarkan navigasi normal, hanya disable actionnya
		pass
	return count

#==============================================================================
# NAVIGASI DAN AKSI MENU
#==============================================================================

func _select_option(up: bool = false) -> void:
	var bounce_tween = create_tween()
	
	if up:
		selected_option -= 1
	else:
		selected_option += 1
	
	enable_selection = false
	$FileSound.play()
	
	# Visual feedback untuk selection
	var selected_file = files.get_child(selected_option)
	if selected_file:
		if up:
			bounce_tween.tween_property(selected_file, "position:y", -10.0, 0.2).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		else:
			bounce_tween.tween_property(selected_file, "position:y", 10.0, 0.2).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
		if up:
			bounce_tween.tween_property(selected_file, "position:y", 10.0, 0.2).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		else:
			bounce_tween.tween_property(selected_file, "position:y", -10.0, 0.2).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	await bounce_tween.finished
	enable_selection = true

func _execute_selected_option() -> void:
	match selected_option:
		0: _new_game()
		1: _continue_game()
		2: _open_settings()
		3: _quit_game()

func _new_game() -> void:
	print("Starting new game...")
	$PressedStart.play()
	
	# Reset progress
	GameState.reset_progress()
	
	# Use loading screen if preset is assigned
	if new_game_loading_preset:
		# Use LoadingManager if available
		if has_node("/root/LoadingManager"):
			get_node("/root/LoadingManager").new_game_with_loading("res://scenes/rooms/kamar/day1.tscn", new_game_loading_preset)
		else:
			print("LoadingManager not found, using instant scene change")
			get_tree().change_scene_to_file("res://scenes/rooms/kamar/day1.tscn")
	else:
		# No loading preset, use fade effect
		var fade_node = _create_fade_overlay()
		var fade_tween = create_tween()
		fade_tween.tween_property(fade_node, "color:a", 1.0, 0.5)
		await fade_tween.finished
		
		# Change to day 1 scene
		get_tree().change_scene_to_file("res://scenes/rooms/kamar/day1.tscn")

func _continue_game() -> void:
	if not game_completed:
		print("Game not completed yet - Continue unavailable")
		return
	
	print("Continuing game...")
	$PressedStart.play()
	
	# Set current day to 5 for continue
	GameState.current_day = 5
	
	var continue_scene = GameState.get_continue_scene()
	
	# Use loading screen if preset is assigned
	if continue_loading_preset:
		# Use LoadingManager if available
		if has_node("/root/LoadingManager"):
			get_node("/root/LoadingManager").continue_game_with_loading(continue_scene, continue_loading_preset)
		else:
			print("LoadingManager not found, using instant scene change")
			get_tree().change_scene_to_file(continue_scene)
	else:
		# No loading preset, use fade effect
		var fade_node = _create_fade_overlay()
		var fade_tween = create_tween()
		fade_tween.tween_property(fade_node, "color:a", 1.0, 0.5)
		await fade_tween.finished
		
		# Load day 5 scene for continue
		get_tree().change_scene_to_file(continue_scene)

func _open_settings() -> void:
	print("Opening settings...")
	$PressedStart.play()
	
	# Prevent opening multiple settings menus
	if in_settings_menu or current_settings_menu:
		return
	
	# Load and instantiate the options menu scene
	var options_scene = preload("res://scenes/ui/pause_menu/options_menu.tscn")
	current_settings_menu = options_scene.instantiate()
	
	# Set a flag to indicate this is called from title screen
	current_settings_menu.set_meta("called_from_title", true)
	
	add_child(current_settings_menu)
	in_settings_menu = true
	
	# Connect the return signal
	EventBus.return_to_title.connect(_on_return_from_settings, CONNECT_ONE_SHOT)

func _on_return_from_settings() -> void:
	if current_settings_menu:
		current_settings_menu.queue_free()
		current_settings_menu = null
	
	in_settings_menu = false

func _quit_game() -> void:
	print("Quitting game...")
	$PressedStart.play()
	get_tree().quit()

#==============================================================================
# ANIMASI DAN EFEK VISUAL
#==============================================================================

func _animate_logo_transition() -> Tween:
	# Phase 1: Move logo to side and bring menu from off-screen
	var logo_tween_1 = create_tween().set_parallel()
	var title_offset: int = -400 # Move title to left
	
	logo_tween_1.tween_property($Title, "position:x", title_offset, .25).set_trans(Tween.TRANS_SINE)
	logo_tween_1.tween_property(logo_mesh, "scale:x", 1.5, .25).set_trans(Tween.TRANS_SINE)
	logo_tween_1.tween_property(file_select, "position:x", MENU_OFFSCREEN_X - 200, .25).set_trans(Tween.TRANS_SINE)
	
	await logo_tween_1.finished
	
	$Whistle.play()
	
	# Phase 2: Quick transition - hide logo, move menu to center
	var logo_tween_2 = create_tween().set_parallel()
	
	create_tween().tween_property(logo_mesh, "scale:x", 0, .3).set_trans(Tween.TRANS_SINE)
	logo_tween_2.tween_property($Title, "position:x", -SCREEN_WIDTH, .5).set_trans(Tween.TRANS_SINE)
	logo_tween_2.tween_property(file_select, "position:x", MENU_CENTER_X + 100, .5).set_trans(Tween.TRANS_SINE)
	
	await logo_tween_2.finished
	
	# Phase 3: Final position - center the menu
	var logo_tween_3 = create_tween().set_parallel()
	
	logo_tween_3.tween_property($Title, "position:x", -SCREEN_WIDTH - 100, .25).set_trans(Tween.TRANS_SINE)
	logo_tween_3.tween_property(file_select, "position:x", MENU_CENTER_X, .25).set_trans(Tween.TRANS_SINE)
	
	await logo_tween_3.finished
	return logo_tween_3

func _return_to_title() -> void:
	start_button.frame_coords.y = 0
	create_tween().tween_property(%LogoOrigin, "position:x", 3.921, 1.).set_trans(Tween.TRANS_BACK)
	
	# Reverse the transition animation (adapted for 16:9)
	var logo_tween = create_tween().set_parallel()
	
	logo_tween.tween_property($Title, "position:x", -400, .25).set_trans(Tween.TRANS_SINE)
	logo_tween.tween_property(logo_mesh, "scale:x", 1.5, .25).set_trans(Tween.TRANS_SINE)
	logo_tween.tween_property(file_select, "position:x", MENU_OFFSCREEN_X - 200, .25).set_trans(Tween.TRANS_SINE)

	await logo_tween.finished

	var logo_tween_2 = create_tween().set_parallel()

	logo_tween_2.tween_property(logo_mesh, "scale:x", 1, .5).set_trans(Tween.TRANS_SINE)
	logo_tween_2.tween_property($Title, "position:x", 0, .5).set_trans(Tween.TRANS_SINE)
	logo_tween_2.tween_property(file_select, "position:x", MENU_OFFSCREEN_X, .5).set_trans(Tween.TRANS_SINE)

	await logo_tween_2.finished
	
	selected_option = 0
	
	# Reset all file visuals
	for file in files.get_children():
		var icon = file.get_node_or_null("Icon")
		if icon:
			icon.visible = false
	
	title_stage = 0

func _update_animations(delta: float) -> void:
	if logo_mesh.scale.x > 0:
		timer += 1
		if timer >= 30:
			timer = 0
		
		logo_timer += delta
		logo_mesh.rotation.z = - sin(1.5 * logo_timer * PI) * cos(logo_timer * PI / 5) * 0.25
		logo_mesh.rotation.y = - cos(1.5 * (logo_timer + 0.25) * PI) * sin(logo_timer * PI / 5) * 0.4
		logo_gift.rotation.z = cos(0.5 * logo_timer * PI) * 0.2
	
	road_mesh.position.x -= delta * 2
	if road_mesh.position.x <= -12:
		road_mesh.position.x += 12

func _create_fade_overlay() -> ColorRect:
	var fade = ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	fade.size = get_viewport().size
	fade.z_index = 100
	get_tree().current_scene.add_child(fade)
	return fade

#==============================================================================
# UTILITY FUNCTIONS
#==============================================================================

# Function to mark game as completed (call this when player beats the game)
func mark_game_completed() -> void:
	GameState.good_ending = true
	game_completed = true
	_check_game_completion()

# Debug function to test Continue button (remove in production)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and Input.is_key_pressed(KEY_F12):
		print("DEBUG: Marking game as completed")
		mark_game_completed()

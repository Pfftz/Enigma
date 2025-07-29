extends Node3D

# --- Konfigurasi ---
const READING_CARD_WAIT = 1.0

# --- Variabel State ---
var title_stage: int = 0 # State machine: 0:Title, 1:MainMenu
var selected_button_index: int = 0 # 0 = Play, 1 = Quit

# --- Variabel Animasi & Timer ---
var logo_timer: float = 0
var timer: int = 0

# --- Referensi Node (@onready) ---
@onready var logo_gift: Sprite3D = %LogoGift
@onready var start_button: Sprite2D = %StartButton
@onready var card_timer: Timer = $CardTimer
@onready var logo_mesh: MeshInstance3D = %LogoMesh
@onready var road_mesh: MeshInstance3D = %RoadMesh
# PERUBAHAN PATH: Sesuaikan jika nama container Anda berbeda
@onready var menu_container: VBoxContainer = $UI_Container/Menu_Container
@onready var play_game_button: TextureButton = $UI_Container/Menu_Container/PlayGameButton
@onready var quit_game_button: TextureButton = $UI_Container/Menu_Container/QuitGameButton
@onready var fade: ColorRect = $Fade

#==============================================================================
# FUNGSI UTAMA
#==============================================================================

func _ready() -> void:
	# Sembunyikan seluruh menu di awal, bukan per tombol
	menu_container.visible = false
	
	# ... (sisa fungsi _ready() tetap sama) ...
	$Song.play()
	if AudioManager.get_current_bg_track() != "res://music/petscop.ogg":
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
	start_button.visible = bool(int(timer < 24))
	if Input.is_action_just_pressed("pressed_start"):
		title_stage = -1
		$PressedStart.play()
		start_button.visible = false
		
		# Nonaktifkan tombol selama transisi
		play_game_button.disabled = true
		quit_game_button.disabled = true
		
		card_timer.wait_time = READING_CARD_WAIT
		card_timer.start()
		await card_timer.timeout
		
		var transition_tween := create_tween().set_parallel()
		transition_tween.tween_property(logo_mesh, "scale", Vector3.ZERO, 0.4).set_trans(Tween.TRANS_SINE)
		transition_tween.tween_property(logo_gift, "scale", Vector3.ZERO, 0.4).set_trans(Tween.TRANS_SINE)
		
		# Munculkan menu dengan animasi fade-in
		menu_container.visible = true
		menu_container.modulate = Color(1, 1, 1, 0) # Mulai dari transparan
		transition_tween.tween_property(menu_container, "modulate:a", 1.0, 0.5) # Fade in ke solid
		
		await transition_tween.finished
		
		await get_tree().create_timer(0.05).timeout
		
		play_game_button.disabled = false
		quit_game_button.disabled = false
		
		_update_button_visuals()
		title_stage = 1

func _state_main_menu() -> void:
	# ... (fungsi ini tetap sama) ...
	if Input.is_action_just_pressed("ui_down"):
		if selected_button_index == 0:
			selected_button_index = 1
			$PressedStart.play()
			_update_button_visuals()
	if Input.is_action_just_pressed("ui_up"):
		if selected_button_index == 1:
			selected_button_index = 0
			$PressedStart.play()
			_update_button_visuals()
	if Input.is_action_just_pressed("pressed_start"):
		match selected_button_index:
			0: _on_play_game_button_pressed()
			1: _on_quit_game_button_pressed()

# ... (sisa fungsi lainnya tetap sama) ...
func _on_play_game_button_pressed() -> void:
	if title_stage != 1: return
	title_stage = -1
	$PressedStart.play()
	var fade_tween := create_tween()
	fade_tween.tween_property(fade, "color:a", 1.0, 0.5)
	await fade_tween.finished
	get_tree().change_scene_to_file("res://scenes/rooms/ruang1.tscn")

func _on_quit_game_button_pressed() -> void:
	if title_stage != 1: return
	get_tree().quit()

func _update_button_visuals() -> void:
	if selected_button_index == 0:
		play_game_button.modulate = Color.WHITE
		quit_game_button.modulate = Color(0.7, 0.7, 0.7)
	else:
		play_game_button.modulate = Color(0.7, 0.7, 0.7)
		quit_game_button.modulate = Color.WHITE

func _update_animations(delta: float) -> void:
	if logo_mesh.scale.x > 0:
		timer += 1
		if timer >= 30: timer = 0
		logo_timer += delta
		logo_mesh.rotation.z = - sin(1.5 * logo_timer * PI) * cos(logo_timer * PI / 5) * 0.25
		logo_mesh.rotation.y = - cos(1.5 * (logo_timer + 0.25) * PI) * sin(logo_timer * PI / 5) * 0.4
		logo_gift.rotation.z = cos(2.5 * logo_timer * PI) * 0.2
	road_mesh.position.x -= delta * 2
	if road_mesh.position.x <= -12:
		road_mesh.position.x += 12

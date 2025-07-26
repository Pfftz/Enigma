extends Node3D

# --- Konfigurasi ---
const READING_CARD_WAIT = 1.0

# --- Variabel State ---
var title_stage: int = 0     # State machine: 0:Title, 1:MainMenu

# --- Variabel Animasi & Timer ---
var logo_timer: float = 0
var timer: int = 0

# --- Referensi Node (@onready) ---
@onready var logo_gift: Sprite3D = %LogoGift
@onready var start_button: Sprite2D = %StartButton
@onready var card_timer: Timer = $CardTimer
@onready var logo_mesh: MeshInstance3D = %LogoMesh
@onready var road_mesh: MeshInstance3D = %RoadMesh
@onready var play_game_button: TextureButton = $PlayGameButton
@onready var fade: ColorRect = $Fade

#==============================================================================
# FUNGSI UTAMA
#==============================================================================

func _ready() -> void:
	print("DEBUG: Scene is ready. Initializing...")
	play_game_button.visible = false
	if BGMusic.get_stream_path() != "res://music/petscop.ogg":
		BGMusic.stream_paused = true
	get_tree().paused = false
	Global.is_game_paused = false
	Global.can_pause = false
	RenderingServer.global_shader_parameter_set("fog_enabled", true)
	RenderingServer.global_shader_parameter_set("fog_color", Vector3.ONE)
	RenderingServer.global_shader_parameter_set("fog_size", 25.0)
	print("DEBUG: Initialization complete.")

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
		print("DEBUG: 'pressed_start' detected. Starting transition...")
		title_stage = -1
		$PressedStart.play()
		start_button.visible = false
		
		play_game_button.disabled = true
		
		card_timer.wait_time = READING_CARD_WAIT
		card_timer.start()
		await card_timer.timeout
		
		print("DEBUG: Timer finished. Tweening now...")
		var transition_tween := create_tween().set_parallel()
		transition_tween.tween_property(logo_mesh, "scale", Vector3.ZERO, 0.4).set_trans(Tween.TRANS_SINE)
		transition_tween.tween_property(logo_gift, "scale", Vector3.ZERO, 0.4).set_trans(Tween.TRANS_SINE)
		
		play_game_button.visible = true
		play_game_button.position.y = -240.0
		transition_tween.tween_property(play_game_button, "position:y", 83.0, 0.5).set_trans(Tween.TRANS_SINE)
		
		await transition_tween.finished
		print("DEBUG: Tween finished.")
		
		await get_tree().create_timer(0.05).timeout # Sedikit jeda tambahan untuk keamanan
		
		play_game_button.disabled = false
		print("DEBUG: PlayGameButton is now ENABLED.")
		
		title_stage = 1
		print("DEBUG: State changed to Main Menu (title_stage = 1)")

func _state_main_menu() -> void:
	# Cek apakah tombol "confirm" (Enter/Spasi) baru saja ditekan
	if Input.is_action_just_pressed("pressed_action"):
		print("DEBUG: 'pressed_confirm' (keyboard) detected!")
		_on_play_game_button_pressed()

# Fungsi ini dipanggil oleh sinyal button ATAU dari input keyboard
func _on_play_game_button_pressed() -> void:
	print("DEBUG: _on_play_game_button_pressed function was called.")
	if title_stage != 1:
		print("DEBUG: ACTION IGNORED because title_stage is not 1. Current stage is: %d" % title_stage)
		return
		
	title_stage = -1
	print("DEBUG: Action confirmed! Starting game...")
	$PressedStart.play()
	
	var fade_tween := create_tween()
	fade_tween.tween_property(fade, "color:a", 1.0, 0.5)
	await fade_tween.finished
	
	get_tree().change_scene_to_file("res://scenes/ruang1.tscn")

#==============================================================================
# FUNGSI BANTU (Helpers)
#==============================================================================
func _update_animations(delta: float) -> void:
	if logo_mesh.scale.x > 0:
		timer += 1
		if timer >= 30:
			timer = 0
		logo_timer += delta
		logo_mesh.rotation.z = -sin(1.5 * logo_timer * PI) * cos(logo_timer * PI / 5) * 0.25
		logo_mesh.rotation.y = -cos(1.5 * (logo_timer + 0.25) * PI) * sin(logo_timer * PI / 5) * 0.4
		logo_gift.rotation.z = cos(2.5 * logo_timer * PI) * 0.2
	road_mesh.position.x -= delta * 2
	if road_mesh.position.x <= -12:
		road_mesh.position.x += 12

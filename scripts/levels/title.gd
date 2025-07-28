extends Node3D

# --- Konfigurasi ---
const READING_CARD_WAIT = 1.0

# --- Variabel State ---
var title_stage: int = 0     # State machine: 0:Title, 1:MainMenu
var selected_button_index: int = 0 # Variabel BARU: 0 = Play, 1 = Quit

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
@onready var quit_game_button: TextureButton = $QuitGameButton
@onready var fade: ColorRect = $Fade

#==============================================================================
# FUNGSI UTAMA
#==============================================================================

func _ready() -> void:
	play_game_button.visible = false
	quit_game_button.visible = false
	$Song.play()
	if BGMusic.get_stream_path() != "res://music/petscop.ogg":
		BGMusic.stream_paused = true
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
		
		play_game_button.disabled = true
		quit_game_button.disabled = true
		
		card_timer.wait_time = READING_CARD_WAIT
		card_timer.start()
		await card_timer.timeout
		
		var transition_tween := create_tween().set_parallel()
		transition_tween.tween_property(logo_mesh, "scale", Vector3.ZERO, 0.4).set_trans(Tween.TRANS_SINE)
		transition_tween.tween_property(logo_gift, "scale", Vector3.ZERO, 0.4).set_trans(Tween.TRANS_SINE)
		
		play_game_button.visible = true
		quit_game_button.visible = true
		# Atur posisi awal tombol (sesuaikan jika perlu)
		play_game_button.position = Vector2(play_game_button.position.x, -240.0)
		quit_game_button.position = Vector2(quit_game_button.position.x, -200.0)
		# Animasikan tombol ke posisi akhir
		transition_tween.tween_property(play_game_button, "position:y", 83.0, 0.5).set_trans(Tween.TRANS_SINE)
		transition_tween.tween_property(quit_game_button, "position:y", 123.0, 0.5).set_trans(Tween.TRANS_SINE)
		
		await transition_tween.finished
		
		await get_tree().create_timer(0.05).timeout
		
		play_game_button.disabled = false
		quit_game_button.disabled = false
		
		# Set visual awal untuk tombol yang dipilih
		_update_button_visuals()
		
		title_stage = 1

# PEROMBAKAN BESAR DI SINI
func _state_main_menu() -> void:
	# --- Tangani Input Navigasi Atas/Bawah ---
	if Input.is_action_just_pressed("ui_down"):
		if selected_button_index == 0: # Jika sedang di Play, pindah ke Quit
			selected_button_index = 1
			$PressedStart.play() # Ganti dengan suara navigasi jika ada
			_update_button_visuals()
			
	if Input.is_action_just_pressed("ui_up"):
		if selected_button_index == 1: # Jika sedang di Quit, pindah ke Play
			selected_button_index = 0
			$PressedStart.play()
			_update_button_visuals()

	# --- Tangani Input Konfirmasi ---
	# Menggunakan "pressed_start" sesuai permintaan Anda
	if Input.is_action_just_pressed("pressed_start"):
		match selected_button_index:
			0: # Jika Play yang dipilih
				_on_play_game_button_pressed()
			1: # Jika Quit yang dipilih
				_on_quit_game_button_pressed()

# Fungsi yang dipanggil saat tombol Play ditekan (baik via mouse atau keyboard)
func _on_play_game_button_pressed() -> void:
	if title_stage != 1: return
	title_stage = -1
	$PressedStart.play()
	
	var fade_tween := create_tween()
	fade_tween.tween_property(fade, "color:a", 1.0, 0.5)
	await fade_tween.finished
	
	get_tree().change_scene_to_file("res://scenes/ruang1.tscn")

# Fungsi yang dipanggil saat tombol Quit ditekan (baik via mouse atau keyboard)
func _on_quit_game_button_pressed() -> void:
	if title_stage != 1: return
	get_tree().quit()

#==============================================================================
# FUNGSI BANTU (Helpers)
#==============================================================================

# FUNGSI BARU: Memberi umpan balik visual pada tombol
func _update_button_visuals() -> void:
	# Tombol yang dipilih akan berwarna normal, yang lain agak gelap
	if selected_button_index == 0: # Play dipilih
		play_game_button.modulate = Color.WHITE
		quit_game_button.modulate = Color(0.7, 0.7, 0.7)
	else: # Quit dipilih
		play_game_button.modulate = Color(0.7, 0.7, 0.7)
		quit_game_button.modulate = Color.WHITE

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

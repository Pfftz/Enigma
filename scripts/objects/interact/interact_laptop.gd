extends Area3D

var player_in_area := false
var using_phantom_camera := false
@onready var interaction_symbol = get_node_or_null("../InteractionSymbol")

# --- Konfigurasi Animasi & Scene ---
var camera_move_distance := 0.5
var camera_move_duration := 1.5
const INTERVIEW_SCENE_PATH = "res://scenes/ui/dialogic_qte_interview.tscn" # <-- GANTI PATH INI JIKA PERLU
@onready var ui: CanvasLayer = $"../UI"

func _ready():
	# Don't connect signals manually - they're already connected in the scene
	# body_entered.connect(_on_body_entered)
	# body_exited.connect(_on_body_exited)
	# Disable interaction symbol if interview is already completed or it's Day 5
	if GameState.is_interview_completed(GameState.current_day) or GameState.current_day == 5:
		if interaction_symbol:
			interaction_symbol.enabled = false
			interaction_symbol.deactivate()

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Check if interview has already been completed for current day
		if GameState.is_interview_completed(GameState.current_day):
			# Don't show any UI or respond to interaction - symbol should already be gone
			return
		
		# Check if this is Day 5 - Day 5 QTE should only be triggered from interact_gedung
		if GameState.current_day == 5:
			return
		
		player_in_area = true
		show_interact_ui(true)

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		show_interact_ui(false)
	
func show_interact_ui(show_ui: bool):
	if show_ui:
		get_tree().call_group("ui", "show_interact_text", "Tekan \"F\" untuk berinteraksi")
	else:
		get_tree().call_group("ui", "hide_interact_text")

# Fungsi input sekarang menangani animasi DAN pindah scene
func _input(event):
	if player_in_area and event.is_action_pressed("interact"):
		# Check if interview has already been completed for current day
		if GameState.is_interview_completed(GameState.current_day):
			show_interact_ui(false)
			player_in_area = false
			return
		
		# Check if this is Day 5 - Day 5 QTE should only be triggered from interact_gedung
		if GameState.current_day == 5:
			show_interact_ui(false)
			player_in_area = false
			return
		
		# Pastikan interaksi hanya berjalan sekali
		show_interact_ui(false)
		if using_phantom_camera:
			return
		
		# Nonaktifkan interaksi lebih lanjut
		player_in_area = false
		
		# Jalankan urutan animasi lalu pindah scene
		play_animation_and_change_scene()

func play_animation_and_change_scene():
	using_phantom_camera = true
	print("[DEBUG] Memulai urutan animasi dan pindah scene...")
	
	var main_camera = get_tree().current_scene.get_node_or_null("Camera3D")
	var phantom_camera = get_tree().current_scene.get_node_or_null("PhantomCamera3D2")

	# Pengecekan paling penting ada di sini
	if phantom_camera:
		print("[DEBUG] Node 'PhantomCamera3D2' DITEMUKAN.")
		if main_camera:
			main_camera.current = false
		
		var cam = phantom_camera.get_node_or_null("Camera3D")
		if cam:
			cam.current = true
		
		print("[DEBUG] Memulai animasi pergerakan kamera...")
		var animation_tween = move_camera_left(phantom_camera)
		
		# Tunggu sampai animasi pergerakan kamera SELESAI
		await animation_tween.finished
		print("[DEBUG] Animasi kamera SELESAI.")
		
		# SETELAH animasi selesai, baru panggil fungsi untuk pindah scene
		print("[DEBUG] Memulai proses fade out dan pindah scene...")
		fade_out_and_change_scene()
	else:
		# Jika phantom_camera tidak ditemukan, pesan ini akan muncul
		print("[FATAL ERROR] Node 'PhantomCamera3D2' TIDAK DITEMUKAN. Periksa nama dan path node di Scene Tree Anda. Proses berhenti.")

# Fungsi animasi kamera, sekarang mengembalikan Tween
func move_camera_left(camera_node) -> Tween:
	var start_pos = camera_node.position
	var target_pos = start_pos - Vector3(camera_move_distance, 0, 0)
	var tween = create_tween()
	tween.tween_property(camera_node, "position", target_pos, camera_move_duration)
	return tween

# Fungsi untuk fade out dan pindah scene
func fade_out_and_change_scene():
	var fade_rect = get_tree().current_scene.find_child("Fade", true, false)
	
	if fade_rect and fade_rect is ColorRect:
		fade_rect.visible = true
		var tween = create_tween()
		tween.tween_property(fade_rect, "modulate:a", 1.0, 0.5)
		await tween.finished
		get_tree().change_scene_to_file(INTERVIEW_SCENE_PATH)
	else:
		get_tree().change_scene_to_file(INTERVIEW_SCENE_PATH)

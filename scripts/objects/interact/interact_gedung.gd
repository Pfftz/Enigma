extends Area3D

var player_in_area := false
@onready var interaction_prompt = $Label3D

# --- Konfigurasi Scene ---
const INTERVIEW_SCENE_PATH = "res://scenes/ui/dialogic_qte_interview.tscn" # <-- Sesuaikan path ini jika perlu

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if interaction_prompt:
		interaction_prompt.visible = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = true
		if interaction_prompt:
			interaction_prompt.visible = true
		show_interact_ui(true)

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		if interaction_prompt:
			interaction_prompt.visible = false
		show_interact_ui(false)
	
func show_interact_ui(show: bool):
	if show:
		get_tree().call_group("ui", "show_interact_text", "Pencet F untuk interaksi")
	else:
		get_tree().call_group("ui", "hide_interact_text")

func _input(event):
	if player_in_area and event.is_action_pressed("interact"):
		# Nonaktifkan interaksi lebih lanjut untuk mencegah input ganda
		player_in_area = false
		show_interact_ui(false)
		if interaction_prompt:
			interaction_prompt.visible = false
		
		# Langsung panggil fungsi untuk fade out dan pindah scene
		fade_out_and_change_scene()

func fade_out_and_change_scene():
	var fade_rect = get_tree().current_scene.find_child("Fade", true, false)
	
	if fade_rect and fade_rect is ColorRect:
		fade_rect.visible = true
		var tween = create_tween()
		# Animasikan layar menjadi gelap
		tween.tween_property(fade_rect, "modulate:a", 1.0, 0.5)
		await tween.finished
		# Setelah gelap, baru pindah scene
		get_tree().change_scene_to_file(INTERVIEW_SCENE_PATH)
	else:
		# Jika tidak ada node Fade, langsung pindah scene
		print("Node 'Fade' tidak ditemukan, langsung pindah scene.")
		get_tree().change_scene_to_file(INTERVIEW_SCENE_PATH)

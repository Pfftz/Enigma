extends Area3D

var player_in_area := false
@onready var interaction_prompt = $Label3D

# --- Konfigurasi Scene ---
const INTERVIEW_SCENE_PATH = "res://scenes/ui/dialogic_qte_interview.tscn" # <-- Sesuaikan path ini jika perlu
const DAY5_INTRO_TIMELINE = "monolog/day5-C1" # Timeline untuk day5.dtl
var day5_intro_played := false
var waiting_for_day5_timeline := false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if interaction_prompt:
		interaction_prompt.visible = false
	
	# Connect to Dialogic signals for handling day5.dtl completion
	Dialogic.timeline_ended.connect(_on_day5_timeline_ended)

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
	
func show_interact_ui(show_ui: bool):
	if show_ui:
		get_tree().call_group("ui", "show_interact_text", "Press F to interact")
	else:
		get_tree().call_group("ui", "hide_interact_text")

func _input(event):
	if player_in_area and event.is_action_pressed("interact"):
		# Nonaktifkan interaksi lebih lanjut untuk mencegah input ganda
		player_in_area = false
		show_interact_ui(false)
		if interaction_prompt:
			interaction_prompt.visible = false
		
		# Start the Day 5 sequence: play day5.dtl first
		start_day5_sequence()

func start_day5_sequence():
	print("[DEBUG] Starting Day 5 sequence with day5.dtl...")
	# Set GameState to Day 5 for QTE later
	GameState.current_day = 5
	
	# Set flag to indicate we're waiting for day5 timeline to end
	waiting_for_day5_timeline = true
	
	# Start playing day5.dtl timeline
	Dialogic.start(DAY5_INTRO_TIMELINE)

func _on_day5_timeline_ended():
	# Only proceed if we were waiting for the day5 timeline and it hasn't been played yet
	if waiting_for_day5_timeline and not day5_intro_played:
		print("[DEBUG] day5.dtl finished, starting Day 5 QTE...")
		day5_intro_played = true
		waiting_for_day5_timeline = false
		# Now start the Day 5 QTE interview
		fade_out_and_change_scene()

func fade_out_and_change_scene():
	var fade_rect = get_tree().current_scene.find_child("Fade", true, false)
	
	if fade_rect and fade_rect is ColorRect:
		fade_rect.visible = true
		var tween = create_tween()
		# Animasikan layar menjadi gelap
		tween.tween_property(fade_rect, "modulate:a", 1.0, 0.5)
		await tween.finished
		# Setelah gelap, baru pindah scene ke QTE Day 5
		get_tree().change_scene_to_file(INTERVIEW_SCENE_PATH)
	else:
		# Jika tidak ada node Fade, langsung pindah scene
		print("Node 'Fade' tidak ditemukan, langsung pindah scene.")
		get_tree().change_scene_to_file(INTERVIEW_SCENE_PATH)

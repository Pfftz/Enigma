extends Area3D

var player_is_near = false
# Opsional: Tambahkan Label3D untuk prompt interaksi
@onready var interaction_prompt = $Label3D

func _ready():
	if interaction_prompt:
		interaction_prompt.visible = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_is_near = true
		if interaction_prompt:
			interaction_prompt.visible = true
		show_interact_ui(true)

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_is_near = false
		if interaction_prompt:
			interaction_prompt.visible = false
		show_interact_ui(false)
			
func show_interact_ui(show: bool):
	if show:
		get_tree().call_group("ui", "show_interact_text", "Tekan \"F\" untuk berinteraksi")
	else:
		get_tree().call_group("ui", "hide_interact_text")

func _process(delta):
	if player_is_near and Input.is_action_just_pressed("interact"):
		go_to_next_day()

func go_to_next_day():
	# Nonaktifkan interaksi untuk mencegah input ganda
	player_is_near = false
	if interaction_prompt:
		interaction_prompt.visible = false

	print("Player pergi tidur...")

	# Di sini Anda bisa memutar animasi fade out
	var fade_rect = get_tree().current_scene.find_child("Fade", true, false)
	if fade_rect:
		var tween = create_tween()
		tween.tween_property(fade_rect, "modulate:a", 1.0, 1.0) # Fade to black
		await tween.finished

	# 1. Maju ke hari berikutnya
	GameState.advance_to_next_day()

	# 2. Ambil path kamar untuk hari yang BARU
	var next_room_path = GameState.get_current_room_scene()

	# 3. Pindah ke scene kamar berikutnya
	get_tree().change_scene_to_file(next_room_path)

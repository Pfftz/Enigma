extends Area3D

var player_in_area := false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = true
		show_interact_ui(true)

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		show_interact_ui(false)

func show_interact_ui(show: bool):
	# Ganti dengan cara menampilkan UI di project Anda
	if show:
		get_tree().call_group("ui", "show_interact_text", "Pencet F untuk interaksi")
	else:
		get_tree().call_group("ui", "hide_interact_text")

func _input(event):
	if player_in_area and event.is_action_pressed("interact"):
		# Ubah mode kamera player
		var player = get_overlapping_bodies().filter(func(b): return b.is_in_group("player"))[0]
		if player and player.has_method("get_camera_controller"):
			var cam = player.get_camera_controller()
			if cam:
				cam.set_preset_dramatic() # Atau preset lain sesuai kebutuhan
		show_interact_ui(false)

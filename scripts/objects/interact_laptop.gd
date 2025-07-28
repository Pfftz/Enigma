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
			# Matikan kamera utama
			var main_camera = get_tree().current_scene.get_node("Camera3D")
			if main_camera:
				main_camera.current = false

			# Aktifkan PhantomCamera3D2
			var phantom_camera = get_tree().current_scene.get_node("PhantomCamera3D2")
			if phantom_camera:
				# Zoom-in (jika ada property follow_distance)
				if "follow_distance" in phantom_camera:
					var tween = create_tween()
					tween.tween_property(phantom_camera, "follow_distance", 0.7, 0.5)
				# Aktifkan Camera3D di dalam PhantomCamera3D2
				var cam = phantom_camera.get_node_or_null("Camera3D")
				if cam:
					cam.current = true
				# Atau panggil method activate/make_current jika ada
				if phantom_camera.has_method("activate"):
					phantom_camera.activate()
				elif phantom_camera.has_method("make_current"):
					phantom_camera.make_current()

			show_interact_ui(false)

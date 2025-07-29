extends Area3D

var player_in_area := false
var using_phantom_camera := false

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
	if show:
		get_tree().call_group("ui", "show_interact_text", "Pencet F untuk interaksi")
	else:
		get_tree().call_group("ui", "hide_interact_text")

func _input(event):
	if player_in_area and event.is_action_pressed("interact"):
		var main_camera = get_tree().current_scene.get_node("Camera3D")
		var phantom_camera = get_tree().current_scene.get_node("PhantomCamera3D2")
		if not using_phantom_camera:
			# Matikan kamera utama
			if main_camera:
				main_camera.current = false
			# Aktifkan PhantomCamera3D2
			if phantom_camera:
				if "follow_distance" in phantom_camera:
					var tween = create_tween()
					tween.tween_property(phantom_camera, "follow_distance", 0.7, 0.5)
				var cam = phantom_camera.get_node_or_null("Camera3D")
				if cam:
					cam.current = true
				if phantom_camera.has_method("activate"):
					phantom_camera.activate()
				elif phantom_camera.has_method("make_current"):
					phantom_camera.make_current()
			using_phantom_camera = true
		else:
			# Kembali ke kamera utama
			if phantom_camera:
				var cam = phantom_camera.get_node_or_null("Camera3D")
				if cam:
					cam.current = false
			if main_camera:
				main_camera.current = true
			using_phantom_camera = false

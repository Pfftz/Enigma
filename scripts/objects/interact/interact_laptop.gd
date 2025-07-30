extends Area3D

var player_in_area := false
var using_phantom_camera := false
@onready var interaction_prompt = $Label3D
var camera_move_distance := 0.5
var camera_move_duration := 1.5
var phantom_camera_prev_pos: Vector3
var player2_scene := preload("res://scenes/objects/player/player.tscn") # Ganti path sesuai scene Player2
var player2_instance: Node = null
var kursi_collision_path := "/root/Ruang1Test/Collision/StaticBody3D/Kursi" # Ganti sesuai path kursi di scene

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

func fade_camera_switch(callback: Callable):
	var fade_rect = get_tree().current_scene.get_node("FadeRect")
	if fade_rect:
		fade_rect.visible = true
		fade_rect.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(fade_rect, "modulate:a", 1.0, 0.3)
		tween.tween_callback(callback)
		tween.tween_property(fade_rect, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func(): fade_rect.visible = false)
	else:
		callback.call()

func _input(event):
	if player_in_area and event.is_action_pressed("interact"):
		fade_camera_switch(func():
			var main_camera = get_tree().current_scene.get_node("Camera3D")
			var phantom_camera = get_tree().current_scene.get_node("PhantomCamera3D2")
			var kursi_collision = get_node_or_null(kursi_collision_path)
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
					phantom_camera_prev_pos = phantom_camera.position
					move_camera_left(phantom_camera)
				using_phantom_camera = true

				# Hilangkan Player, munculkan Player2
				var player = get_tree().current_scene.get_node_or_null("Player")
				if player:
					player.visible = false
				if not player2_instance:
					player2_instance = player2_scene.instantiate()
					get_tree().current_scene.add_child(player2_instance)
					player2_instance.position = Vector3(0, 1, 0) # Atur posisi spawn Player2
					# Benar-benar static: matikan semua proses dan input
					player2_instance.set_process(false)
					player2_instance.set_physics_process(false)
					if player2_instance.has_method("set_process_input"):
						player2_instance.set_process_input(false)
				# Hilangkan kursi collision
				if kursi_collision:
					kursi_collision.visible = false
			else:
				# Kembali ke kamera utama dan posisi awal PhantomCamera3D2
				if phantom_camera:
					var cam = phantom_camera.get_node_or_null("Camera3D")
					if cam:
						cam.current = false
					var tween = create_tween()
					tween.tween_property(phantom_camera, "position", phantom_camera_prev_pos, camera_move_duration)
				if main_camera:
					main_camera.current = true
				using_phantom_camera = false

				# Hilangkan Player2, munculkan Player
				if player2_instance:
					player2_instance.queue_free()
					player2_instance = null
				var player = get_tree().current_scene.get_node_or_null("Player")
				if player:
					player.visible = true
				# Kembalikan kursi collision
				if kursi_collision:
					kursi_collision.visible = true

			if interaction_prompt:
				interaction_prompt.visible = false
			show_interact_ui(false)
		)

func move_camera_left(phantom_camera):
	var start_pos = phantom_camera.position
	var target_pos = start_pos - Vector3(camera_move_distance, 0, 0)
	var tween = create_tween()
	tween.tween_property(phantom_camera, "position", target_pos, camera_move_duration)

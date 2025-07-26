extends Control

var fullscreen: bool = false

@onready var file_dialog: FileDialog = $FileDialog


func _process(_delta: float) -> void:
	#CHECKS INPUTS FOR SHEET FOLDER HOTKEY AND FULLSCREEN BUTTON
	if Input.is_action_just_pressed("open_sheet_folder"):
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://sheets"), true)

	if Input.is_action_just_pressed("fullscreen"):
		fullscreen = !fullscreen
		DisplayServer.window_set_mode(
										DisplayServer.WINDOW_MODE_FULLSCREEN
										if fullscreen
										else
											DisplayServer.WINDOW_MODE_WINDOWED
										)


func reset_game() -> void:
	Global.current_controller = 0
	Global.can_pause = true
	Global.can_unpause = false
	Global.is_game_paused = false
	Global.demo_timer_multiplier = 1
	
	Global.warp_to(
						"res://scene/title/title.tscn",
						load("res://resource/loading_preset/ec_noload.tres")
					)
	
	EventBus.destroy_hud.emit()


func hard_reset_game() -> void:
	GameManager.save_debug_settings()
	EventBus.destroy_hud.emit()
	EventBus.destroy_pause.emit()
	Global.save_global()
	get_tree().paused = false
	# BGMusic.stream_paused = true
	Global.current_controller = 0
	Global.can_pause = true
	Global.can_unpause = false
	Global.is_game_paused = false
	Global.draw_mode = false
	Global.demo_timer_multiplier = 1
	
	get_tree().change_scene_to_file("res://scene/title/garalina.tscn")


#SYSTEM NOTIF CLASS IS UNKNOWN
func _notification(system_notif) -> void:
	if system_notif == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit() # default behavior

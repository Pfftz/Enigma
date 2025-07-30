extends Control

const CURSOR_PIXELS: float = 8.0
const CURSOR_SPEED: float = 0.5

var selected_option: int = 0:
	set(value):
		button_sound.play()
		selected_option = value

var in_menu: bool = false
var returning: bool = false
var cursor_tween: Tween
var is_from_title_screen: bool = false # Track whether this was opened from title screen

@onready var cursor: Sprite2D = %Cursor
@onready var cursor_pos: Marker2D = $CursorPos
@onready var option_buttons: Marker2D = $OptionButtons
@onready var sound_menu: Sprite2D = %SoundMenu
@onready var sub_menu: Control = %SubMenu
@onready var button_sound: AudioStreamPlayer = $ButtonSound
@onready var cross_button: AnimatedSprite2D = %CrossButton
@onready var triangle_button: AnimatedSprite2D = %TriangleButton


func _ready() -> void:
	EventBus.return_to_options.connect(unfreeze)
	
	# Detect if we're in title screen context
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.name == "TitleScreen":
		is_from_title_screen = true
		print("Options menu detected title screen context via scene name")
	
	# Also check for meta property set by title screen
	if has_meta("called_from_title"):
		is_from_title_screen = true
		print("Options menu detected title screen context via meta property")
	
	print("Options menu is_from_title_screen: ", is_from_title_screen)

	cursor_tween = create_tween().set_loops()
	cursor_tween.tween_property(cursor, "position:x", -CURSOR_PIXELS, CURSOR_SPEED).set_trans(Tween.TRANS_SINE).as_relative()
	cursor_tween.tween_property(cursor, "position:x", CURSOR_PIXELS, CURSOR_SPEED).set_trans(Tween.TRANS_SINE).as_relative()
	
	if Global.global_data.gen == 6:
		button_sound.move_stream(0, 1)


func _process(delta: float) -> void:
	if !in_menu:
		if !returning:
			cursor_pos.global_position.y = lerp(
													cursor_pos.global_position.y,
													float(selected_option * 32),
													8.0 * delta
												)
			cursor.frame = selected_option
			
			if (
					Input.is_action_just_pressed("pressed_down") and
					selected_option < option_buttons.get_child_count() - 1
				):
					selected_option += 1
			
			if Input.is_action_just_pressed("pressed_up") and selected_option > 0:
				selected_option -= 1
			
			for button in option_buttons.get_children():
				if button.get_index() == selected_option:
					button.frame_coords.x = 1
				else:
					button.frame_coords.x = 0
			
			if Input.is_action_just_pressed("pressed_action") and selected_option > 1:
				in_menu = true
				$SelectSound.play()
				
				# HUD.fade_animation(Color(1.0, 0.85, 1.0))
				# await HUD.transition_middle
				
				# Simple fade effect replacement
				await get_tree().create_timer(0.3).timeout
				
				cursor_tween.pause()
				cross_button.pause()
				triangle_button.pause()
				
				
				match selected_option:
					3:
						# BGMusic.mute()
						# sub_menu.add_child(SOUND_TEST.instantiate())
						# TODO: Implement sound test menu
						pass
			
			if Input.is_action_just_pressed("pressed_triangle"):
				returning = true
				
				print("Triangle pressed, is_from_title_screen: ", is_from_title_screen)
				
				# HUD.fade_animation(Color(1.0, 0.85, 1.0))
				# await HUD.transition_middle
				
				# Simple fade effect replacement
				await get_tree().create_timer(0.3).timeout
				
				# Handle return based on context
				if is_from_title_screen:
					# Return to title screen - emit return_to_options signal
					print("Emitting return_to_options signal")
					EventBus.return_to_options.emit()
				else:
					# Return to pause menu
					print("Emitting return_to_pause signal")
					EventBus.return_to_pause.emit()
				
				queue_free()


func unfreeze() -> void:
	in_menu = false
	cursor_tween.play()
	cross_button.play()
	triangle_button.play()

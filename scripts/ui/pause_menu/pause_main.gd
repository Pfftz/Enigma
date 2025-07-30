extends Control

## The code for the Pause Menu, it is instantiated as an object inside and by the [Level].


const BUTTON_ANIM_SPEED: float = 1 ## Speed of the pause buttons animation.
const BUTTON_OFFSET: float = 10 ## Distance the button should move when selected in pixels.
const SCREEN_ANIM_TIME: float = 1.0 ## Speed for the shrinking screen's animation
const MINI_SCREEN_SIZE: float = 0.5 ## The size of the shrinking screen.
const OPTIONS_MENU: PackedScene = preload("res://scenes/ui/pause_menu/options_menu.tscn") ## The scene for the options menu.
const QUIT_MENU: PackedScene = preload("res://scenes/ui/pause_menu/quit_buttons.tscn") ## The scene for the quit menu, spawned on top of the pause menu.

var level_slogan: String = "" ## Level slonga, provided by the [Level] node.
var _in_menu: bool = false ## Variable responsible for toggling whether you're in a submenu.
var _selected_option: int = 0: ## Currently selected option, the set function is responsible for playing the sound.
	set(value):
		button_sound.play()
		_selected_option = value
var allow_input: bool = true ## Variable responsible for toggling input in the pause menu.
var secret_code: bool = false ## Variable responsible for toggling whether the secret code is enabled.
var current_key: int = 0
var code_array: Array[String] = [
									"pressed_down",
									"pressed_down",
									"pressed_down",
									"pressed_down",
									"pressed_down",
									"pressed_right",
									"pressed_start"
								]
var unlocked_nmp: bool = false
var inside_wheel: bool = false
var wheel_id: int = 0

@onready var main_menu: Control = %Main
@onready var buttons_origin: Marker2D = %ButtonsOrigin
@onready var button_sound: AudioStreamPlayer = $ButtonSound
@onready var screenshot: Sprite2D = %Screenshot
@onready var counter_label: Label = %CounterLabel
# @onready var slogan_label: Label = %SloganLabel
@onready var fade_overlay: Sprite2D = %FadeOverlay
@onready var piece: AnimatedSprite2D = %Piece
@onready var cross_button: AnimatedSprite2D = %CrossButton
@onready var start_button: AnimatedSprite2D = %StartButton
@onready var sub_menu: Control = %SubMenu


func _ready() -> void:
	EventBus.pause_leave_sfx.connect(leave_sfx)
	EventBus.game_paused.emit()
	EventBus.destroy_hud.connect(_on_destruction)
	EventBus.destroy_pause.connect(_on_destruction)
	EventBus.return_to_pause.connect(_on_return_to_pause)
	EventBus.crash_game.connect(crash_pause_menu)
	
	Global.can_unpause = false
	get_tree().paused = true
	
	visible = false

	# slogan_label.text = level_slogan
	fade_overlay.modulate.a = 0.0

	if Global.global_data.gen == 6:
		button_sound.move_stream(0, 1)
	
	screenshot.z_index = 2
	screenshot.set_texture(get_screen())
	visible = true
	
	var shrink: Tween = create_tween()
	
	shrink.tween_property(
								screenshot,
								"scale",
								Vector2(
											MINI_SCREEN_SIZE,
											MINI_SCREEN_SIZE
										),
								SCREEN_ANIM_TIME
							).set_trans(Tween.TRANS_SINE)
	
	await shrink.finished
	
	screenshot.z_index = 0
	Global.can_unpause = true
	Global.is_game_paused = true


func _process(_delta: float) -> void:
	if !_in_menu && Global.can_unpause:
		if (
			Input.is_action_just_pressed("pressed_up")
			or Input.is_action_just_pressed("pressed_down")
			or Input.is_action_just_pressed("pressed_left")
			or Input.is_action_just_pressed("pressed_right")
			or Input.is_action_just_pressed("pressed_start")
			or Input.is_action_just_pressed("pressed_action")
			or Input.is_action_just_pressed("pressed_triangle")
		):
			if Input.is_action_just_pressed(code_array[current_key]):
				if current_key < code_array.size() - 1:
					current_key += 1
				else:
					unlocked_nmp = true
			else:
				current_key = 0
		
		if Input.is_action_just_pressed("pressed_start") && Global.can_unpause:
			unpause_game()
		
		if Input.is_action_just_pressed("pressed_up") && _selected_option > 0 && allow_input:
			_selected_option -= 1
				
		if (
				Input.is_action_just_pressed("pressed_down")
				and _selected_option < buttons_origin.get_child_count() - 1
				and allow_input
			):
			_selected_option += 1
		
		if Input.is_action_just_pressed("pressed_action"):
			if _selected_option == 0:
				unpause_game()
			elif _selected_option == 1:
				# Options menu
				allow_input = false
				$SelectSound.play()
				# Don't modify fade_overlay for options menu
				main_menu.visible = false
				var options_instance = OPTIONS_MENU.instantiate()
				sub_menu.add_child(options_instance)
				_in_menu = true
			elif _selected_option == 2:
				# Quit menu (last option)
				allow_input = false
				$SelectSound.play()
				buttons_origin.visible = false
				main_menu.visible = false # Hide main menu to prevent overlap
				sub_menu.visible = false # Hide sub menu container as well
				_in_menu = true
				var _menu_instance: Marker2D = QUIT_MENU.instantiate()
				# Position it properly with the new scale
				_menu_instance.position = Vector2(200, 300)
				_menu_instance.z_index = 100 # Very high z-index to ensure visibility
				add_child(_menu_instance)
				print("Quit menu added at position: ", _menu_instance.position)
				print("Quit menu scale: ", _menu_instance.scale)
				print("Quit menu z_index: ", _menu_instance.z_index)
				print("Quit menu children: ")
				for child in _menu_instance.get_children():
					if child is Sprite2D:
						print("  - ", child.name, " at ", child.position)
		
		# Add triangle button functionality for going back
		if Input.is_action_just_pressed("pressed_triangle"):
			if _in_menu:
				# If in submenu, go back to main pause menu
				EventBus.return_to_pause.emit()
			else:
				# If in main pause menu, unpause the game
				unpause_game()
	else:
		# Handle triangle button when in submenus
		if Input.is_action_just_pressed("pressed_triangle"):
			EventBus.return_to_pause.emit()
	for button in buttons_origin.get_children():
		if button.get_index() != _selected_option:
			button.frame_coords.x = 0
			
			if button.position.x > 0:
				button.position.x -= BUTTON_ANIM_SPEED
		else:
			button.frame_coords.x = 1
			if button.position.x < BUTTON_OFFSET:
				button.position.x += BUTTON_ANIM_SPEED


func get_screen() -> Texture2D:
	var viewport_feed: Viewport = get_tree().root.get_viewport()
	var screen_texture: Texture2D = viewport_feed.get_texture()
	var screen_image: Image = screen_texture.get_image()
	var screen: Texture2D = ImageTexture.create_from_image(screen_image)
	
	return screen


func unpause_game() -> void:
	Global.can_unpause = false

	if AudioManager:
		AudioManager.pause_bg_music()
		$NMPUnlock.play()
	
	var grow: Tween = create_tween()

	grow.tween_property(
								screenshot,
								"scale",
								Vector2(
											1.0,
											1.0
										),
								SCREEN_ANIM_TIME
							).set_trans(Tween.TRANS_SINE)
	
	await grow.finished
	
	Global.is_game_paused = false
	Global.can_pause = true
	Global.can_unpause = true
	get_tree().paused = false
	
	EventBus.game_unpaused.emit()
	queue_free()


func _on_return_to_pause() -> void:
	_in_menu = false
	allow_input = true
	main_menu.visible = true
	buttons_origin.visible = true
	sub_menu.visible = true # Make sure sub menu is visible again
	
	# Remove any quit menu instances more thoroughly
	for child in get_children():
		if child.name == "QuitButtons" or child.has_method("get_child_count"):
			if child.get_script() and child.get_script().resource_path.ends_with("quit_buttons.gd"):
				child.queue_free()
	
	# Reset selected option to avoid staying on quit option
	_selected_option = 0
	
	# Disable fade animation when returning from options/quit menu
	# No fade overlay animation since we're returning to pause menu
	if fade_overlay:
		fade_overlay.modulate.a = 0.0


func _on_destruction() -> void:
	Global.is_game_paused = false
	Global.can_pause = true
	Global.can_unpause = false
	EventBus.game_unpaused.emit()
	queue_free()


func leave_sfx() -> void:
	$LeaveSound.play()


func crash_pause_menu() -> void:
	self.set_process_mode(Node.PROCESS_MODE_DISABLED)

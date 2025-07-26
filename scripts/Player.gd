extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var animatedSprite
var state = "idle"
var walkDir = "Down"
var current_direction: int = 2 # 0=Up, 1=Right, 2=Down, 3=Left

# Camera reference - harus sesuai dengan struktur scene
@onready var camera_controller: CameraController = $CameraRig/Camera3D

func _ready():
	animatedSprite = $AnimatedSprite3D
	add_to_group("player") # Add to player group for easy finding
	
	# Setup camera jika ada
	if camera_controller:
		camera_controller.set_focus(self)
		camera_controller.set_mode(CameraController.CameraModes.LERP)

func _physics_process(delta):
	if not is_on_floor():
		pass  # Same as original - no gravity applied

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		state = "walk"
		
		# Update current direction for warp system
		if abs(direction.x) > abs(direction.z):
			if direction.x > 0:
				walkDir = "Right"
				current_direction = 1
			else:
				walkDir = "Left"
				current_direction = 3
		else:
			if direction.z > 0:
				walkDir = "Down"
				current_direction = 2
			else:
				walkDir = "Up"
				current_direction = 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		state = "idle"
	
	animatedSprite.animation = state + walkDir
	animatedSprite.play()
	move_and_slide()

# === CAMERA FUNCTIONS ===

func get_camera_controller() -> CameraController:
	return camera_controller

func setup_camera_for_level(angle: float, distance: Vector2, rotation_y: float = 0.0):
	if camera_controller:
		camera_controller.setup_camera(distance, angle)
		camera_controller.rotate_marker(rotation_y)

func set_camera_mode(mode: CameraController.CameraModes):
	if camera_controller:
		camera_controller.set_mode(mode)

func set_camera_speed(speed: float):
	if camera_controller:
		camera_controller.set_speed(speed)

func transition_camera(angle: float, distance: Vector2, rotation_y: float = 0.0, transition_time: float = 2.0):
	if camera_controller:
		camera_controller.transition_to_new_angle(angle, distance, rotation_y, transition_time)

# Camera presets
func set_camera_preset_topdown():
	if camera_controller:
		camera_controller.set_preset_topdown()

func set_camera_preset_isometric():
	if camera_controller:
		camera_controller.set_preset_isometric()

func set_camera_preset_dramatic():
	if camera_controller:
		camera_controller.set_preset_dramatic()

func shake_camera(intensity: float, duration: float):
	if camera_controller:
		camera_controller.shake_camera(intensity, duration)

# Methods for warp system
func get_current_direction() -> int:
	return current_direction

func set_direction(new_direction: int) -> void:
	current_direction = new_direction
	var directions = ["Up", "Right", "Down", "Left"]
	if new_direction < directions.size():
		walkDir = directions[new_direction]

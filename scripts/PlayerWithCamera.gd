extends CharacterBody3D
class_name PlayerWithCamera

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Built-in camera reference
@onready var camera_controller: CameraController = $CameraRig/Camera3D

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Add to player group untuk mudah ditemukan
	add_to_group("player")
	
	# Setup camera default
	if camera_controller:
		camera_controller.set_focus(self)
		camera_controller.set_mode(CameraController.CameraModes.LERP)
		camera_controller.setup_topdown_2_5d()

func _physics_process(delta):
	# Add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir != Vector2.ZERO:
		velocity.x = input_dir.x * SPEED
		velocity.z = input_dir.y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

# === CAMERA FUNCTIONS ===

# Expose camera controller untuk external access
func get_camera_controller() -> CameraController:
	return camera_controller

# Setup camera untuk level tertentu
func setup_camera_for_level(angle: float, distance: Vector2, rotation_y: float = 0.0):
	if camera_controller:
		camera_controller.setup_camera(distance, angle)
		camera_controller.rotate_marker(rotation_y)
		camera_controller.set_focus(self)

# Set camera mode
func set_camera_mode(mode: CameraController.CameraModes):
	if camera_controller:
		camera_controller.set_mode(mode)

# Set camera speed
func set_camera_speed(speed: float):
	if camera_controller:
		camera_controller.set_speed(speed)

# Transition camera dengan smooth animation
func transition_camera(angle: float, distance: Vector2, rotation_y: float = 0.0, transition_time: float = 2.0):
	if camera_controller:
		camera_controller.transition_to_new_angle(angle, distance, rotation_y, transition_time)

# Camera presets untuk quick access
func set_camera_preset_topdown():
	if camera_controller:
		camera_controller.set_preset_topdown()

func set_camera_preset_isometric():
	if camera_controller:
		camera_controller.set_preset_isometric()

func set_camera_preset_dramatic():
	if camera_controller:
		camera_controller.set_preset_dramatic()

func set_camera_preset_third_person():
	if camera_controller:
		camera_controller.set_preset_third_person()

# Camera shake
func shake_camera(intensity: float, duration: float):
	if camera_controller:
		camera_controller.shake_camera(intensity, duration)

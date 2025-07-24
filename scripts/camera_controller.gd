extends Camera3D
class_name CameraController

@export var target: Node3D
@export var camera_mode: CameraModes = CameraModes.FOLLOW

## Camera modes adapted from Openscop
enum CameraModes {
	COPY,           # Camera copies target position exactly
	FOLLOW,         # Camera follows with distance limits
	POV,            # First person view
	LERP,           # Smooth lerp movement
	PEN_PIANO,      # Special mode (can be customized)
	NO_CODE,        # No movement code
	STATIC_CAMERA,  # Fixed camera position
	FREE            # Free camera movement
}

# Camera settings
@export var follow_speed: float = 5.0
@export var camera_distance: Vector2 = Vector2(5.0, 3.0) # x = horizontal distance, y = height
@export var smoothing: bool = true

# Openscop-style variables
var shake_amount: float = 0.1
var shake_progress: float = 0.0
var shake_transition: float = 0.5
var quake_enabled: float = 0.0
var shake_speed: float = 1.0
var focus_node: Node3D
var marker_rotation: float = 0.0
var camera_rotation: float = 0.0
var limits: Array = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
var distance_limit: Vector3 = Vector3(10, 5, 10)
var can_move: Array = [true, true, true]
var camera_speed: float = 2.0

# Internal variables
var original_position: Vector3
var shake_offset: Vector3

extends Camera3D
class_name CameraController

@export var target: Node3D
@export var camera_mode: CameraModes = CameraModes.FOLLOW

## Camera modes adapted from Openscop
enum CameraModes {
	COPY,           # Camera copies target position exactly
	FOLLOW,         # Camera follows with distance limits
	POV,            # First person view
	LERP,           # Smooth lerp movement
	PEN_PIANO,      # Special mode (can be customized)
	NO_CODE,        # No movement code
	STATIC_CAMERA,  # Fixed camera position
	FREE            # Free camera movement
}

# Camera settings
@export var follow_speed: float = 5.0
@export var camera_distance: Vector2 = Vector2(5.0, 3.0) # x = horizontal distance, y = height
@export var smoothing: bool = true

# Openscop-style variables
var shake_amount: float = 0.1
var shake_progress: float = 0.0
var shake_transition: float = 0.5
var quake_enabled: float = 0.0
var shake_speed: float = 1.0
var focus_node: Node3D
var marker_rotation: float = 0.0
var camera_rotation: float = 0.0
var limits: Array = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
var distance_limit: Vector3 = Vector3(10, 5, 10)
var can_move: Array = [true, true, true]
var camera_speed: float = 2.0

# Internal variables
var original_position: Vector3
var shake_offset: Vector3

func _ready():
	projection = PROJECTION_PERSPECTIVE
	fov = 45.0
	
	if focus_node == null and target != null:
		focus_node = target
	
	if focus_node != null:
		global_position = focus_node.global_position + Vector3(0, camera_distance.y, camera_distance.x)
	
	original_position = position

func _process(delta: float) -> void:
	# Handle camera shake/earthquake
	if quake_enabled > 0.0:
		shake_progress += 100.0 * delta
		shake_offset.y = sin(shake_progress * shake_speed) * shake_amount * quake_enabled
		position = original_position + shake_offset
	else:
		position = original_position
	
	# Handle camera modes
	if focus_node != null:
		match camera_mode:
			CameraModes.COPY:
				_anchor_camera()
				global_position = focus_node.global_position
			
			CameraModes.FOLLOW:
				_follow_mode(delta)
			
			CameraModes.POV:
				_pov_mode()
			
			CameraModes.LERP:
				_lerp_mode(delta)
			
			CameraModes.STATIC_CAMERA:
				_static_mode()
			
			CameraModes.FREE:
				_free_mode()
			
			CameraModes.PEN_PIANO:
				_pen_piano_mode(delta)

func _anchor_camera() -> void:
	# Set camera position relative to marker
	var target_pos = focus_node.global_position
	var camera_offset = Vector3(0.0, camera_distance.y, camera_distance.x)
	global_position = target_pos + camera_offset
	rotation.x = deg_to_rad(camera_rotation)
	# Apply marker rotation around Y axis
	var rotated_offset = camera_offset.rotated(Vector3.UP, deg_to_rad(marker_rotation))
	global_position = target_pos + rotated_offset

func _follow_mode(delta: float) -> void:
	_anchor_camera()
	
	if focus_node == null:
		return
	
	var target_pos = focus_node.global_position
	var desired_position = global_position
	
	# Apply distance limits
	if can_move[0]:
		desired_position.x = clamp(desired_position.x, target_pos.x - distance_limit.x, target_pos.x + distance_limit.x)
	if can_move[1]:
		desired_position.y = clamp(desired_position.y, target_pos.y - distance_limit.y, target_pos.y + distance_limit.y)
	if can_move[2]:
		desired_position.z = clamp(desired_position.z, target_pos.z - distance_limit.z, target_pos.z + distance_limit.z)
	
	# Apply world limits
	if limits[0].x != 0.0 || limits[0].y != 0.0:
		desired_position.x = clamp(desired_position.x, limits[0].x, limits[0].y)
	if limits[1].x != 0.0 || limits[1].y != 0.0:
		desired_position.y = clamp(desired_position.y, limits[1].x, limits[1].y)
	if limits[2].x != 0.0 || limits[2].y != 0.0:
		desired_position.z = clamp(desired_position.z, limits[2].x, limits[2].y)
	
	if smoothing:
		global_position = global_position.lerp(desired_position, follow_speed * delta)
	else:
		global_position = desired_position
	
	# Look at target
	look_at(target_pos + Vector3(0, 1, 0), Vector3.UP)

func _pov_mode() -> void:
	if focus_node == null:
		return
	
	# First person view
	global_rotation.y = focus_node.global_rotation.y + deg_to_rad(180.0)
	
	# Check if target has height property (Entity-like)
	if focus_node.has_method("get_entity_height"):
		global_position = Vector3(
			focus_node.global_position.x,
			focus_node.global_position.y + focus_node.get_entity_height() + 1.0,
			focus_node.global_position.z
		)
	else:
		global_position = focus_node.global_position + Vector3(0, 1.7, 0)

func _lerp_mode(delta: float) -> void:
	_anchor_camera()
	
	if focus_node == null:
		return
	
	# Smooth lerp to target position
	var target_pos = focus_node.global_position + Vector3(0, camera_distance.y, camera_distance.x)
	global_position = global_position.lerp(target_pos, camera_speed * delta)
	look_at(focus_node.global_position + Vector3(0, 1, 0), Vector3.UP)

func _static_mode() -> void:
	# Camera stays in place - no movement
	pass

func _free_mode() -> void:
	var move_speed = 0.1
	var rotation_speed = 0.05
	
	if Input.is_action_pressed("shift"):
		# Rotation mode
		if Input.is_action_pressed("ui_up"):
			rotation.x -= rotation_speed
		if Input.is_action_pressed("ui_down"):
			rotation.x += rotation_speed
		if Input.is_action_pressed("ui_left"):
			rotation.y += rotation_speed
		if Input.is_action_pressed("ui_right"):
			rotation.y -= rotation_speed
	else:
		# Movement mode
		if Input.is_action_pressed("ui_up"):
			global_position.z -= move_speed
		if Input.is_action_pressed("ui_down"):
			global_position.z += move_speed
		if Input.is_action_pressed("ui_left"):
			global_position.x -= move_speed
		if Input.is_action_pressed("ui_right"):
			global_position.x += move_speed
		if Input.is_action_pressed("ui_page_up"):
			global_position.y += move_speed
		if Input.is_action_pressed("ui_page_down"):
			global_position.y -= move_speed

func _pen_piano_mode(delta: float) -> void:
	# Special mode - customize as needed
	# For now, similar to follow but with special behavior
	_follow_mode(delta)
	
	# Add special pen piano behavior here
	# Example: smoother movement, special angles, etc.

# Openscop-style functions
func set_focus(node: Node3D) -> void:
	focus_node = node
	target = node

func set_mode(mode: CameraModes) -> void:
	camera_mode = mode

func get_mode() -> int:
	return camera_mode

func rotate_marker(rotation_y: float = 0.0) -> void:
	marker_rotation = rotation_y

func setup_camera(distance: Vector2, rotation_x: float) -> void:
	camera_distance = distance
	camera_rotation = rotation_x
	_anchor_camera()

func set_distance(limit: Vector3) -> void:
	distance_limit = limit

func set_limit(axis: int, limit: Vector2) -> void:
	if axis >= 0 and axis < limits.size():
		limits[axis] = limit

func set_movement(axis: int, value: bool) -> void:
	if axis >= 0 and axis < can_move.size():
		can_move[axis] = value

func set_speed(value: float) -> void:
	camera_speed = value

# Earthquake/shake functions
func do_earthquake(enable: bool) -> void:
	if enable:
		if quake_enabled == 0.0:
			var tween = create_tween()
			tween.tween_property(self, "quake_enabled", 1.0, shake_transition)
	else:
		var tween = create_tween()
		tween.tween_property(self, "quake_enabled", 0.0, shake_transition)

func set_shake_amount(value: float) -> void:
	shake_amount = value

func set_shake_speed(value: float) -> void:
	shake_speed = value

func set_earthquake_transition_speed(value: float) -> void:
	shake_transition = value

func stop_earthquake_abruptly() -> void:
	quake_enabled = 0.0

# Additional utility functions
func shake_camera(intensity: float, duration: float) -> void:
	set_shake_amount(intensity)
	do_earthquake(true)
	
	await get_tree().create_timer(duration).timeout
	do_earthquake(false)

func set_camera_angle(angle_x: float, distance: float = -1, height: float = -1) -> void:
	camera_rotation = angle_x
	if distance > 0:
		camera_distance.x = distance
	if height > 0:
		camera_distance.y = height
	_anchor_camera()

func transition_to_mode(new_mode: CameraModes, transition_time: float = 1.0) -> void:
	var old_position = global_position
	set_mode(new_mode)
	
	# Smooth transition to new camera position
	var tween = create_tween()
	tween.tween_property(self, "global_position", global_position, transition_time)
	
	# Handle camera modes
	if focus_node != null:
		match camera_mode:
			CameraModes.COPY:
				_anchor_camera()
				global_position = focus_node.global_position
			
			CameraModes.FOLLOW:
				_follow_mode(delta)
			
			CameraModes.POV:
				_pov_mode()
			
			CameraModes.LERP:
				_lerp_mode(delta)
			
			CameraModes.STATIC_CAMERA:
				_static_mode()
			
			CameraModes.FREE:
				_free_mode()
			
			CameraModes.PEN_PIANO:
				_pen_piano_mode(delta)

func _anchor_camera() -> void:
	# Set camera position relative to marker
	var target_pos = focus_node.global_position
	var camera_offset = Vector3(0.0, camera_distance.y, camera_distance.x)
	global_position = target_pos + camera_offset
	rotation.x = deg_to_rad(camera_rotation)
	# Apply marker rotation around Y axis
	var rotated_offset = camera_offset.rotated(Vector3.UP, deg_to_rad(marker_rotation))
	global_position = target_pos + rotated_offset

func _follow_mode(delta: float) -> void:
	_anchor_camera()
	
	if focus_node == null:
		return
	
	var target_pos = focus_node.global_position
	var desired_position = global_position
	
	# Apply distance limits
	if can_move[0]:
		desired_position.x = clamp(desired_position.x, target_pos.x - distance_limit.x, target_pos.x + distance_limit.x)
	if can_move[1]:
		desired_position.y = clamp(desired_position.y, target_pos.y - distance_limit.y, target_pos.y + distance_limit.y)
	if can_move[2]:
		desired_position.z = clamp(desired_position.z, target_pos.z - distance_limit.z, target_pos.z + distance_limit.z)
	
	# Apply world limits
	if limits[0].x != 0.0 || limits[0].y != 0.0:
		desired_position.x = clamp(desired_position.x, limits[0].x, limits[0].y)
	if limits[1].x != 0.0 || limits[1].y != 0.0:
		desired_position.y = clamp(desired_position.y, limits[1].x, limits[1].y)
	if limits[2].x != 0.0 || limits[2].y != 0.0:
		desired_position.z = clamp(desired_position.z, limits[2].x, limits[2].y)
	
	if smoothing:
		global_position = global_position.lerp(desired_position, follow_speed * delta)
	else:
		global_position = desired_position
	
	# Look at target
	look_at(target_pos + Vector3(0, 1, 0), Vector3.UP)

func _pov_mode() -> void:
	if focus_node == null:
		return
	
	# First person view
	global_rotation.y = focus_node.global_rotation.y + deg_to_rad(180.0)
	
	# Check if target has height property (Entity-like)
	if focus_node.has_method("get_entity_height"):
		global_position = Vector3(
			focus_node.global_position.x,
			focus_node.global_position.y + focus_node.get_entity_height() + 1.0,
			focus_node.global_position.z
		)
	else:
		global_position = focus_node.global_position + Vector3(0, 1.7, 0)

func _lerp_mode(delta: float) -> void:
	_anchor_camera()
	
	if focus_node == null:
		return
	
	# Smooth lerp to target position
	var target_pos = focus_node.global_position + Vector3(0, camera_distance.y, camera_distance.x)
	global_position = global_position.lerp(target_pos, camera_speed * delta)
	look_at(focus_node.global_position + Vector3(0, 1, 0), Vector3.UP)

func _static_mode() -> void:
	# Camera stays in place - no movement
	pass

func _free_mode() -> void:
	var move_speed = 0.1
	var rotation_speed = 0.05
	
	if Input.is_action_pressed("shift"):
		# Rotation mode
		if Input.is_action_pressed("ui_up"):
			rotation.x -= rotation_speed
		if Input.is_action_pressed("ui_down"):
			rotation.x += rotation_speed
		if Input.is_action_pressed("ui_left"):
			rotation.y += rotation_speed
		if Input.is_action_pressed("ui_right"):
			rotation.y -= rotation_speed
	else:
		# Movement mode
		if Input.is_action_pressed("ui_up"):
			global_position.z -= move_speed
		if Input.is_action_pressed("ui_down"):
			global_position.z += move_speed
		if Input.is_action_pressed("ui_left"):
			global_position.x -= move_speed
		if Input.is_action_pressed("ui_right"):
			global_position.x += move_speed
		if Input.is_action_pressed("ui_page_up"):
			global_position.y += move_speed
		if Input.is_action_pressed("ui_page_down"):
			global_position.y -= move_speed

func _pen_piano_mode(delta: float) -> void:
	# Special mode - customize as needed
	# For now, similar to follow but with special behavior
	_follow_mode(delta)
	
	# Add special pen piano behavior here
	# Example: smoother movement, special angles, etc.

# Openscop-style functions
func set_focus(node: Node3D) -> void:
	focus_node = node
	target = node

func set_mode(mode: CameraModes) -> void:
	camera_mode = mode

func get_mode() -> int:
	return camera_mode

func rotate_marker(rotation_y: float = 0.0) -> void:
	marker_rotation = rotation_y

func setup_camera(distance: Vector2, rotation_x: float) -> void:
	camera_distance = distance
	camera_rotation = rotation_x
	_anchor_camera()

func set_distance(limit: Vector3) -> void:
	distance_limit = limit

func set_limit(axis: int, limit: Vector2) -> void:
	if axis >= 0 and axis < limits.size():
		limits[axis] = limit

func set_movement(axis: int, value: bool) -> void:
	if axis >= 0 and axis < can_move.size():
		can_move[axis] = value

func set_speed(value: float) -> void:
	camera_speed = value

# Earthquake/shake functions
func do_earthquake(enable: bool) -> void:
	if enable:
		if quake_enabled == 0.0:
			var tween = create_tween()
			tween.tween_property(self, "quake_enabled", 1.0, shake_transition)
	else:
		var tween = create_tween()
		tween.tween_property(self, "quake_enabled", 0.0, shake_transition)

func set_shake_amount(value: float) -> void:
	shake_amount = value

func set_shake_speed(value: float) -> void:
	shake_speed = value

func set_earthquake_transition_speed(value: float) -> void:
	shake_transition = value

func stop_earthquake_abruptly() -> void:
	quake_enabled = 0.0

# Additional utility functions
func shake_camera(intensity: float, duration: float) -> void:
	set_shake_amount(intensity)
	do_earthquake(true)
	
	await get_tree().create_timer(duration).timeout
	do_earthquake(false)

func set_camera_angle(angle_x: float, distance: float = -1, height: float = -1) -> void:
	camera_rotation = angle_x
	if distance > 0:
		camera_distance.x = distance
	if height > 0:
		camera_distance.y = height
	_anchor_camera()

func transition_to_mode(new_mode: CameraModes, transition_time: float = 1.0) -> void:
	var old_position = global_position
	set_mode(new_mode)
	
	# Smooth transition to new camera position
	var tween = create_tween()
	tween.tween_property(self, "global_position", global_position, transition_time)

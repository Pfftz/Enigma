extends Camera3D
class_name CameraController

@export var target: Node3D
@export var camera_mode: CameraModes = CameraModes.LERP

## Camera modes
enum CameraModes {
    FOLLOW,
    POV,
    LERP,
    STATIC,
    FREE
}

# Camera settings
@export var follow_speed: float = 5.0
@export var camera_distance: Vector2 = Vector2(8.0, 6.0) # x = horizontal distance, y = height
@export var smoothing: bool = true

# Camera variables
var focus_node: Node3D
var marker_rotation: float = 0.0
var camera_rotation: float = -45.0
var camera_speed: float = 3.0

func _ready():
    # Setup untuk topdown 2.5D
    projection = PROJECTION_PERSPECTIVE
    fov = 45.0
    
    # Set sudut default
    camera_rotation = -45.0
    marker_rotation = 0.0
    camera_distance = Vector2(8.0, 6.0)
    
    if focus_node == null and target != null:
        focus_node = target
    
    if focus_node != null:
        _anchor_camera()

func _process(delta: float) -> void:
    if focus_node == null:
        return
        
    match camera_mode:
        CameraModes.FOLLOW:
            _follow_mode(delta)
        CameraModes.POV:
            _pov_mode()
        CameraModes.LERP:
            _lerp_mode(delta)
        CameraModes.STATIC:
            _static_mode()
        CameraModes.FREE:
            _free_mode()

func _anchor_camera() -> void:
    if focus_node == null:
        return
        
    var target_pos = focus_node.global_position
    
    # Calculate camera offset
    var offset = Vector3(0, camera_distance.y, camera_distance.x)
    
    # Apply rotation around Y axis
    var rotation_y = deg_to_rad(marker_rotation)
    offset = offset.rotated(Vector3.UP, rotation_y)
    
    # Set position
    global_position = target_pos + offset
    
    # Look at target
    var look_target = target_pos + Vector3(0, 1, 0)
    look_at(look_target, Vector3.UP)
    
    # Apply camera rotation
    rotation.x = deg_to_rad(camera_rotation)

func _follow_mode(delta: float) -> void:
    _anchor_camera()

func _pov_mode() -> void:
    if focus_node:
        global_position = focus_node.global_position + Vector3(0, 1.7, 0)
        global_rotation = focus_node.global_rotation

func _lerp_mode(delta: float) -> void:
    if focus_node == null:
        return
        
    var target_pos = focus_node.global_position
    var offset = Vector3(0, camera_distance.y, camera_distance.x)
    var rotation_y = deg_to_rad(marker_rotation)
    offset = offset.rotated(Vector3.UP, rotation_y)
    
    var desired_position = target_pos + offset
    global_position = global_position.lerp(desired_position, camera_speed * delta)
    
    # Smooth look at
    var look_target = target_pos + Vector3(0, 1, 0)
    var current_transform = global_transform
    var target_transform = current_transform.looking_at(look_target, Vector3.UP)
    global_transform = current_transform.interpolate_with(target_transform, camera_speed * delta)
    
    # Apply camera rotation
    rotation.x = deg_to_rad(camera_rotation)

func _static_mode() -> void:
    # Camera doesn't move
    pass

func _free_mode() -> void:
    # Free camera mode - can be implemented later
    pass

# === PUBLIC FUNCTIONS ===

func set_focus(node: Node3D) -> void:
    focus_node = node
    target = node

func set_mode(mode: CameraModes) -> void:
    camera_mode = mode

func rotate_marker(rotation_y: float = 0.0) -> void:
    marker_rotation = rotation_y

func setup_camera(distance: Vector2, rotation_x: float) -> void:
    camera_distance = distance
    camera_rotation = rotation_x

func set_speed(value: float) -> void:
    camera_speed = value

# === TRANSITION FUNCTIONS ===

func transition_to_new_angle(new_angle: float, new_distance: Vector2, new_rotation: float = 0.0, transition_time: float = 1.0):
    var tween = create_tween()
    tween.set_parallel(true)
    
    tween.tween_method(_tween_camera_rotation, camera_rotation, new_angle, transition_time)
    tween.tween_method(_tween_camera_distance, camera_distance, new_distance, transition_time)
    tween.tween_method(_tween_marker_rotation, marker_rotation, new_rotation, transition_time)

func _tween_camera_rotation(value: float):
    camera_rotation = value

func _tween_camera_distance(value: Vector2):
    camera_distance = value

func _tween_marker_rotation(value: float):
    marker_rotation = value

# === CAMERA SHAKE ===

func shake_camera(intensity: float, duration: float):
    var original_pos = global_position
    var tween = create_tween()
    
    var shake_time = 0.0
    var shake_duration = duration
    
    while shake_time < shake_duration:
        var shake_offset = Vector3(
            randf_range(-intensity, intensity),
            randf_range(-intensity, intensity),
            randf_range(-intensity, intensity)
        )
        tween.tween_property(self, "global_position", original_pos + shake_offset, 0.05)
        await tween.finished
        
        tween = create_tween()
        shake_time += 0.05
    
    # Return to original position
    tween.tween_property(self, "global_position", original_pos, 0.1)

# === CAMERA PRESETS ===

func set_preset_topdown():
    setup_camera(Vector2(0, 10), -90)
    rotate_marker(0)

func set_preset_isometric():
    setup_camera(Vector2(8, 6), -35)
    rotate_marker(45)

func set_preset_third_person():
    setup_camera(Vector2(5, 3), -20)
    rotate_marker(0)

func set_preset_dramatic():
    setup_camera(Vector2(12, 8), -60)
    rotate_marker(30)

extends Camera3D
class_name CameraController

@export var target: Node3D
@export var follow_speed: float = 5.0
@export var camera_distance: float = 10.0
@export var camera_height: float = 8.0
@export var look_ahead_distance: float = 2.0
@export var smoothing: bool = true

var offset: Vector3
var velocity: Vector3

func _ready():
    if target == null:
        target = get_parent()
    
    # Set camera untuk topdown 2.5D view
    setup_topdown_camera()

func setup_topdown_camera():
    # Posisi kamera di atas dan sedikit ke belakang
    position = Vector3(0, camera_height, camera_distance)
    
    # Rotasi untuk sudut topdown 2.5D (sekitar 45-60 derajat)
    rotation_degrees = Vector3(-45, 0, 0)
    
    # Set projection ke perspective untuk efek 2.5D
    projection = PROJECTION_PERSPECTIVE
    fov = 45.0

func _process(delta):
    if target == null:
        return
    
    follow_target(delta)

func follow_target(delta):
    var target_position = target.global_position
    
    # Hitung posisi kamera yang diinginkan
    var desired_position = target_position + Vector3(0, camera_height, camera_distance)
    
    if smoothing:
        # Smooth camera movement
        global_position = global_position.lerp(desired_position, follow_speed * delta)
    else:
        global_position = desired_position
    
    # Selalu lihat ke target dengan offset sedikit
    var look_target = target_position + Vector3(0, 1, 0)
    look_at(look_target, Vector3.UP)

# Fungsi untuk mengubah sudut kamera secara dinamis
func set_camera_angle(angle_x: float, distance: float = -1, height: float = -1):
    if distance > 0:
        camera_distance = distance
    if height > 0:
        camera_height = height
    
    rotation_degrees.x = -angle_x
    setup_topdown_camera()

# Fungsi untuk camera shake effect
func shake_camera(intensity: float, duration: float):
    var tween = create_tween()
    var original_position = position
    
    for i in range(int(duration * 60)): # 60 FPS
        var shake_offset = Vector3(
            randf_range(-intensity, intensity),
            randf_range(-intensity, intensity),
            randf_range(-intensity, intensity)
        )
        tween.tween_method(_apply_shake, shake_offset, Vector3.ZERO, 0.016)
    
    tween.tween_callback(func(): position = original_position)

func _apply_shake(shake_offset: Vector3):
    position += shake_offset
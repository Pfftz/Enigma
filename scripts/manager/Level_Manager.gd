extends Node3D
class_name LevelManager

@export var player: Player
@export var level_bounds: AABB
@export var camera_angle: float = -45.0
@export var camera_distance: Vector2 = Vector2(8.0, 6.0)
@export var camera_rotation_y: float = 0.0

func _ready():
    add_to_group("level_manager")
    
    # Auto-detect player if not set
    if player == null:
        player = get_node("Player") as Player
        if player == null:
            player = get_tree().get_first_node_in_group("player") as Player
    
    setup_level_camera()

func setup_level_camera():
    if player and player.has_method("get_camera_controller"):
        var camera_controller = player.get_camera_controller()
        if camera_controller:
            # Set focus ke player
            camera_controller.set_focus(player)
            
            # Setup camera untuk level ini
            camera_controller.setup_camera(camera_distance, camera_angle)
            camera_controller.rotate_marker(camera_rotation_y)
            
            # Set mode ke LERP untuk smooth movement
            camera_controller.set_mode(CameraController.CameraModes.LERP)
            camera_controller.set_speed(3.0)

# Fungsi untuk mengubah sudut kamera secara dinamis per area
func set_camera_for_area(angle: float, distance: Vector2, rotation_y: float = 0.0):
    if player and player.has_method("get_camera_controller"):
        var camera_controller = player.get_camera_controller()
        if camera_controller:
            camera_controller.transition_to_new_angle(angle, distance, rotation_y, 2.0)

# Input untuk testing camera modes (hanya di debug mode)
func _input(event):
    if OS.is_debug_build() and player and player.has_method("get_camera_controller"):
        var camera_controller = player.get_camera_controller()
        if camera_controller:
            if event.is_action_pressed("ui_accept"):  # Enter key
                camera_controller.set_preset_topdown()
            elif event.is_action_pressed("ui_cancel"):  # Escape key
                camera_controller.set_preset_isometric()
            elif event.is_action_pressed("ui_select"):  # Space key
                camera_controller.set_preset_dramatic()

# Fungsi untuk area triggers
func on_area_entered(area_name: String):
    match area_name:
        "narrow_corridor":
            set_camera_for_area(-70, Vector2(4, 3), 0)
        "open_area":
            set_camera_for_area(-35, Vector2(10, 8), 45)
        "boss_arena":
            set_camera_for_area(-30, Vector2(15, 10), 0)
            if player:
                player.set_camera_speed(1.5)  # Slower untuk dramatic effect
        "default":
            set_camera_for_area(camera_angle, camera_distance, camera_rotation_y)

# Helper functions untuk akses mudah
func get_camera_controller() -> CameraController:
    if player and player.has_method("get_camera_controller"):
        return player.get_camera_controller()
    return null

func shake_camera(intensity: float, duration: float):
    if player:
        player.shake_camera(intensity, duration)
extends Area3D
class_name CameraAreaTrigger

@export var area_name: String = "default"
@export var new_camera_angle: float = -45.0
@export var new_camera_distance: Vector2 = Vector2(8.0, 6.0)
@export var new_camera_rotation: float = 0.0
@export var transition_speed: float = 2.0
@export var revert_on_exit: bool = true

var level_manager: LevelManager
var player: Node3D

func _ready():
    # Connect signals
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    
    # Find level manager
    level_manager = get_tree().get_first_node_in_group("level_manager")
    if level_manager == null:
        level_manager = get_node("../../") as LevelManager

func _on_body_entered(body):
    if body.has_method("get_camera_controller"):  # Check if it's a player with camera
        player = body
        var camera_controller = body.get_camera_controller()
        
        if camera_controller:
            camera_controller.transition_to_new_angle(
                new_camera_angle, 
                new_camera_distance, 
                new_camera_rotation, 
                transition_speed
            )
        
        # Also call level manager's area handler
        if level_manager:
            level_manager.on_area_entered(area_name)
        
        # Optional: Print debug info
        if OS.is_debug_build():
            print("Camera Area Triggered: ", area_name)
            print("New Angle: ", new_camera_angle)
            print("New Distance: ", new_camera_distance)

func _on_body_exited(body):
    if body.has_method("get_camera_controller") and revert_on_exit:
        player = body
        var camera_controller = body.get_camera_controller()
        
        # Revert to level default settings
        if level_manager and camera_controller:
            camera_controller.transition_to_new_angle(
                level_manager.camera_angle,
                level_manager.camera_distance,
                level_manager.camera_rotation_y,
                transition_speed
            )
            level_manager.on_area_entered("default")

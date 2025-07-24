extends LevelManager
class_name Level1Manager

# Level 1 - Indoor maze, gunakan angle yang tight
func _ready():
    # Setup khusus untuk Level 1
    camera_angle = -60.0
    camera_distance = Vector2(6.0, 4.0)
    camera_rotation_y = 0.0
    
    # Panggil parent _ready()
    super._ready()

# Override area triggers untuk level ini
func on_area_entered(area_name: String):
    match area_name:
        "entrance":
            set_camera_for_area(-45, Vector2(8, 6), 0)
            print("Entering level - camera adjusted")
        "maze_narrow":
            set_camera_for_area(-70, Vector2(4, 3), 0)
            print("Narrow corridor - tight camera")
        "maze_center":
            set_camera_for_area(-35, Vector2(10, 8), 45)
            print("Open area - isometric view")
        "boss_room":
            set_camera_for_area(-30, Vector2(15, 10), 0)
            if player:
                player.set_camera_speed(1.5)  # Slower untuk dramatic effect
            print("Boss room - dramatic camera")
        "exit":
            set_camera_for_area(-20, Vector2(12, 8), 0)
            print("Exit area - reveal view")
        _:
            super.on_area_entered(area_name)  # Fallback ke parent

# Events khusus untuk level ini
func _on_door_opened():
    set_camera_for_area(-45, Vector2(8, 6), 0)
    shake_camera(0.2, 0.5)

func _on_puzzle_solved():
    shake_camera(0.5, 1.0)  # Camera shake effect
    # Zoom out untuk reveal
    set_camera_for_area(-30, Vector2(12, 8), 0)

func _on_enemy_defeated():
    shake_camera(0.3, 0.8)

# Input khusus untuk level (testing)
func _input(event):
    super._input(event)  # Call parent input first
    
    if OS.is_debug_build():
        if event.is_action_pressed("ui_page_up"):
            _on_puzzle_solved()  # Test puzzle camera
        elif event.is_action_pressed("ui_page_down"):
            _on_door_opened()  # Test door camera

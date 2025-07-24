# Camera System Setup Guide

## Struktur File yang Diperlukan:

### Core Scripts:
- `scripts/Player.gd` - Player controller dengan built-in camera support
- `scripts/manager/camera_controller.gd` - Camera controller yang clean
- `scripts/manager/Level_Manager.gd` - Base level manager
- `scripts/manager/CameraAreaTrigger.gd` - Area trigger untuk camera changes
- `scripts/levels/Level1Manager.gd` - Level specific manager

## Setup Scene Structure:

### Player.tscn:
```
Player (CharacterBody3D) - attach Player.gd
├── AnimatedSprite3D
├── CollisionShape3D
└── CameraRig (Node3D)
    └── Camera3D - attach camera_controller.gd
```

### Level1.tscn:
```
Level1 (Node3D) - attach Level1Manager.gd
├── Environment (Node3D)
│   ├── Floor
│   └── Walls
├── Player (Instance Player.tscn)
├── CameraTriggers (Node3D)
│   ├── EntranceArea (Area3D) - attach CameraAreaTrigger.gd
│   ├── MazeArea (Area3D) - attach CameraAreaTrigger.gd
│   └── BossArea (Area3D) - attach CameraAreaTrigger.gd
└── UI (CanvasLayer)
```

## Setup Steps:

1. **Buat Player.tscn:**
   - Root: CharacterBody3D dengan script Player.gd
   - Add CameraRig (Node3D) sebagai child
   - Add Camera3D ke CameraRig dengan script camera_controller.gd

2. **Buat Level Scene:**
   - Root: Node3D dengan script Level1Manager.gd
   - Instance Player.tscn

3. **Setup di Inspector:**
   - Set Player reference di Level1Manager
   - Set camera_angle, camera_distance, camera_rotation_y

4. **Setup Camera Triggers:**
   - Buat Area3D dengan CameraAreaTrigger.gd
   - Set area_name, new_camera_angle, new_camera_distance, dll
   - Add CollisionShape3D

## Testing Controls (Debug Mode):

- **Enter**: Topdown preset
- **Escape**: Isometric preset
- **Space**: Dramatic preset
- **Page Up**: Test puzzle effect
- **Page Down**: Test door effect

## Camera Presets Available:

- **Topdown**: -90°, distance (0, 10)
- **Isometric**: -35°, distance (8, 6), rotation 45°
- **Third Person**: -20°, distance (5, 3)
- **Dramatic**: -60°, distance (12, 8), rotation 30°

## Area Trigger Examples:

- **entrance**: -45°, (8, 6), 0°
- **maze_narrow**: -70°, (4, 3), 0°
- **maze_center**: -35°, (10, 8), 45°
- **boss_room**: -30°, (15, 10), 0°

Sistem sudah clean dan ready untuk digunakan!

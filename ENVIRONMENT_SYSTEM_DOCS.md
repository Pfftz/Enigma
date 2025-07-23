# **Enigma - Environmental Effects System Documentation**

## **🌫️ FOG SYSTEM**

### **How It Works**

The fog system uses global shader parameters to create atmospheric depth. Fog follows the player and affects all materials using PSX shaders.

### **Key Files**

-   `scripts/EnvironmentResource.gd` - Configuration data
-   `scripts/LevelEnvironmentManager.gd` - System manager
-   `shaders/psx_base.gdshader` - Fog rendering logic

### **Configuration Options**

```gdscript
# In your environment resource:
enable_fog = true                 # Enable fog
fog_color = Color(0.8, 0.8, 0.9)  # Color of the fog
fog_radius = 15.0                 # Distance for full opacity
fog_follow_player = true          # Follow player movement
```

### **Runtime Control**

```gdscript
# Get environment manager reference
var env_manager = get_node("LevelEnvironmentManager")

# Change fog properties at runtime
env_manager.set_fog_enabled(true)
env_manager.set_fog_color(Color.BLUE)
env_manager.set_fog_radius(20.0)
```

---

## **🌌 MOVING BACKGROUNDS**

### **How It Works**

Animated sky backgrounds use a custom sky shader that scrolls textures based on global time.

### **Key Files**

-   `shaders/sky_animated.gdshader` - Sky animation shader
-   `scripts/LevelEnvironmentManager.gd` - Background setup

### **Configuration Options**

```gdscript
# Texture-based animated background
sky_texture = preload("res://textures/sky_clouds.png")
scroll_speed = 0.3                # Horizontal scroll speed
offset_y = 0.1                    # Vertical offset

# Solid color background (fallback)
sky_color = Color(0.5, 0.7, 1.0)  # Sky color when no texture
```

### **Supported Features**

-   **Horizontal scrolling** - Clouds moving across the sky
-   **Vertical offset** - Adjust sky position
-   **PSX-accurate** - Respects 320x240 resolution
-   **Seamless looping** - Textures repeat smoothly

---

## **💡 LIGHTING SYSTEM**

### **How It Works**

Environmental lighting combines ambient lighting with optional directional lights for realistic illumination.

### **Configuration Options**

```gdscript
# Ambient lighting
ambient_color = Color(1.0, 1.0, 1.0)  # Color of ambient light
environment_darkness = 0.8            # Brightness (0.0-1.0)

# Directional lighting (optional)
enable_directional_light = true
light_direction = Vector3(-0.5, -1.0, -0.5)
light_color = Color(1.0, 0.9, 0.7)
light_energy = 1.2
```

### **Lighting Presets**

-   **Dark/Moody**: Low environment_darkness (0.3-0.6)
-   **Normal**: Standard brightness (0.8-1.0)
-   **Bright/Outdoor**: High energy with directional light

---

## **🎮 IMPLEMENTATION GUIDE**

### **Step 1: Add to Your Scene**

```gdscript
# Add LevelEnvironmentManager to your level scene
1. Add Node3D to your scene
2. Attach LevelEnvironmentManager.gd script
3. Assign an EnvironmentResource in the inspector
4. Set fog_follow_target to your player node
```

### **Step 2: Create Environment Presets**

```gdscript
# Create .tres files in resource/environment/
1. Right-click in FileSystem
2. New Resource > EnvironmentResource
3. Configure the settings
4. Save as .tres file
```

### **Step 3: Apply PSX Materials**

```gdscript
# Ensure your 3D objects use PSX shaders for fog support
# Materials should inherit from:
- psx_base.gdshader
- psx_lit.gdshader
- psx_unlit.gdshader
```

---

## **📝 CONFIGURATION REFERENCE**

### **EnvironmentResource Properties**

#### **Sky & Background**

| Property       | Type      | Description             | Example                |
| -------------- | --------- | ----------------------- | ---------------------- |
| `sky_color`    | Color     | Solid sky color         | `Color(0.5, 0.7, 1.0)` |
| `sky_texture`  | Texture2D | Animated sky texture    | `preload("sky.png")`   |
| `scroll_speed` | float     | Scroll animation speed  | `0.3`                  |
| `offset_y`     | float     | Vertical texture offset | `0.1`                  |

#### **Ambient Lighting**

| Property               | Type  | Description         | Example       |
| ---------------------- | ----- | ------------------- | ------------- |
| `ambient_color`        | Color | Ambient light color | `Color.WHITE` |
| `environment_darkness` | float | Overall brightness  | `0.8`         |

#### **Fog System**

| Property            | Type  | Description   | Example                |
| ------------------- | ----- | ------------- | ---------------------- |
| `enable_fog`        | bool  | Enable fog    | `true`                 |
| `fog_color`         | Color | Fog color     | `Color(0.8, 0.8, 0.9)` |
| `fog_radius`        | float | Fog distance  | `15.0`                 |
| `fog_follow_player` | bool  | Follow player | `true`                 |

#### **Directional Lighting**

| Property                   | Type    | Description        | Example                   |
| -------------------------- | ------- | ------------------ | ------------------------- |
| `enable_directional_light` | bool    | Add sun/moon light | `false`                   |
| `light_direction`          | Vector3 | Light direction    | `Vector3(-0.5, -1, -0.5)` |
| `light_color`              | Color   | Light color        | `Color(1, 0.95, 0.8)`     |
| `light_energy`             | float   | Light strength     | `1.0`                     |

---

## **🎨 ARTISTIC GUIDELINES**

### **Fog Colors**

-   **Blue/Cold**: `Color(0.6, 0.7, 0.9)` - Outdoor, mysterious
-   **Gray/Neutral**: `Color(0.8, 0.8, 0.8)` - Indoor, clinical
-   **Warm/Orange**: `Color(0.9, 0.8, 0.6)` - Sunset, cozy
-   **Green/Sickly**: `Color(0.7, 0.9, 0.7)` - Toxic, unnatural

### **Background Scroll Speeds**

-   **Slow (0.1-0.3)**: Distant clouds, subtle movement
-   **Medium (0.3-0.6)**: Active weather, windy scenes
-   **Fast (0.6-1.0)**: Storm effects, dramatic scenes

### **Lighting Combinations**

```gdscript
# Mysterious Cave
ambient_color = Color(0.3, 0.4, 0.6)
environment_darkness = 0.4
enable_fog = true
fog_color = Color(0.5, 0.5, 0.7)

# Sunny Outdoor
ambient_color = Color(1.0, 0.95, 0.8)
environment_darkness = 1.0
enable_directional_light = true
light_energy = 1.5

# Eerie Nightmare
ambient_color = Color(0.8, 0.6, 0.6)
environment_darkness = 0.3
enable_fog = true
fog_color = Color(0.7, 0.5, 0.5)
```

---

## **🔧 TROUBLESHOOTING**

### **Fog Not Visible**

1. Check that materials use PSX shaders
2. Verify `fog_enabled` is true in shader parameters
3. Ensure fog_radius is appropriate for scene scale
4. Check that LevelEnvironmentManager is in scene

### **Background Not Moving**

1. Verify sky_texture is assigned
2. Check scroll_speed is not zero
3. Ensure Global.clock_float exists or time is updating
4. Confirm sky shader is loaded correctly

### **Lighting Too Dark/Bright**

1. Adjust environment_darkness value
2. Check ambient_color brightness
3. Verify directional light energy if enabled
4. Test with different environment presets

### **Performance Issues**

1. Use smaller sky textures (max 512x512)
2. Reduce fog_radius for distant objects
3. Disable directional lighting if not needed
4. Use fewer environment updates per frame

---

## **📁 EXAMPLE ENVIRONMENT PRESETS**

The system includes several preset configurations:

-   **`dark_foggy.tres`** - Dark, mysterious atmosphere with fog
-   **`bright_clear.tres`** - Bright, clear outdoor environment

Create custom presets by copying and modifying these examples!

---

## **🚀 ADVANCED USAGE**

### **Dynamic Environment Changes**

```gdscript
# Gradually change fog over time
func transition_to_night():
    var tween = create_tween()
    var env_manager = get_node("LevelEnvironmentManager")

    # Fade fog to darker blue
    tween.tween_method(
        env_manager.set_fog_color,
        Color(0.8, 0.8, 0.9),  # Start color
        Color(0.3, 0.3, 0.6),  # End color
        2.0                     # Duration
    )
```

### **Multiple Environment Zones**

```gdscript
# Different environments in different areas
func _on_area_entered(area):
    match area.name:
        "ForestZone":
            apply_environment("res://resource/environment/forest.tres")
        "CaveZone":
            apply_environment("res://resource/environment/cave.tres")
```

This comprehensive system gives you full control over atmospheric effects in your Enigma project, matching the quality and style of the Openscop implementation!

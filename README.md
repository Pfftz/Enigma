# Enigma

A second game from Gedagedi Game Studio for Gameseed

## Overview

Enigma is a 3D adventure game developed in Godot 4.4 with a retro PSX-style aesthetic. The game features atmospheric exploration, interactive dialogue systems, and immersive post-processing effects that create a nostalgic gaming experience.

## Features

- **Retro PSX-Style Graphics**: Custom shaders that recreate the classic PlayStation 1 visual style
- **Interactive Dialogue System**: Rich textbox system with audio feedback
- **Atmospheric Audio**: Carefully crafted soundscape with multiple music tracks
- **Post-Processing Effects**: LCD overlay, blur, and dithering effects for authentic retro feel
- **3D Exploration**: First-person character controller with interaction system

## System Requirements

- **Engine**: Godot 4.4+
- **Platform**: Windows/Linux/macOS
- **Rendering**: Forward Plus renderer
- **Resolution**: 320x240 (scaled up)

## Project Structure

```
Enigma/
├── scenes/           # Game scenes and player controller
├── scripts/          # GDScript files for game logic
├── shaders/          # Custom PSX-style shaders
├── post_process/     # Post-processing materials and effects
├── resource/         # Game resources (textures, models, etc.)
├── music/           # Background music and audio tracks
├── sounds/          # Sound effects
├── sprites/         # 2D sprites and textures
├── world/           # World geometry and environments
└── asset/           # Additional game assets
```

## Key Components

### Scripts
- `global.gd` - Global game manager and textbox system
- `Player.gd` - Character controller for 3D movement
- `interact.gd` - Interaction system for game objects
- `textbox.gd` - Rich text dialogue system

### Shaders
- PSX-style rendering shaders with authentic vertex snapping
- Fog and lighting effects
- Dithering and transparency effects
- LCD post-processing overlay

### Audio
- Atmospheric background music
- Interactive sound effects for dialogue
- Multiple music tracks for different game areas

## Getting Started

1. **Prerequisites**: Install Godot 4.4 or later
2. **Clone/Download**: Get the project files
3. **Open Project**: Launch Godot and open `project.godot`
4. **Run**: Press F5 or click the Play button

## Controls

- **Movement**: WASD keys
- **Interaction**: E key (default)
- **Dialogue**: Space/Enter to continue

## Development

### Adding New Scenes
- Create new scene files in the `scenes/` folder
- Add corresponding scripts in the `scripts/` folder
- Register autoloads in project settings if needed

### Audio Integration
- Place music files in the `music/` folder
- Add sound effects to the `sounds/` folder
- Configure audio in the AudioStreamPlayer nodes

### Shader Customization
- Edit shader files in the `shaders/` folder
- Modify post-processing materials in `post_process/`
- Adjust dithering and LCD effects as needed

## Contributing

This project is part of the Gameseed initiative by Gedagedi Game Studio. 


## Credits

- **Developer**: Gedagedi Game Studio
- **Engine**: Godot 4.4
- **Part of**: Gameseed Project Series

## Technical Notes

- **Viewport Size**: 320x240 with viewport stretching
- **Rendering**: Forward Plus pipeline
- **VSync**: Disabled for performance
- **Main Scene**: `post_process/pp_stack.tscn`

---

*Enigma - Experience the mystery in retro style*
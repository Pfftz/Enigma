# Simplified Warp & Spawn System Documentation

## Overview

The warp and spawn system has been greatly simplified to make it easier to use and more robust for scene transitions.

## How to Use

### Setting up a Warp Point

1. **Add a Warp scene** to your level
2. **Set Target Scene**: Use the "Quick Load" (Ctrl+O) to select the target scene as a PackedScene resource
3. **Set Target Spawn Name**: Enter the name of the spawn point in the target scene (REQUIRED for proper spawning)

**Important**: Always specify a target_spawn_name to avoid confusion between spawn points!

### Setting up a Spawn Point

1. **Add a SpawnClass scene** to your level
2. **Set Spawn Name**: Give it a unique name based on where the player is coming FROM (e.g., "from_hallway1", "from_trapdoor")
3. **Set Player Direction**: Choose from the dropdown (UP, RIGHT, DOWN, LEFT)

### Naming Convention

Use descriptive spawn names that indicate where the player came from:

-   `"from_hallway1"` - Player came from hallway1 scene
-   `"from_trapdoor"` - Player came through a trapdoor
-   `"from_cellar"` - Player came from cellar scene
-   `"default"` - Only use for scenes with a single entry point

### How It Works

-   **Warp**: When player enters warp collision, scene changes automatically
-   **Spawn**: Player appears at spawn point with matching name, or default spawn if no name specified
-   **Fog**: LevelEnvironmentManager automatically finds and follows the player (no manual assignment needed)

## What Was Removed/Simplified

### Old System Issues:

-   ❌ Manual scene path typing (error-prone)
-   ❌ warp_id/spawn_warp_id matching system (confusing)
-   ❌ warp_direction requirement (made warps hard to trigger)
-   ❌ all_directions workaround flag
-   ❌ place_camera unused feature
-   ❌ Manual fog_follow_target assignment in each scene

### New System Benefits:

-   ✅ Use Godot's built-in Quick Load for scenes (no typos!)
-   ✅ Simple name-based spawn matching
-   ✅ Automatic warp triggering (just walk into the area)
-   ✅ Enum-based direction selection (readable in editor)
-   ✅ Automatic player detection for fog system
-   ✅ Robust scene transition handling

## Example Setup

**Warp in Room A (going to Room B):**

-   Target Scene: `room_b.tscn` (selected via Quick Load)
-   Target Spawn Name: `"from_room_a"`

**Spawn in Room B:**

-   Spawn Name: `"from_room_a"`
-   Player Direction: `DOWN`

**Warp in Room B (going back to Room A):**

-   Target Scene: `room_a.tscn` (selected via Quick Load)
-   Target Spawn Name: `"from_room_b"`

**Spawn in Room A:**

-   Spawn Name: `"from_room_b"`
-   Player Direction: `UP`

When player walks into the warp in Room A, they'll automatically appear at the "from_room_a" spawn in Room B, facing down. When they return, they'll appear at the "from_room_b" spawn in Room A, facing up.

## Migration from Old System

Existing warps and spawns will need to be updated:

1. Change warp target_scene from String to PackedScene (use Quick Load)
2. Replace spawn warp_id with spawn_name
3. Remove manual fog_follow_target assignments from EnvironmentManager nodes

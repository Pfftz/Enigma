# Ending System Implementation

This document explains how the ending system works in the Enigma project.

## How it Works

### 1. GameState Management

-   `GameState` autoload now tracks completion status with `good_ending`, `bad_ending`, and `game_completed` booleans
-   Completion state is automatically saved to `user://game_completion.save`
-   The state is loaded when the game starts

### 2. Title Screen Integration

-   **New Game**: Always starts from Day 1 (`res://scenes/rooms/kamar/day1.tscn`)
-   **Continue**: Only available after completing the game (either ending), starts from Day 5
-   Continue button is visually dimmed when not available

### 3. Triggering Endings

You can trigger endings in several ways:

#### Method 1: Direct GameState calls

```gdscript
# In your ending scene or game logic:
GameState.trigger_good_ending()  # For good ending
GameState.trigger_bad_ending()   # For bad ending
```

#### Method 2: Using EndingTrigger helper class

```gdscript
# In your ending scene:
EndingTrigger.trigger_ending(EndingTrigger.EndingType.GOOD_ENDING)
# or
EndingTrigger.trigger_ending(EndingTrigger.EndingType.BAD_ENDING)
```

#### Method 3: Change to ending scenes

```gdscript
# Change to the ending scenes directly:
get_tree().change_scene_to_file("res://scenes/endings/good_ending.tscn")
get_tree().change_scene_to_file("res://scenes/endings/bad_ending.tscn")
```

### 4. Automatic Return to Title

When an ending is triggered:

1. The completion state is saved
2. After a 3-second delay, the game automatically returns to the title screen
3. The Continue button becomes available and functional

## Example Implementation in Your Game

### In Day 5 or Final Scene:

```gdscript
extends Node

func check_ending_conditions():
    # Your game logic to determine ending
    var score = GameState.total_score
    var some_choice = player_made_good_choice

    if score >= 100 and some_choice:
        # Trigger good ending
        get_tree().change_scene_to_file("res://scenes/endings/good_ending.tscn")
    else:
        # Trigger bad ending
        get_tree().change_scene_to_file("res://scenes/endings/bad_ending.tscn")
```

### Direct Trigger Example:

```gdscript
extends Node

func _on_final_choice_made(is_good_choice: bool):
    if is_good_choice:
        GameState.trigger_good_ending()
    else:
        GameState.trigger_bad_ending()
```

## File Structure

```
scripts/
├── autoloads/
│   └── gamestate.gd          # Extended with ending system
├── endings/
│   ├── ending_trigger.gd     # Helper class for triggering endings
│   ├── good_ending.gd        # Good ending scene script
│   └── bad_ending.gd         # Bad ending scene script
└── levels/
    └── title.gd              # Updated to use GameState completion

scenes/
├── endings/
│   ├── good_ending.tscn      # Good ending scene
│   └── bad_ending.tscn       # Bad ending scene
└── title/
    └── title.tscn            # Title screen with working Continue button
```

## Testing

To test the ending system:

1. Run the game
2. The Continue button should be dimmed initially
3. Press F12+Enter in the title screen to simulate game completion for testing
4. The Continue button should now be enabled and lead to Day 5
5. Alternatively, trigger an ending using one of the methods above
6. The game should return to title screen after 3 seconds
7. The Continue button should now be enabled and lead to Day 5

## Notes

-   Ending state persists between game sessions
-   Both good and bad endings enable the Continue functionality
-   Continue always starts from Day 5 regardless of which ending was achieved
-   You can reset the completion state by deleting `user://game_completion.save`

C:\Users\abdul\AppData\Roaming\Godot\app_userdata\Enigma
# Bubble Minigame Integration Documentation

## Overview

This document outlines the complete integration of a bubble typing minigame into the interview QTE system, creating an "intrusive thought" mechanic that influences dialogue choices based on player performance.

## System Architecture

### Core Components

1. **DialogicQTEManager** (`dialogic_qte_interview.gd`) - Main interview system
2. **Bubble Minigame** (`main.gd`) - Typing minigame with scoring mechanics
3. **Dialogic Variables** (`project.godot`) - Score persistence and conditional branching
4. **Timeline Integration** - Conditional dialogue based on bubble performance

## Major Changes Implemented

### 1. Bubble Minigame Integration in DialogicQTEManager

#### Added Variables:

```gdscript
var bubble_minigame_score: int = 0
var waiting_for_bubble_result: bool = false
```

#### New Functions Added:

-   `start_bubble_minigame()` - Instantiates and launches bubble minigame
-   `_on_bubble_minigame_completed(minigame_score: int)` - Handles minigame completion

#### Signal Handling Enhanced:

-   Added "start_bubble_minigame" signal handler in `_on_dialogic_signal()`
-   Removed problematic duplicate flag setting that caused deadlock

### 2. Bubble Minigame Core System (`main.gd`)

#### Scoring Mechanics:

-   **Positive Words**: ["BISA", "OKAY", "KUAT", "CUKUP", "MAJU", "RELAX", "FOKUS", "SABAR"]
-   **Trap Words**: ["RAGU", "LEMAH", "TAKUT", "KALAH", "GUSAR", "PUTUS", "BICIK"]
-   **Scoring**: +5 points for positive words, -10 points for trap words
-   **Duration**: 20 seconds gameplay timer

#### Key Functions:

-   `handle_typing(event)` - Processes keyboard input and word completion
-   `game_over()` - Shows final score and emits completion signal
-   `spawn_new_bubble()` - Creates bubble instances with word assignment

#### Visual Feedback:

-   Real-time score display during gameplay
-   Final score presentation with 2-second delay
-   "Waktu Habis!\nSkor Akhir: [score]" end game message

### 3. Dialogic Configuration (`project.godot`)

#### Variables Added/Modified:

```gdscript
variables={
    "bubble_score": 0,  # Fixed from false to 0 (proper integer type)
    # ... other existing variables
}
```

#### Timeline Integration:

-   **Day 1**: `interview_q2_bubble_result`
-   **Day 2**: `interview_day2_q2_bubble_result`
-   **Day 3**: `interview_day3_q2_bubble_result`
-   **Day 4**: `interview_day4_q2_bubble_result`
-   **Day 5**: `interview_day5_q2_bubble_result`

### 4. Conditional Dialogue System

#### Branching Logic:

```
if {bubble_score} >= 50:
    [Player gives confident/positive response]
else:
    [Player gives hesitant/negative response]
```

#### Implementation Flow:

1. Question 2 starts normally with timer
2. After answering, `start_bubble_minigame` signal triggers
3. Bubble minigame runs for 20 seconds
4. Score determines dialogue branch in `*_q2_bubble_result` timelines
5. Interview continues to Question 3

## Technical Solutions Implemented

### 1. Deadlock Prevention

**Problem**: `waiting_for_bubble_result = true` set before calling `start_bubble_minigame()`, causing immediate return.

**Solution**: Removed duplicate flag setting in signal handler:

```gdscript
# BEFORE (problematic):
"start_bubble_minigame":
    waiting_for_bubble_result = true  # ← Removed this line
    start_bubble_minigame()

# AFTER (fixed):
"start_bubble_minigame":
    start_bubble_minigame()
```

### 2. Score Transfer Issues

**Problem**: Dialogic variable type mismatch (`bubble_score: false` instead of `0`).

**Solution**: Fixed variable definition in `project.godot`:

```gdscript
"bubble_score": 0,  # Changed from false to 0
```

### 3. Final Score Display Timing

**Problem**: Score display appeared too briefly before timeline transition.

**Solution**: Reordered `game_over()` function flow:

```gdscript
func game_over():
    # 1. Show score display
    game_status_label.show()
    game_status_label.text = "Waktu Habis!\nSkor Akhir: %d" % score

    # 2. Wait 2 seconds for player to see score
    await get_tree().create_timer(2.0).timeout

    # 3. THEN emit signal to continue interview
    minigame_completed.emit(score)
```

### 4. Scene Management

**Problem**: Memory leaks and "previously freed" errors with bubble cleanup.

**Solution**: Added comprehensive validation:

```gdscript
# Safe bubble removal
if bubble_game_instance and is_instance_valid(bubble_game_instance):
    bubble_game_instance.queue_free()
    bubble_game_instance = null

# Safe node access
if is_instance_valid(target_bubble):
    # Process bubble interaction
```

## Debug Features Added

### Extensive Logging System:

-   Score tracking throughout minigame
-   Dialogic variable verification
-   Signal emission confirmation
-   Scene transition monitoring
-   Bubble interaction feedback

### Debug Output Examples:

```
DEBUG: Starting bubble minigame with score: 0
DEBUG: Hit positive bubble, score now: 5
DEBUG: Bubble minigame final score: 45
DEBUG: Received bubble score from minigame: 45
DEBUG: Set bubble_score in Dialogic to: 45
DEBUG: Starting timeline: interview_q2_bubble_result
```

## Game Flow Integration

### Complete Interview Sequence:

1. **Question 1**: Standard timed QTE choice
2. **Question 2**:
    - Standard timed QTE choice
    - Triggers `start_bubble_minigame` signal
    - Bubble minigame runs (20 seconds)
    - Score-based conditional response in `*_q2_bubble_result`
3. **Question 3**: Final standard timed QTE choice
4. **Results**: Day completion and scene transition

### Score Thresholds:

-   **≥50 points**: Confident, positive dialogue responses
-   **<50 points**: Hesitant, negative dialogue responses

## File Structure Changes

### New/Modified Files:

-   `scripts/core_game/qte/dialogic_qte_interview.gd` - Enhanced with bubble integration
-   `scripts/core_game/main.gd` - Complete bubble minigame implementation
-   `project.godot` - Dialogic variable type fixes
-   Timeline files (`.dtl`) - Conditional branching logic

### Scene Files:

-   `scenes/core_game/main.tscn` - Bubble minigame scene
-   `scenes/core_game/bubble.tscn` - Individual bubble components
-   `scenes/core_game/positive_bubble.tscn` - Trap bubble variants

## Performance Considerations

### Memory Management:

-   Proper scene cleanup with `queue_free()`
-   Validation checks with `is_instance_valid()`
-   Signal disconnection on scene removal

### Timing Optimization:

-   Non-blocking async operations with `await`
-   Smooth transitions between systems
-   Responsive input handling during minigame

## Future Enhancement Possibilities

### Potential Improvements:

1. **Dynamic Difficulty**: Adjust trap word frequency based on day
2. **Visual Polish**: Enhanced particle effects and animations
3. **Audio Integration**: Typing sounds and feedback audio
4. **Score Persistence**: Track bubble performance across multiple days
5. **Multiple Thresholds**: More granular response variations (e.g., 0-25, 25-50, 50-75, 75+)

## Testing Scenarios

### Verification Steps:

1. **High Score Test**: Complete many positive words (>50 points)
2. **Low Score Test**: Hit trap words or minimal interaction (<50 points)
3. **Edge Cases**: Exactly 50 points, negative scores
4. **System Integration**: Verify proper timeline transitions
5. **Memory Testing**: Multiple minigame cycles without leaks

## Known Issues and Solutions

### Resolved Issues:

-   ✅ Deadlock prevention in signal handling
-   ✅ Score transfer between systems
-   ✅ Final score display timing
-   ✅ Memory management and cleanup
-   ✅ Variable type consistency

### System Requirements:

-   Godot 4.4 or higher
-   Dialogic addon properly configured
-   All timeline files present and accessible

## Conclusion

The bubble minigame integration creates a seamless "intrusive thought" mechanic that adds depth to the interview system. Player performance in the typing minigame directly influences dialogue responses, creating a dynamic narrative experience where internal mental state affects external behavior.

The system is robust, well-tested, and ready for production use with comprehensive error handling and debug capabilities for future maintenance.

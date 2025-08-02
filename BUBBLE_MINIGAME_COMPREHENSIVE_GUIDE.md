# Bubble Minigame Comprehensive Guide

## Table of Contents

1. [Overview](#overview)
2. [Game Mechanics](#game-mechanics)
3. [Scoring System](#scoring-system)
4. [Multi-Scene System](#multi-scene-system)
5. [Integration with Interview Flow](#integration-with-interview-flow)
6. [Timeline Structure](#timeline-structure)
7. [Day-Specific Variations](#day-specific-variations)
8. [Technical Implementation](#technical-implementation)
9. [Debugging and Troubleshooting](#debugging-and-troubleshooting)
10. [Customization Guide](#customization-guide)

## Overview

The Bubble Minigame is an "intrusive thought" mechanic integrated into the interview QTE system. It represents the character's internal mental state affecting their dialogue responses. Players must type words that appear in floating bubbles within a time limit, and their performance determines how confidently their character responds to interview questions.

### Core Concept

-   **Narrative Purpose**: Simulates dealing with intrusive thoughts during stressful interviews
-   **Gameplay Impact**: Score affects dialogue choices and character responses
-   **Integration**: Seamlessly embedded between question 2 and question 3 of each interview day
-   **Multi-Scene System**: Different bubble scenes for each day with unique configurations

## Game Mechanics

### Basic Gameplay

1. **Duration**: 20 seconds of active gameplay
2. **Objective**: Type words that appear in floating bubbles
3. **Input Method**: Standard keyboard typing
4. **Visual Feedback**: Bubbles animate when typed correctly
5. **Progressive Difficulty**: More bubbles spawn as game progresses

### Bubble Types

#### 1. Normal Bubbles (Positive Words)

-   **Color**: Standard blue/default color
-   **Words**: ["BISA", "OKAY", "KUAT", "CUKUP", "MAJU", "RELAX", "FOKUS", "SABAR"]
-   **Score Value**: +5 points each
-   **Purpose**: Represent positive, confident thoughts

#### 2. Trap Bubbles (Negative Words)

-   **Color**: Different visual style (red/warning color)
-   **Words**: ["RAGU", "LEMAH", "TAKUT", "KALAH", "GUSAR", "PUTUS", "BICIK"]
-   **Score Value**: -10 points each
-   **Purpose**: Represent negative, self-doubting thoughts

#### 3. Golden Bubble (Ultimate Mode)

-   **Trigger**: Appears when score ≥ 50 points
-   **Mechanic**: Requires rapid key pressing (15 presses)
-   **Visual**: Special golden appearance with enhanced effects
-   **Reward**: Significantly boosts final score

### Typing Mechanics

-   **Target Selection**: Start typing any visible word to select that bubble
-   **Completion**: Must type the complete word exactly
-   **Case Sensitive**: All words are in UPPERCASE
-   **Error Handling**: Incorrect typing resets current target
-   **Multi-targeting**: Can switch between bubbles if needed

## Scoring System

### Base Scoring

```
Positive Word Completion: +5 points
Trap Word Completion: -10 points (penalty for negative thoughts)
Minimum Score: No lower limit (can go negative)
Ultimate Threshold: 50 points
```

### Score Ranges and Meaning

-   **≥ 50 points**: Excellent mental state, confident responses
-   **25-49 points**: Good mental state, positive but cautious responses
-   **0-24 points**: Neutral mental state, basic responses
-   **Below 0**: Poor mental state, hesitant/negative responses

### Ultimate Mode Mechanics

```gdscript
# Triggers when score >= 50
if score >= ultimate_score_threshold and not is_ultimate_triggered:
    trigger_ultimate()

# Ultimate bubble requires 15 rapid key presses
ultimate_spam_count: int = 15
```

## Multi-Scene System

### Scene Architecture

The bubble minigame uses different scene files for each interview day, allowing for unique configurations, difficulty progressions, and visual variations per day.

#### Scene Mapping

```
Day 1: res://scenes/core_game/main.tscn
Day 2: res://scenes/core_game/main2.tscn
Day 3: res://scenes/core_game/main3.tscn
Day 4: res://scenes/core_game/main4.tscn
Day 5: res://scenes/core_game/main5_1.tscn (1st bubble)
Day 5: res://scenes/core_game/main5_2.tscn (2nd bubble)
Day 5: res://scenes/core_game/main5_3.tscn (3rd bubble)
```

#### Dynamic Scene Loading

The system automatically selects the correct scene based on the current interview day:

```gdscript
# Function to get the correct bubble scene path
func get_bubble_scene_path() -> String:
    match current_day:
        1: return "res://scenes/core_game/main.tscn"
        2: return "res://scenes/core_game/main2.tscn"
        3: return "res://scenes/core_game/main3.tscn"
        4: return "res://scenes/core_game/main4.tscn"
        5:
            # Day 5 has 3 different bubble scenes
            day5_bubble_counter += 1
            match day5_bubble_counter:
                1: return "res://scenes/core_game/main5_1.tscn"
                2: return "res://scenes/core_game/main5_2.tscn"
                3: return "res://scenes/core_game/main5_3.tscn"
```

### Day 5 Special Mechanics

Day 5 interviews include **three separate bubble minigames** during the interview:

1. **First Bubble** (main5_1.tscn): After Question 1
2. **Second Bubble** (main5_2.tscn): After Question 2
3. **Third Bubble** (main5_3.tscn): After Question 3

The system tracks which bubble scene to use via `day5_bubble_counter` which resets when Day 5 begins.

### Scene Configuration Examples

Each scene can have unique settings in the Godot editor:

#### Day 1 (main.tscn) - Tutorial Level

```gdscript
number_of_bubbles = 6
trap_chance = 0.25
bubble_replace_interval = 2.0
gameplay_duration = 20.0
```

#### Day 2 (main2.tscn) - Intermediate

```gdscript
number_of_bubbles = 6
trap_chance = 0.35
bubble_replace_interval = 1.8
gameplay_duration = 20.0
```

#### Day 4 (main4.tscn) - Advanced

```gdscript
number_of_bubbles = 8
trap_chance = 0.45
bubble_replace_interval = 1.5
gameplay_duration = 18.0
```

## Integration with Interview Flow

### Standard Interview Sequence (All Days)

1. **Question 1**: Standard timed multiple choice (12 seconds)
2. **Question 2**: Standard timed multiple choice (12 seconds)
3. **Bubble Minigame Trigger**: Activated by `[signal arg="start_bubble_minigame"]`
4. **Bubble Minigame Execution**: 20-second typing challenge
5. **Question 2 Result Timeline**: Conditional dialogue based on bubble score
6. **Question 3**: Final timed multiple choice (12 seconds)
7. **Interview Results**: Day completion and scoring

### Signal Flow

```gdscript
# In question timeline (.dtl file) - SAME FOR ALL DAYS
[signal arg="start_bubble_minigame"]

# In DialogicQTEManager - Automatic scene selection
func _on_dialogic_signal(argument: String):
    match argument:
        "start_bubble_minigame":
            start_bubble_minigame() # Automatically loads correct scene

# Dynamic scene loading based on current day
func start_bubble_minigame():
    var scene_path = get_bubble_scene_path()
    var bubble_scene = load(scene_path)
    bubble_game_instance = bubble_scene.instantiate()

# In bubble minigame (main.gd) - SAME FOR ALL SCENES
minigame_completed.emit(final_score)

# Back in DialogicQTEManager
func _on_bubble_minigame_completed(minigame_score: int):
    bubble_minigame_score = minigame_score
    # Start result timeline based on score
```

### Timeline Usage

**Important**: All timeline files continue to use the same signal regardless of day:

```dialogic
# This works for ALL days - no changes needed to existing timelines
[signal arg="start_bubble_minigame"]
```

The system automatically detects which day is active and loads the appropriate scene.
"start_bubble_minigame":
start_bubble_minigame()

# In bubble minigame (main.gd)

minigame_completed.emit(final_score)

# Back in DialogicQTEManager

func \_on_bubble_minigame_completed(minigame_score: int):
bubble_minigame_score = minigame_score
Dialogic.VAR.set('bubble_score', bubble_minigame_score) # Start result timeline based on score

```

## Timeline Structure

### File Naming Convention

```

interview_q2.dtl # Question 2 (triggers bubble minigame)
interview_q2_bubble_result.dtl # Question 2 result (conditional)
interview_day2_q2.dtl # Day 2 Question 2
interview_day2_q2_bubble_result.dtl # Day 2 Question 2 result

````

### Conditional Response Structure

```dialogic
# In *_bubble_result.dtl files
if {bubble_score} >= 50:
    # High score response - confident, positive
    character: [Confident dialogue with positive tone]
    set {interview_score} += 30
    [signal arg="correct_choice"]
else:
    # Low score response - hesitant, uncertain
    character: [Hesitant dialogue with uncertain tone]
    set {interview_score} += 15  # Lower bonus
    [signal arg="correct_choice"]

[wait time="1.0"]
[signal arg="update_ui"]
[signal arg="next_question"]
````

## Day-Specific Variations

### Recommended Scene Configurations

Each day's bubble scene can be configured with unique settings to create a progression of difficulty and narrative tension:

#### Day 1: Introduction (main.tscn)

```gdscript
# Tutorial-friendly settings
positive_thoughts = ["BISA", "OKAY", "KUAT", "MAJU", "RELAX", "FOKUS", "SABAR", "TENANG"]
trap_thoughts = ["RAGU", "LEMAH", "TAKUT", "KALAH", "GUSAR", "PUTUS", "BICIK"]
number_of_bubbles = 6
trap_chance = 0.25        # 25% trap bubbles
gameplay_duration = 20.0   # Full 20 seconds
bubble_replace_interval = 2.0  # Slower replacement
```

#### Day 2: Building Pressure (main2.tscn)

```gdscript
# Slightly increased difficulty
number_of_bubbles = 6
trap_chance = 0.35        # 35% trap bubbles
gameplay_duration = 20.0
bubble_replace_interval = 1.8  # Faster replacement
```

#### Day 3: Mid-Point Crisis (main3.tscn)

```gdscript
# Moderate challenge
positive_thoughts = ["KREATIF", "INOVASI", "VISI", "SENI", "INSPIRASI", "MIMPI"]
trap_thoughts = ["GAGAL", "BIASA", "KOSONG", "HAMPA", "STUCK", "BUNTU"]
number_of_bubbles = 7
trap_chance = 0.40
gameplay_duration = 18.0   # Reduced time
bubble_replace_interval = 1.6
```

#### Day 4: High Stakes (main4.tscn)

```gdscript
# Challenging settings
number_of_bubbles = 8
trap_chance = 0.45        # 45% trap bubbles
gameplay_duration = 18.0
bubble_replace_interval = 1.4  # Fast replacement
min_pop_respawn_delay = 1.0
max_pop_respawn_delay = 2.0
```

#### Day 5: Final Challenge (main5_1.tscn, main5_2.tscn, main5_3.tscn)

**Scene 1 (main5_1.tscn)**: Overwhelming start

```gdscript
number_of_bubbles = 8
trap_chance = 0.50        # 50% trap bubbles
gameplay_duration = 16.0   # Shorter duration
bubble_replace_interval = 1.2
```

**Scene 2 (main5_2.tscn)**: Peak difficulty

```gdscript
number_of_bubbles = 9
trap_chance = 0.55
gameplay_duration = 15.0   # Even shorter
bubble_replace_interval = 1.0
```

**Scene 3 (main5_3.tscn)**: Final test

```gdscript
number_of_bubbles = 10
trap_chance = 0.60        # 60% trap bubbles
gameplay_duration = 14.0   # Shortest duration
bubble_replace_interval = 0.8  # Fastest replacement
```

### Thematic Word Variations

You can customize the word sets for each company/day:

#### Day 1: Bananazon (Environmental)

```gdscript
positive_thoughts = ["HIJAU", "BERSIH", "ALAM", "SEHAT", "LESTARI", "DAUR", "HEMAT", "RAMAH"]
trap_thoughts = ["POLUSI", "LIMBAH", "RUSAK", "KOTOR", "HABIS", "BUANG", "BOROS", "RACUN"]
```

#### Day 2: TechCorp (Technology)

```gdscript
positive_thoughts = ["INOVASI", "DIGITAL", "SMART", "CLOUD", "DATA", "AI", "CODE", "TECH"]
trap_thoughts = ["LAG", "ERROR", "CRASH", "VIRUS", "HACK", "SPAM", "GLITCH", "OFFLINE"]
```

### Implementation Steps

1. **Create Scene Variants**: Duplicate `main.tscn` to create `main2.tscn`, `main3.tscn`, etc.
2. **Configure Settings**: Adjust the exported variables in each scene's Inspector
3. **Test Progression**: Ensure difficulty scales appropriately
4. **No Timeline Changes**: Existing `.dtl` files work unchanged

## Day 1 Complete Flow Example

### Step-by-Step Breakdown

#### 1. Interview Initialization

```dialogic
# interview_q1.dtl
set {interview_day} = 1
set {company_name} = "bananazon"
set {interview_score} = 0
```

#### 2. Question 1 (Standard QTE)

```dialogic
bananazon_interviewer: Siang MC, nama saya HR Pohon
[signal arg="timer_start"]

- Siang, saya juga senang bertemu anda
    set {interview_score} += 5
    [signal arg="correct_choice"]
```

#### 3. Question 2 Setup

```dialogic
# interview_q2.dtl
bananazon_interviewer: Kenapa anda tertarik untuk mendaftar ke eco-sigma
[signal arg="timer_start"]

- Karena saya mau membantu melestarikan alam
    set {interview_score} += 8
    [signal arg="correct_choice"]

# After Q2 choices, trigger bubble minigame
bananazon_interviewer: Berapa jumlah jendela di gedung yang ada di jakarta
[signal arg="start_bubble_minigame"]
```

#### 4. Bubble Minigame Execution

```
Game Flow:
1. Narrative setup: "PERTANYAAN MACAM APA ITU?"
2. Context: "singkirkan pikiran intrusif mu"
3. Countdown: 3, 2, 1
4. Bubble spawning with progressive difficulty
5. 20 seconds of active typing gameplay
6. Score calculation and ultimate mode (if applicable)
7. Final score display: "Waktu Habis! Skor Akhir: [score]"
8. Signal emission: minigame_completed(final_score)
```

#### 5. Question 2 Result (Conditional Response)

```dialogic
# interview_q2_bubble_result.dtl
if {bubble_score} >= 50:
    # High performance - confident answer
    character: Ada dua. Jendela kesempatan dan jendela dunia
    set {interview_score} += 10
    bananazon_interviewer: jawaban yang sangat bijak
else:
    # Low performance - uncertain answer
    character: um... lebih dari 3
    set {interview_score} += 15
    bananazon_interviewer: ahh... butuh lebih banyak menginjak rumput sepertinya

[signal arg="next_question"]
```

#### 6. Question 3 (Final Question)

```dialogic
# interview_q3.dtl
bananazon_interviewer: dimana anda melihat diri anda 5 tahun keepan?
[signal arg="timer_start"]

- menjadi pupuk bagi anda
    set {interview_score} += 10
    [signal arg="correct_choice"]
```

#### 7. Interview Completion

```dialogic
# Final results in interview_q3.dtl
if {interview_score} >= 25:
    bananazon_interviewer: You did great! Kami akan kabari anda di hari jumat
else:
    bananazon_interviewer: Kami tidak menerima orang seperti anda. Terima kasih

set {day1_completed} = true
set {day1_score} = {interview_score}
```

## Technical Implementation

### Multi-Scene Architecture

#### 1. DialogicQTEManager (`scripts/core_game/qte/dialogic_qte_interview.gd`)

**Updated Core Variables:**

```gdscript
# Dynamic scene loading - no more single preload
var bubble_game_instance = null
var day5_bubble_counter: int = 0  # Track Day 5 bubble sequence

# Key functions for multi-scene system
func get_bubble_scene_path() -> String  # NEW: Dynamic scene selection
func start_bubble_minigame()            # UPDATED: Uses dynamic loading
func _on_bubble_minigame_completed(minigame_score: int)
func _on_dialogic_signal(argument: String)
```

**Dynamic Scene Selection Logic:**

```gdscript
func get_bubble_scene_path() -> String:
    match current_day:
        1: return "res://scenes/core_game/main.tscn"
        2: return "res://scenes/core_game/main2.tscn"
        3: return "res://scenes/core_game/main3.tscn"
        4: return "res://scenes/core_game/main4.tscn"
        5:
            day5_bubble_counter += 1
            match day5_bubble_counter:
                1: return "res://scenes/core_game/main5_1.tscn"
                2: return "res://scenes/core_game/main5_2.tscn"
                3: return "res://scenes/core_game/main5_3.tscn"
```

**Updated Minigame Start Function:**

```gdscript
func start_bubble_minigame():
    # Get the correct scene for current day
    var scene_path = get_bubble_scene_path()
    var bubble_scene = load(scene_path)
    bubble_game_instance = bubble_scene.instantiate()
    add_child(bubble_game_instance)
    bubble_game_instance.minigame_completed.connect(_on_bubble_minigame_completed)
```

#### 2. Bubble Minigame Scenes

**Shared Script:** All scenes use the same `scripts/core_game/main.gd`

**Per-Scene Configuration (Inspector Settings):**

```gdscript
# Configurable via Godot Inspector for each scene
@export var positive_thoughts: Array[String]
@export var trap_thoughts: Array[String]
@export var number_of_bubbles: int = 6
@export var trap_chance: float = 0.25
@export var gameplay_duration: float = 20.0
@export var bubble_replace_interval: float = 2.0
```

**Scene Files:**

-   `main.tscn` → Day 1 configuration
-   `main2.tscn` → Day 2 configuration
-   `main3.tscn` → Day 3 configuration
-   `main4.tscn` → Day 4 configuration
-   `main5_1.tscn` → Day 5, First bubble
-   `main5_2.tscn` → Day 5, Second bubble
-   `main5_3.tscn` → Day 5, Third bubble

#### 3. Individual Bubbles (`scripts/core_game/bubble.gd`)

**Unchanged:** Bubble behavior remains consistent across all scenes

```gdscript
var positive_affirmation: String
func setup(word: String)
func play_typing_feedback()
signal popped(position: Vector2)
```

func pop()

```

### Scene Structure

```

main.tscn (Bubble Minigame Scene)
├── GameStatusLabel (Instructions/countdown)
├── ScoreLabel (Current score display)
├── TimeLabel (Remaining time)
├── PlayerInputLabel (Current typed text)
├── GameplayTimer (20-second timer)
└── BubbleRespawnTimer (New bubble spawning)

bubble.tscn (Individual Bubble)
├── Sprite2D (Visual representation)
├── TypingLabel (Word display)
├── AnimationPlayer (Typing feedback)
├── GPUParticles2D (Pop effects)
└── AudioStreamPlayer2D (Sound effects)

````

## Debugging and Troubleshooting

### Common Issues and Solutions

#### 1. Timeline Not Progressing

**Problem**: Interview gets stuck after bubble minigame
**Solution**: Check timeline_in_progress flag management

```gdscript
# Ensure flag is cleared after completion
timeline_in_progress = false
waiting_for_bubble_result = false
````

#### 2. Score Not Transferring

**Problem**: Bubble score doesn't affect dialogue
**Solution**: Verify Dialogic variable setting

```gdscript
# Correct variable type in project.godot
"bubble_score": 0  # Must be integer, not boolean

# Proper score transfer
Dialogic.VAR.set('bubble_score', bubble_minigame_score)
```

#### 3. Memory Leaks

**Problem**: Multiple minigame instances causing crashes
**Solution**: Proper cleanup validation

```gdscript
if bubble_game_instance and is_instance_valid(bubble_game_instance):
    bubble_game_instance.queue_free()
    bubble_game_instance = null
```

### Debug Logging

The system includes comprehensive debug output:

```
DEBUG: Starting bubble minigame with score: 0
DEBUG: Hit positive bubble, score now: 5
DEBUG: Bubble minigame final score: 45
DEBUG: Starting timeline: interview_q2_bubble_result
```

## Customization Guide

### Difficulty Adjustment

#### Bubble Count and Timing

```gdscript
# Adjust these variables in main.gd
@export_range(2, 6) var number_of_bubbles: int = 6
@export var gameplay_duration: float = 20.0
@export_range(0.0, 1.0) var trap_chance: float = 0.25
```

#### Score Values

```gdscript
# Modify scoring in handle_typing function
if target_bubble.is_in_group("trap_bubbles"):
    score -= 10  # Penalty for negative words
else:
    score += 5   # Reward for positive words
```

#### Ultimate Mode

```gdscript
@export var ultimate_score_threshold: int = 50
@export var ultimate_spam_count: int = 15
```

### Adding New Words

#### Positive Words (Confidence Building)

```gdscript
var positive_words = [
    "BISA", "OKAY", "KUAT", "CUKUP",
    "MAJU", "RELAX", "FOKUS", "SABAR"
    # Add new positive words here
]
```

#### Trap Words (Self-Doubt)

```gdscript
var trap_words = [
    "RAGU", "LEMAH", "TAKUT", "KALAH",
    "GUSAR", "PUTUS", "BICIK"
    # Add new trap words here
]
```

### Score Threshold Customization

#### Multiple Response Tiers

```dialogic
if {bubble_score} >= 75:
    # Exceptional performance
    character: [Extremely confident response]
    set {interview_score} += 40
elif {bubble_score} >= 50:
    # Good performance
    character: [Confident response]
    set {interview_score} += 30
elif {bubble_score} >= 25:
    # Average performance
    character: [Neutral response]
    set {interview_score} += 20
else:
    # Poor performance
    character: [Hesitant response]
    set {interview_score} += 10
```

### Visual Customization

#### Bubble Appearance

-   Modify `bubble.tscn` for visual changes
-   Adjust `Sprite2D` textures and colors
-   Customize `GPUParticles2D` for pop effects

#### UI Elements

-   Edit labels in `main.tscn` for different fonts/colors
-   Modify countdown text and instructions
-   Customize score display formatting

---

## Conclusion

The Bubble Minigame system creates a unique psychological gameplay element that directly impacts narrative outcomes. By simulating the challenge of managing intrusive thoughts during stressful situations, it adds depth to the interview experience while maintaining seamless integration with the overall QTE system.

The system is robust, well-documented, and easily customizable for different difficulty levels or narrative themes. Its modular design allows for easy expansion and modification while maintaining stability and performance.

---

## Quick Setup Guide for Multi-Scene System

### For Developers

1. **Create Scene Variants**:

    ```
    - Duplicate main.tscn → main2.tscn, main3.tscn, main4.tscn
    - Create main5_1.tscn, main5_2.tscn, main5_3.tscn for Day 5
    ```

2. **Configure Each Scene**:

    - Open each scene in Godot Editor
    - Select the root node (main/main2)
    - Adjust exported variables in Inspector:
        - `number_of_bubbles`
        - `trap_chance`
        - `gameplay_duration`
        - `bubble_replace_interval`
        - `positive_thoughts` array
        - `trap_thoughts` array

3. **Test the System**:
    - All existing timeline files work unchanged
    - Use `[signal arg="start_bubble_minigame"]` in any `.dtl` file
    - Debug output shows which scene is loaded: `"Loading bubble scene for Day X: path"`

### For Timeline Authors

**No changes required!** Continue using:

```dialogic
[signal arg="start_bubble_minigame"]
```

The system automatically detects the current day and loads the appropriate scene.

### Benefits of This Approach

-   ✅ **No timeline changes needed** - existing `.dtl` files work unchanged
-   ✅ **Centralized logic** - scene selection handled in one place
-   ✅ **Easy to extend** - add new days by creating new scenes
-   ✅ **Per-day customization** - each scene can have unique settings
-   ✅ **Day 5 multi-bubble support** - automatic sequencing for complex interviews
-   ✅ **Maintainable** - one signal type, automatic routing

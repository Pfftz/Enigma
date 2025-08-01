# Bubble Minigame Comprehensive Guide

## Table of Contents

1. [Overview](#overview)
2. [Game Mechanics](#game-mechanics)
3. [Scoring System](#scoring-system)
4. [Integration with Interview Flow](#integration-with-interview-flow)
5. [Timeline Structure](#timeline-structure)
6. [Day 1 Complete Flow Example](#day-1-complete-flow-example)
7. [Technical Implementation](#technical-implementation)
8. [Debugging and Troubleshooting](#debugging-and-troubleshooting)
9. [Customization Guide](#customization-guide)

## Overview

The Bubble Minigame is an "intrusive thought" mechanic integrated into the interview QTE system. It represents the character's internal mental state affecting their dialogue responses. Players must type words that appear in floating bubbles within a time limit, and their performance determines how confidently their character responds to interview questions.

### Core Concept

-   **Narrative Purpose**: Simulates dealing with intrusive thoughts during stressful interviews
-   **Gameplay Impact**: Score affects dialogue choices and character responses
-   **Integration**: Seamlessly embedded between question 2 and question 3 of each interview day

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
# In question timeline (.dtl file)
[signal arg="start_bubble_minigame"]

# In DialogicQTEManager
func _on_dialogic_signal(argument: String):
    match argument:
        "start_bubble_minigame":
            start_bubble_minigame()

# In bubble minigame (main.gd)
minigame_completed.emit(final_score)

# Back in DialogicQTEManager
func _on_bubble_minigame_completed(minigame_score: int):
    bubble_minigame_score = minigame_score
    Dialogic.VAR.set('bubble_score', bubble_minigame_score)
    # Start result timeline based on score
```

## Timeline Structure

### File Naming Convention

```
interview_q2.dtl                    # Question 2 (triggers bubble minigame)
interview_q2_bubble_result.dtl      # Question 2 result (conditional)
interview_day2_q2.dtl              # Day 2 Question 2
interview_day2_q2_bubble_result.dtl # Day 2 Question 2 result
```

### Conditional Response Structure

```dialogic
# In *_bubble_result.dtl files
if {bubble_score} >= 50:
    # High score response - confident, positive
    character: [Confident dialogue with positive tone]
    set {interview_score} += 30
    set {interview_health} += 30
    [signal arg="correct_choice"]
else:
    # Low score response - hesitant, uncertain
    character: [Hesitant dialogue with uncertain tone]
    set {interview_score} += 15  # Lower bonus
    set {interview_health} += 15
    [signal arg="correct_choice"]

[wait time="1.0"]
[signal arg="update_ui"]
[signal arg="next_question"]
```

## Day 1 Complete Flow Example

### Step-by-Step Breakdown

#### 1. Interview Initialization

```dialogic
# interview_q1.dtl
set {interview_day} = 1
set {company_name} = "bananazon"
set {interview_score} = 0
set {interview_health} = 80.0
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

### Key Classes and Files

#### 1. DialogicQTEManager (`scripts/core_game/qte/dialogic_qte_interview.gd`)

```gdscript
# Core variables
var bubble_minigame_score: int = 0
var waiting_for_bubble_result: bool = false
var timeline_in_progress: bool = false

# Key functions
func start_bubble_minigame()
func _on_bubble_minigame_completed(minigame_score: int)
func _on_dialogic_signal(argument: String)
```

#### 2. Bubble Minigame (`scripts/core_game/main.gd`)

```gdscript
# Core variables
var positive_words = ["BISA", "OKAY", "KUAT", ...]
var trap_words = ["RAGU", "LEMAH", "TAKUT", ...]
var score = 0
var gameplay_duration: float = 20.0

# Key functions
func start_new_game()
func handle_typing(event)
func game_over()
```

#### 3. Individual Bubbles (`scripts/core_game/bubble.gd`)

```gdscript
# Bubble behavior
var positive_affirmation: String
func setup(word: String)
func play_typing_feedback()
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
```

## Debugging and Troubleshooting

### Common Issues and Solutions

#### 1. Timeline Not Progressing

**Problem**: Interview gets stuck after bubble minigame
**Solution**: Check timeline_in_progress flag management

```gdscript
# Ensure flag is cleared after completion
timeline_in_progress = false
waiting_for_bubble_result = false
```

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

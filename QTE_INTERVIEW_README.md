# Quick Time Event Interview System

This system creates a job interview minigame with quick time events similar to visual novels, featuring multiple choice qu## Extension Ideas

-   Add sound effects for timer warnings
-   Implement different interview scenarios
-   Add character animations
-   Create difficulty levels
-   Add branching storylines based on performance

## Troubleshooting

### Common Issues and Solutions

#### "Invalid access to property or key 'theme_override_font_sizes'"

**Solution**: This was fixed by using `add_theme_font_size_override()` instead of direct property access.

#### "Could not find type 'QuickTimeEvent' or 'InterviewManager'"

**Solution**: Use `Control` or `Node` as type hints instead of custom class names, or ensure the class_name is properly defined.

#### Dialogic Integration Issues

**Solution**: The system safely checks for Dialogic availability before attempting to use it. If Dialogic isn't properly set up, it falls back to direct QTE functionality.

### Performance Tips

-   The system automatically cleans up temporary UI elements
-   JSON data is loaded once at startup for efficiency
-   Timers are properly managed to prevent memory leaks with time limits.

## Features

-   Multiple choice questions with 2-4 options
-   Countdown timer for each question
-   Score tracking with positive/negative consequences
-   Health/performance bar
-   Customizable questions via JSON
-   Integration with Dialogic (optional)
-   Visual feedback for answers
-   Auto-progression when time expires

## Files Created

### Core System

-   `scenes/ui/quick_time_event.tscn` - Main QTE scene with UI
-   `scripts/ui/quick_time_event.gd` - Core QTE logic and functionality
-   `resource/interview_questions.json` - Question data and scoring

### Optional Components

-   `scripts/manager/interview_manager.gd` - Manager for Dialogic integration
-   `dialogic/timelines/interview_intro.dtl` - Sample Dialogic timeline

### Test/Demo

-   `scenes/ui/interview_simple_test.tscn` - Simple test scene
-   `scripts/ui/interview_simple_test.gd` - Test script

## How to Use

### Basic Usage (Standalone)

1. Load the QuickTimeEvent scene:

```gdscript
var qte_scene = preload("res://scenes/ui/quick_time_event.tscn")
var qte_instance = qte_scene.instantiate()
add_child(qte_instance)
```

2. Connect to signals for feedback:

```gdscript
qte_instance.question_answered.connect(_on_question_answered)
qte_instance.interview_completed.connect(_on_interview_completed)
qte_instance.time_expired.connect(_on_time_expired)
```

### Testing

1. Run the scene `scenes/ui/interview_simple_test.tscn`
2. Click "Start Interview QTE" to begin
3. Answer questions within the time limit
4. View your final score and outcome

## JSON Data Structure

The `interview_questions.json` file contains:

```json
{
    "interview_questions": [
        {
            "day": 1,
            "question": "Your question text here",
            "options": [
                {
                    "text": "Option 1 text",
                    "type": "correct",
                    "score_change": 5
                }
            ],
            "timer": 12
        }
    ],
    "scoring": {
        "excellent": 25,
        "good": 15,
        "average": 5,
        "poor": -5
    },
    "consequences": {
        "good": "Good choice!",
        "poor": "Poor choice."
    }
}
```

### Question Properties:

-   `day`: Day number for display
-   `question`: The question text
-   `options`: Array of answer options
-   `timer`: Time limit in seconds

### Option Properties:

-   `text`: Button text for the option
-   `type`: "correct", "wrong", "neutral" (affects feedback)
-   `score_change`: Points added/subtracted (+/-)

## Customization

### Adding New Questions

Edit `resource/interview_questions.json` and add new question objects to the array.

### Styling

Modify the scene file `scenes/ui/quick_time_event.tscn` to change:

-   Colors and themes
-   Button layouts
-   Timer display
-   Health bar appearance

### Scoring System

Adjust scoring thresholds in the JSON file's `scoring` section.

### Integration with Dialogic

Use `InterviewManager` to integrate with Dialogic:

```gdscript
var manager = InterviewManager.new()
manager.start_interview_with_dialogic("interview_intro")
```

## Signals

The QuickTimeEvent emits these signals:

-   `question_answered(score_change: int, choice_type: String)` - When player picks an option
-   `interview_completed(final_score: int)` - When all questions are done
-   `time_expired()` - When time runs out on a question

## Controls

-   **Left Mouse Click**: Select answer options
-   **Auto-progression**: System automatically moves to next question
-   **Timer**: Visual countdown with color changes (white → yellow → red)

## Performance

The system is lightweight and suitable for:

-   Visual novel games
-   Educational applications
-   Job simulation games
-   Quick decision-making minigames

## Example Indonesian Questions

The default JSON includes Indonesian language questions about job interviews, similar to the provided reference images.

## Extension Ideas

-   Add sound effects for timer warnings
-   Implement different interview scenarios
-   Add character animations
-   Create difficulty levels
-   Add branching storylines based on performance

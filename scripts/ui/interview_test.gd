extends Control

@onready var interview_manager: Node = $InterviewManager
@onready var start_button: Button = $UI/StartButton
@onready var reset_button: Button = $UI/ResetButton
@onready var score_label: Label = $UI/ScoreLabel

func _ready() -> void:
	# Connect button signals
	start_button.pressed.connect(_on_start_button_pressed)
	reset_button.pressed.connect(_on_reset_button_pressed)
	
	# Connect interview manager signals
	interview_manager.interview_started.connect(_on_interview_started)
	interview_manager.interview_ended.connect(_on_interview_ended)

func _on_start_button_pressed() -> void:
	start_button.disabled = true
	interview_manager.start_quick_time_event()

func _on_reset_button_pressed() -> void:
	interview_manager.reset_interview()
	start_button.disabled = false
	score_label.text = "Score will appear here"

func _on_interview_started() -> void:
	score_label.text = "Interview in progress..."

func _on_interview_ended(final_score: int) -> void:
	score_label.text = "Final Score: " + str(final_score)
	start_button.disabled = false

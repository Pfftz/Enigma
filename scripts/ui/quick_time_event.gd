extends Control

class_name QuickTimeEvent

# UI References
@onready var dialogue_label: Label = $CenterContainer/InterviewPanel/VBoxContainer/DialogueBox/DialogueLabel
@onready var timer_label: Label = $CenterContainer/InterviewPanel/VBoxContainer/TimerContainer/TimerLabel
@onready var day_label: Label = $DayLabel
@onready var score_display: Label = $ScoreDisplay
@onready var health_bar: ProgressBar = $CenterContainer/InterviewPanel/VBoxContainer/CompanyHeader/HealthBar
@onready var timer: Timer = $Timer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var option_buttons: Array[Button] = [
	$CenterContainer/InterviewPanel/VBoxContainer/OptionsContainer/TopRow/Option1,
	$CenterContainer/InterviewPanel/VBoxContainer/OptionsContainer/TopRow/Option2,
	$CenterContainer/InterviewPanel/VBoxContainer/OptionsContainer/BottomRow/Option3,
	$CenterContainer/InterviewPanel/VBoxContainer/OptionsContainer/BottomRow/Option4
]

# Game Data
var interview_data: Dictionary = {}
var current_question_index: int = 0
var current_day: int = 1
var total_score: int = 0
var health: float = 80.0
var time_remaining: float = 12.0
var is_question_active: bool = false

# Signals
signal question_answered(score_change: int, choice_type: String)
signal interview_completed(final_score: int)
signal time_expired()

func _ready() -> void:
	load_interview_data()
	setup_ui()
	start_interview()

func _process(_delta: float) -> void:
	if is_question_active and time_remaining > 0:
		time_remaining -= _delta
		update_timer_display()
		
		if time_remaining <= 0:
			handle_timeout()

func load_interview_data() -> void:
	var file = FileAccess.open("res://resource/interview_questions.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			interview_data = json.data
		else:
			print("Error parsing interview data: ", json.get_error_message())
	else:
		print("Could not load interview_questions.json")

func setup_ui() -> void:
	# Connect button signals
	for i in range(option_buttons.size()):
		if option_buttons[i]:
			option_buttons[i].pressed.connect(_on_option_selected.bind(i))
	
	# Setup timer
	timer.timeout.connect(_on_timer_timeout)
	
	# Initial UI state
	update_score_display()
	update_health_display()

func start_interview() -> void:
	if interview_data.has("interview_questions"):
		load_question(current_question_index)
	else:
		print("No interview questions found!")

func load_question(question_index: int) -> void:
	var questions = interview_data.get("interview_questions", [])
	
	if question_index >= questions.size():
		complete_interview()
		return
	
	var question_data = questions[question_index]
	
	# Update UI with question data
	current_day = question_data.get("day", 1)
	day_label.text = "DAY " + str(current_day)
	dialogue_label.text = question_data.get("question", "")
	
	# Set up options
	var options = question_data.get("options", [])
	for i in range(option_buttons.size()):
		if i < options.size():
			option_buttons[i].text = options[i].get("text", "")
			option_buttons[i].visible = true
			option_buttons[i].disabled = false
		else:
			option_buttons[i].visible = false
	
	# Start timer
	time_remaining = question_data.get("timer", 12.0)
	is_question_active = true
	update_timer_display()

func _on_option_selected(option_index: int) -> void:
	if not is_question_active:
		return
	
	is_question_active = false
	
	var questions = interview_data.get("interview_questions", [])
	var current_question = questions[current_question_index]
	var options = current_question.get("options", [])
	
	if option_index < options.size():
		var selected_option = options[option_index]
		var score_change = selected_option.get("score_change", 0)
		var choice_type = selected_option.get("type", "neutral")
		
		# Update score and health
		total_score += score_change
		health = clamp(health + score_change, 0, 100)
		
		# Update displays
		update_score_display()
		update_health_display()
		
		# Show feedback
		show_feedback(choice_type, score_change)
		
		# Emit signal
		question_answered.emit(score_change, choice_type)
		
		# Disable all buttons
		for button in option_buttons:
			button.disabled = true
		
		# Wait a moment then proceed to next question
		await get_tree().create_timer(2.0).timeout
		proceed_to_next_question()

func handle_timeout() -> void:
	if not is_question_active:
		return
	
	is_question_active = false
	time_remaining = 0
	update_timer_display()
	
	# Apply timeout penalty
	var penalty = -5
	total_score += penalty
	health = clamp(health + penalty, 0, 100)
	
	update_score_display()
	update_health_display()
	
	# Show timeout feedback
	show_feedback("timeout", penalty)
	
	# Disable all buttons
	for button in option_buttons:
		button.disabled = true
	
	time_expired.emit()
	
	# Wait a moment then proceed to next question
	await get_tree().create_timer(2.0).timeout
	proceed_to_next_question()

func proceed_to_next_question() -> void:
	current_question_index += 1
	load_question(current_question_index)

func complete_interview() -> void:
	is_question_active = false
	dialogue_label.text = "Interview completed! Final score: " + str(total_score)
	
	# Hide options
	for button in option_buttons:
		button.visible = false
	
	timer_label.text = "Complete"
	
	interview_completed.emit(total_score)

func update_timer_display() -> void:
	var seconds = int(ceil(time_remaining))
	timer_label.text = str(seconds) + "s"
	
	# Change color based on remaining time
	if time_remaining <= 3:
		timer_label.modulate = Color.RED
	elif time_remaining <= 6:
		timer_label.modulate = Color.YELLOW
	else:
		timer_label.modulate = Color.WHITE

func update_score_display() -> void:
	score_display.text = "Score: " + str(total_score)

func update_health_display() -> void:
	health_bar.value = health
	
	# Change health bar color based on health level
	var color = Color.GREEN
	if health < 30:
		color = Color.RED
	elif health < 60:
		color = Color.YELLOW
	
	health_bar.modulate = color

func show_feedback(choice_type: String, score_change: int) -> void:
	var feedback_text = ""
	var consequences = interview_data.get("consequences", {})
	
	match choice_type:
		"correct", "good":
			feedback_text = consequences.get("good", "Good choice!")
		"wrong", "poor":
			feedback_text = consequences.get("poor", "Poor choice.")
		"timeout":
			feedback_text = "Time's up! Moving to next question."
		_:
			feedback_text = consequences.get("average", "Acceptable choice.")
	
	if score_change > 0:
		feedback_text += " (+" + str(score_change) + ")"
	elif score_change < 0:
		feedback_text += " (" + str(score_change) + ")"
	
	# Create a temporary feedback label
	var feedback_label = Label.new()
	feedback_label.text = feedback_text
	feedback_label.add_theme_font_size_override("font_size", 14)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.modulate = Color.WHITE if score_change >= 0 else Color.RED
	
	# Add to scene temporarily
	add_child(feedback_label)
	feedback_label.position = Vector2(get_viewport().get_visible_rect().size.x / 2 - 100, 100)
	
	# Animate and remove
	var tween = create_tween()
	tween.tween_property(feedback_label, "modulate:a", 0.0, 1.5)
	tween.tween_callback(feedback_label.queue_free)

func _on_timer_timeout() -> void:
	# This is called every second to update the timer display
	pass

# Public methods for external control
func reset_interview() -> void:
	current_question_index = 0
	total_score = 0
	health = 80.0
	is_question_active = false
	start_interview()

func get_current_score() -> int:
	return total_score

func get_current_health() -> float:
	return health

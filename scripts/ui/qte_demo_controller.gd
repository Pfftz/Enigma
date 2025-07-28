extends Control

@onready var qte_manager: DialogicQTEManager = $DialogicQTEManager
@onready var start_button: Button = $UI/ControlPanel/VBoxContainer/StartButton
@onready var reset_button: Button = $UI/ControlPanel/VBoxContainer/ResetButton
@onready var skip_button: Button = $UI/ControlPanel/VBoxContainer/SkipButton
@onready var status_label: Label = $UI/ControlPanel/VBoxContainer/StatusLabel
@onready var day_selector: OptionButton = $UI/ControlPanel/VBoxContainer/DaySelector

func _ready() -> void:
	setup_ui()
	connect_signals()
	setup_day_selector()

func setup_ui() -> void:
	# Initialize UI elements
	status_label.text = "Ready to start interview sequence"

func connect_signals() -> void:
	# Connect button signals
	start_button.pressed.connect(_on_start_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	skip_button.pressed.connect(_on_skip_pressed)
	
	# Connect QTE manager signals
	qte_manager.interview_day_completed.connect(_on_day_completed)
	qte_manager.all_interviews_completed.connect(_on_all_completed)
	qte_manager.timer_expired.connect(_on_timer_expired)

func setup_day_selector() -> void:
	day_selector.add_item("Day 1 - Bananazon")
	day_selector.add_item("Day 2 - TechCorp")
	day_selector.add_item("Day 3 - CreativeStudio")
	day_selector.add_item("Day 4 - GreenCorp")
	day_selector.add_item("Day 5 - MegaCorp")

func _on_start_pressed() -> void:
	start_button.disabled = true
	status_label.text = "Starting interview sequence..."
	qte_manager.start_interview_sequence()

func _on_reset_pressed() -> void:
	start_button.disabled = false
	status_label.text = "Interview sequence reset"
	qte_manager.reset_interview_sequence()

func _on_skip_pressed() -> void:
	var selected_day = day_selector.selected + 1
	start_button.disabled = true
	status_label.text = "Skipping to Day " + str(selected_day)
	qte_manager.skip_to_day(selected_day)

func _on_day_completed(day: int, score: int) -> void:
	status_label.text = "Day " + str(day) + " completed! Score: " + str(score)

func _on_all_completed(final_score: int) -> void:
	start_button.disabled = false
	status_label.text = "All interviews completed! Final Score: " + str(final_score)

func _on_timer_expired() -> void:
	status_label.text = "Time expired on current question!"

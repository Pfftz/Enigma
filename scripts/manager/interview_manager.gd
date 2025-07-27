extends Node

class_name InterviewManager

# References
var quick_time_event_scene: PackedScene = preload("res://scenes/ui/quick_time_event.tscn")
var current_qte_instance: Control = null

# Interview state
var interview_results: Dictionary = {}
var is_interview_active: bool = false

signal interview_started()
signal interview_ended(final_score: int)

func _ready() -> void:
	# Connect to Dialogic signals if using Dialogic integration
	# Check if Dialogic exists and is available
	if Engine.has_singleton("Dialogic") or get_node_or_null("/root/Dialogic"):
		var dialogic = get_node_or_null("/root/Dialogic")
		if dialogic and dialogic.has_signal("signal_event"):
			dialogic.signal_event.connect(_on_dialogic_signal)

func start_interview_with_dialogic(timeline_name: String = "interview_intro") -> void:
	"""Start the interview using Dialogic for intro/outro"""
	var dialogic = get_node_or_null("/root/Dialogic")
	if dialogic and dialogic.has_method("start"):
		dialogic.start(timeline_name)
	else:
		# Fallback to direct QTE start
		start_quick_time_event()

func start_quick_time_event() -> void:
	"""Start the quick time event interview directly"""
	if current_qte_instance:
		current_qte_instance.queue_free()
	
	current_qte_instance = quick_time_event_scene.instantiate()
	get_tree().current_scene.add_child(current_qte_instance)
	
	# Connect QTE signals
	current_qte_instance.question_answered.connect(_on_question_answered)
	current_qte_instance.interview_completed.connect(_on_interview_completed)
	current_qte_instance.time_expired.connect(_on_time_expired)
	
	is_interview_active = true
	interview_started.emit()

func _on_dialogic_signal(argument: String) -> void:
	"""Handle signals from Dialogic timeline"""
	match argument:
		"start_qte_interview":
			start_quick_time_event()
		"end_interview":
			end_interview()

func _on_question_answered(score_change: int, choice_type: String) -> void:
	"""Handle when a question is answered in the QTE"""
	print("Question answered: ", choice_type, " Score change: ", score_change)
	
	# Store results for later use
	if not interview_results.has("answers"):
		interview_results["answers"] = []
	
	interview_results["answers"].append({
		"score_change": score_change,
		"choice_type": choice_type,
		"timestamp": Time.get_unix_time_from_system()
	})

func _on_interview_completed(final_score: int) -> void:
	"""Handle when the interview is completed"""
	interview_results["final_score"] = final_score
	interview_results["completion_time"] = Time.get_unix_time_from_system()
	
	is_interview_active = false
	interview_ended.emit(final_score)
	
	print("Interview completed with score: ", final_score)
	
	# You can add logic here to determine what happens next based on the score
	handle_interview_outcome(final_score)

func _on_time_expired() -> void:
	"""Handle when time expires on a question"""
	print("Time expired on a question")

func handle_interview_outcome(final_score: int) -> void:
	"""Determine the outcome based on the final score"""
	var outcome_message: String = ""
	
	if final_score >= 25:
		outcome_message = "Excellent! You got the job!"
	elif final_score >= 15:
		outcome_message = "Good performance! You're hired!"
	elif final_score >= 5:
		outcome_message = "Acceptable. We'll consider your application."
	else:
		outcome_message = "Unfortunately, we cannot offer you the position."
	
	# Show outcome using Dialogic or a simple popup
	show_interview_outcome(outcome_message, final_score)

func show_interview_outcome(message: String, score: int) -> void:
	"""Display the interview outcome"""
	# Create a simple outcome dialog
	var outcome_dialog = AcceptDialog.new()
	outcome_dialog.dialog_text = message + "\n\nFinal Score: " + str(score)
	outcome_dialog.title = "Interview Results"
	
	get_tree().current_scene.add_child(outcome_dialog)
	outcome_dialog.popup_centered()
	
	# Clean up the QTE instance
	if current_qte_instance:
		await get_tree().create_timer(1.0).timeout
		current_qte_instance.queue_free()
		current_qte_instance = null

func end_interview() -> void:
	"""Manually end the interview"""
	if current_qte_instance:
		current_qte_instance.complete_interview()

func get_interview_results() -> Dictionary:
	"""Get the results of the last interview"""
	return interview_results

func reset_interview() -> void:
	"""Reset the interview state"""
	interview_results.clear()
	is_interview_active = false
	
	if current_qte_instance:
		current_qte_instance.reset_interview()

# Utility functions
func save_interview_results_to_file(file_path: String = "user://interview_results.json") -> void:
	"""Save interview results to a file"""
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(interview_results))
		file.close()
		print("Interview results saved to: ", file_path)

func load_interview_results_from_file(file_path: String = "user://interview_results.json") -> Dictionary:
	"""Load interview results from a file"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			return json.data
	
	return {}

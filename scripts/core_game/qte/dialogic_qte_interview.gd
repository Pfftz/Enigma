extends Control

class_name DialogicQTEManager

# Dynamic bubble scene loading - no longer need single preload
var bubble_game_instance = null

# UI References from original QTE scene
@onready var score_display: Label = $ScoreDisplay
@onready var day_label: Label = $DayLabel
@onready var company_label: Label = $CenterContainer/InterviewPanel/VBoxContainer/CompanyHeader/CompanyLabel
@onready var timer_display: Label = $CenterContainer/InterviewPanel/VBoxContainer/TimerContainer/TimerLabel
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

# Dialogic Integration
var current_day: int = 1
var interview_timelines: Array[String] = [
	"interview_day1_bananazon",
	"interview_day2_techcorp",
	"interview_day3_creative",
	"interview_day4_green",
	"interview_day5_megacorp"
]

var company_names: Array[String] = [
	"bananazon",
	"TechCorp",
	"CreativeStudio",
	"GreenCorp",
	"MegaCorp"
]

# Bubble minigame integration
var bubble_minigame_score: int = 0
var waiting_for_bubble_result: bool = false

# Timer system for dialogic choices
var timer_active: bool = false
var time_remaining: float = 12.0
var timer_node: Timer
var current_question: int = 1 # Track which question we're currently on

# Game State
var total_score: int = 0
var game_over: bool = false
var timeline_in_progress: bool = false # Prevent multiple timeline executions
var day5_bubble_counter: int = 0 # Track which bubble scene to use for day 5

# Signals
signal interview_day_completed(day: int, score: int)
signal all_interviews_completed(final_score: int)
signal player_kicked_out(day: int) # New signal for game over

# Function to get the correct bubble scene path based on day and question
func get_bubble_scene_path() -> String:
	match current_day:
		1:
			return "res://scenes/core_game/main.tscn"
		2:
			return "res://scenes/core_game/main2.tscn"
		3:
			return "res://scenes/core_game/main3.tscn"
		4:
			return "res://scenes/core_game/main4.tscn"
		5:
			# Day 5 has 3 different bubble scenes
			day5_bubble_counter += 1
			match day5_bubble_counter:
				1:
					return "res://scenes/core_game/main5_1.tscn"
				2:
					return "res://scenes/core_game/main5_2.tscn"
				3:
					return "res://scenes/core_game/main5_3.tscn"
				_:
					# Fallback to first scene if counter exceeds 3
					return "res://scenes/core_game/main5_1.tscn"
		_:
			# Fallback for any unexpected day
			return "res://scenes/core_game/main.tscn"

func _ready() -> void:
	# 2. Siapkan UI awal
	setup_ui()
	
	# 3. Hubungkan sinyal dari Dialogic ke fungsi di skrip ini
	setup_dialogic_signals()
	
	# 4. CARA BARU & PALING STABIL:
	# Tunda pemanggilan start_interview_sequence() sesaat (satu frame)
	# untuk memberi waktu pada Dialogic untuk siap sepenuhnya.
	get_tree().create_timer(0.01, false).timeout.connect(start_interview_sequence)

func setup_dialogic_signals() -> void:
	# Connect to Dialogic signals
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

func _process(delta: float) -> void:
	if timer_active and time_remaining > 0:
		time_remaining -= delta
		update_timer_display()
		
		if time_remaining <= 0:
			handle_timer_timeout()

func setup_ui() -> void:
	# Initialize UI elements
	update_score_display()
	day_label.text = "DAY 1"
	company_label.text = company_names[0]

func setup_timer() -> void:
	# Create timer node for QTE timing
	timer_node = Timer.new()
	add_child(timer_node)
	timer_node.timeout.connect(_on_timer_timeout)

# Fungsi ini HANYA akan berjalan SETELAH scene siap sepenuhnya
func start_interview_sequence():
	# Ambil hari dari GameState dan mulai wawancara
	var day_from_gamestate = GameState.current_day
	start_interview_day(day_from_gamestate)

func start_interview_day(day: int) -> void:
	if day > interview_timelines.size():
		complete_all_interviews()
		return
	
	if game_over:
		return
	
	current_day = day
	current_question = 1 # Reset question counter for new day
	
	# Reset day 5 bubble counter when starting a new day
	if day == 5:
		day5_bubble_counter = 0
	
	# Update UI for current day
	day_label.text = "DAY " + str(day)
	company_label.text = company_names[day - 1]
	
	# Reset day variables using set() method
	Dialogic.VAR.set('interview_score', 0)
	Dialogic.VAR.set('interview_day', day)
	Dialogic.VAR.set('company_name', company_names[day - 1])
	Dialogic.VAR.set('bubble_score', 0) # Initialize bubble score
	
	# Start with the first question timeline
	start_question_timeline(1)

func start_question_timeline(question_num: int) -> void:
	if timeline_in_progress:
		print("DEBUG: Timeline already in progress, skipping question ", question_num)
		return
		
	current_question = question_num
	timeline_in_progress = true
	print("Starting question ", question_num, " for day ", current_day)
	
	var timeline_name = ""
	
	match current_day:
		1:
			match question_num:
				1: timeline_name = "interview_q1"
				2: timeline_name = "interview_q2"
				3: timeline_name = "interview_q3"
		2:
			match question_num:
				1: timeline_name = "interview_day2_q1"
				2: timeline_name = "interview_day2_q2"
				3: timeline_name = "interview_day2_q3"
		3:
			match question_num:
				1: timeline_name = "interview_day3_q1"
				2: timeline_name = "interview_day3_q2"
				3: timeline_name = "interview_day3_q3"
		4:
			match question_num:
				1: timeline_name = "interview_day4_q1"
				2: timeline_name = "interview_day4_q2"
				3: timeline_name = "interview_day4_q3"
		5:
			match question_num:
				1: timeline_name = "interview_day5_q1"
				2: timeline_name = "interview_day5_q2"
				3: timeline_name = "interview_day5_q3"
	
	if timeline_name != "":
		Dialogic.start(timeline_name)
	else:
		print("ERROR: No timeline found for day ", current_day, " question ", question_num)
		timeline_in_progress = false

func _on_dialogic_signal(argument: String) -> void:
	# Handle custom signals from Dialogic timelines
	match argument:
		"start_bubble_minigame":
			start_bubble_minigame()
		"timer_start":
			start_qte_timer(12.0)
		"timer_end":
			stop_qte_timer()
		"correct_choice":
			play_feedback_sound("correct")
		"wrong_choice":
			play_feedback_sound("wrong")
		"update_ui":
			update_score_display()
		"kick_out":
			kick_out_player()
		"next_question":
			# Check if we need to move to next question
			if current_question < 3:
				start_question_timeline(current_question + 1)
			else:
				# Day completed
				_on_timeline_ended()
		"timeout":
			play_feedback_sound("timeout")
		"force_timeout":
			handle_dialogic_timeout()
		"question_start":
			# Reset timer when question starts
			stop_qte_timer()
			print("Question started, timer reset")

func start_qte_timer(duration: float) -> void:
	time_remaining = duration
	timer_active = true
	update_timer_display()
	print("Timer started: ", duration, " seconds")

func stop_qte_timer() -> void:
	timer_active = false
	timer_display.text = ""
	timer_display.modulate = Color.WHITE
	print("Timer stopped")

func handle_timer_timeout() -> void:
	if not timer_active:
		return
	
	timer_active = false
	time_remaining = 0
	
	# Update timer display to show time's up
	timer_display.text = "TIME UP!"
	timer_display.modulate = Color.RED
	
	# Switch to appropriate timeout timeline based on current question
	var timeout_timeline = get_current_timeout_label()
	if timeout_timeline != "":
		print("Timer expired! Switching to timeout timeline: ", timeout_timeline)
		Dialogic.start(timeout_timeline)
	else:
		print("Timer expired! No timeout timeline found for question ", current_question)
		# If no timeout timeline, move to next question directly
		if current_question < 3:
			await get_tree().create_timer(1.0).timeout
			start_question_timeline(current_question + 1)
		else:
			show_interview_results()

func get_current_timeout_label() -> String:
	var timeout_timeline = ""
	
	match current_day:
		1:
			match current_question:
				1: timeout_timeline = "interview_q1_timeout"
				2: timeout_timeline = "interview_q2_timeout"
				3: timeout_timeline = "interview_q3_timeout"
		2:
			match current_question:
				1: timeout_timeline = "interview_day2_q1_timeout"
				2: timeout_timeline = "interview_day2_q2_timeout"
				3: timeout_timeline = "interview_day2_q3_timeout"
		3:
			match current_question:
				1: timeout_timeline = "interview_day3_q1_timeout"
				2: timeout_timeline = "interview_day3_q2_timeout"
				3: timeout_timeline = "interview_day3_q3_timeout"
		4:
			match current_question:
				1: timeout_timeline = "interview_day4_q1_timeout"
				2: timeout_timeline = "interview_day4_q2_timeout"
				3: timeout_timeline = "interview_day4_q3_timeout"
		5:
			match current_question:
				1: timeout_timeline = "interview_day5_q1_timeout"
				2: timeout_timeline = "interview_day5_q2_timeout"
				3: timeout_timeline = "interview_day5_q3_timeout"
	
	return timeout_timeline

func handle_dialogic_timeout() -> void:
	# Called from Dialogic when timer expires in timeline
	if timer_active:
		handle_timer_timeout()

func kick_out_player() -> void:
	# Player gets kicked out by HR
	game_over = true
	stop_qte_timer()
	
	# Show game over message
	day_label.text = "GAME OVER"
	company_label.text = "HR Decision: Rejected"
	
	var game_over_message = "You have been dismissed from the interview process.\n"
	game_over_message += "Your performance was insufficient to continue.\n"
	game_over_message += "Day reached: " + str(current_day) + "\n"
	game_over_message += "Final Score: " + str(total_score)
	
	print(game_over_message)
	
	# Stop the current timeline
	Dialogic.end_timeline()
	
	# Emit signal for game over handling
	player_kicked_out.emit(current_day)

func _on_timer_timeout() -> void:
	# Timer signal handler
	pass

# Fungsi untuk memulai minigame bubble
func start_bubble_minigame():
	# Prevent starting multiple instances
	if waiting_for_bubble_result or bubble_game_instance != null:
		print("DEBUG: Bubble minigame already running, skipping...")
		return
	
	# Also check if any existing bubble game nodes exist and remove them
	var existing_bubble_games = get_tree().get_nodes_in_group("bubble_minigame")
	if existing_bubble_games.size() > 0:
		print("DEBUG: Found existing bubble games, removing them...")
		for game in existing_bubble_games:
			if is_instance_valid(game):
				game.queue_free()
		await get_tree().process_frame
		
	print("Memulai Bubble Typing Minigame...")
	waiting_for_bubble_result = true
	
	# Stop any active timers
	stop_qte_timer()
	
	# Sembunyikan dialog agar tidak menutupi
	var dialog_node = find_child("Dialogic", true, false)
	if dialog_node:
		dialog_node.visible = false

	# Get the correct bubble scene for current day
	var scene_path = get_bubble_scene_path()
	print("DEBUG: Loading bubble scene for Day ", current_day, ": ", scene_path)
	var bubble_scene = load(scene_path)
	
	if bubble_scene == null:
		print("ERROR: Could not load bubble scene: ", scene_path)
		waiting_for_bubble_result = false
		return
	
	bubble_game_instance = bubble_scene.instantiate()
	add_child(bubble_game_instance)

	# Hubungkan sinyal dari minigame ke fungsi di skrip ini
	bubble_game_instance.minigame_completed.connect(_on_bubble_minigame_completed)

# Fungsi yang dipanggil saat minigame bubble selesai
func _on_bubble_minigame_completed(minigame_score: int):
	bubble_minigame_score = minigame_score
	
	print("DEBUG: Received bubble score from minigame: ", minigame_score)
	
	# Set the bubble score in Dialogic variables
	Dialogic.VAR.set('bubble_score', bubble_minigame_score)
	
	print("DEBUG: Set bubble_score in Dialogic to: ", Dialogic.VAR.get('bubble_score'))
	print("Bubble minigame completed with score: ", bubble_minigame_score)
	
	# Remove the bubble game instance
	if bubble_game_instance and is_instance_valid(bubble_game_instance):
		bubble_game_instance.queue_free()
		bubble_game_instance = null
	
	# Show dialog again
	var dialog_node = find_child("Dialogic", true, false)
	if dialog_node:
		dialog_node.visible = true
	
	# Clear the waiting flag AND timeline progress flag BEFORE starting the next timeline
	waiting_for_bubble_result = false
	timeline_in_progress = false
	
	# Continue to the next part of the interview based on current question and day
	var timeline_name = ""
	
	match current_day:
		1:
			match current_question:
				1:
					timeline_name = "interview_q1_bubble_result"
				2:
					timeline_name = "interview_q2_bubble_result"
				3:
					timeline_name = "interview_q3"
		2:
			match current_question:
				1:
					timeline_name = "interview_day2_q1_bubble_result"
				2:
					timeline_name = "interview_day2_q2_bubble_result"
				3:
					timeline_name = "interview_day2_q3"
		3:
			match current_question:
				1:
					timeline_name = "interview_day3_q1_bubble_result"
				2:
					timeline_name = "interview_day3_q2_bubble_result"
				3:
					timeline_name = "interview_day3_q3"
		4:
			match current_question:
				1:
					timeline_name = "interview_day4_q1_bubble_result"
				2:
					timeline_name = "interview_day4_q2_bubble_result"
				3:
					timeline_name = "interview_day4_q3"
		5:
			match current_question:
				1:
					timeline_name = "interview_day5_q1_bubble_result"
				2:
					timeline_name = "interview_day5_q2_bubble_result"
				3:
					timeline_name = "interview_day5_q3"
	
	if timeline_name != "":
		print("DEBUG: Starting timeline: ", timeline_name)
		# Wait a brief moment to ensure the minigame is fully cleaned up
		await get_tree().create_timer(0.2).timeout
		Dialogic.start(timeline_name)
	else:
		print("No timeline found for day ", current_day, " question ", current_question)

# Di dalam DialogicQTEManager.gd
func _on_timeline_ended() -> void:
	print("DEBUG: Timeline ended - game_over:", game_over, " waiting_for_bubble:", waiting_for_bubble_result)
	
	# Clear the timeline progress flag
	timeline_in_progress = false
	
	if game_over:
		return

	# Don't auto-proceed if we're waiting for bubble result
	if waiting_for_bubble_result:
		print("DEBUG: Timeline ended but waiting for bubble result, ignoring...")
		return

	print("DEBUG: Timeline ended, proceeding to next question or results...")
	print("DEBUG: Current question:", current_question, " Current day:", current_day)
	
	await get_tree().create_timer(1.0).timeout

	# Check if we need to move to next question or show results
	if current_question < 3:
		print("DEBUG: Moving to question ", current_question + 1)
		start_question_timeline(current_question + 1)
	else:
		print("DEBUG: All questions completed, showing results...")
		show_interview_results()

func show_interview_results() -> void:
	if not is_inside_tree():
		print("Warning: Node is not in scene tree, cannot show interview results")
		return
		
	var day_score = Dialogic.VAR.get("interview_score") if Dialogic.VAR.has("interview_score") else 0
	
	# Emit the completion signal
	interview_day_completed.emit(current_day, day_score)
	
	# Display completion message
	var completion_message = "Day " + str(current_day) + " completed!\n"
	completion_message += "Score this day: " + str(day_score)
	print(completion_message)
	
	# Wait before proceeding (only if still in tree)
	if is_inside_tree():
		await get_tree().create_timer(2.0).timeout
	
	# DIUBAH TOTAL:
	# Hapus `GameState.advance_to_next_day()`
	# Sekarang kita kembali ke kamar di HARI YANG SAMA
	if current_day < 5:
		var current_room_path = GameState.get_current_room_scene()
		get_tree().change_scene_to_file(current_room_path)
	else:
		# Jika ini hari terakhir, jalankan logika penyelesaian
		complete_all_interviews()

func complete_all_interviews() -> void:
	# Clear any timeline progress flags
	timeline_in_progress = false
	
	all_interviews_completed.emit(total_score)
	print("Semua wawancara selesai! Skor akhir: ", GameState.total_score)
	
	# Tunggu sejenak agar pemain bisa melihat hasil
	await get_tree().create_timer(4.0).timeout
	
	# Trigger good ending through GameState
	GameState.trigger_good_ending()

func update_timer_display() -> void:
	if not timer_active:
		timer_display.text = ""
		return
		
	var seconds = int(ceil(time_remaining))
	timer_display.text = str(seconds) + "s"
	
	# Change color based on remaining time
	if time_remaining <= 3:
		timer_display.modulate = Color.RED
	elif time_remaining <= 6:
		timer_display.modulate = Color.YELLOW
	else:
		timer_display.modulate = Color.WHITE

func update_score_display() -> void:
	var current_interview_score = Dialogic.VAR.get("interview_score") if Dialogic.VAR.has("interview_score") else 0
	var display_score = total_score + current_interview_score
	score_display.text = "Score: " + str(display_score)

func play_feedback_sound(type: String) -> void:
	# Play different sounds based on choice result
	# You can load different sound files here
	match type:
		"correct":
			# Load and play success sound
			pass
		"wrong":
			# Load and play error sound
			pass
		"timeout":
			# Load and play timeout sound
			pass

# Public methods for external control
func reset_interview_sequence() -> void:
	current_day = 1
	total_score = 0
	timer_active = false
	game_over = false
	start_interview_sequence()

func get_total_score() -> int:
	return total_score

func get_current_day() -> int:
	return current_day

func is_game_over() -> bool:
	return game_over

func skip_to_day(day: int) -> void:
	if day >= 1 and day <= interview_timelines.size() and not game_over:
		start_interview_day(day)

# Method to transition between interview days (for "ruang one" integration)
func prepare_for_next_day() -> void:
	# This method can be called when transitioning from "ruang one" back to interview
	if not game_over and current_day < interview_timelines.size():
		start_interview_day(current_day + 1)

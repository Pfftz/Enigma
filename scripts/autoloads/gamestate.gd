# File: GameState.gd
extends Node

var current_day: int = 1
var total_score: int = 0

# Game completion tracking
var good_ending: bool = false
var bad_ending: bool = false
var game_completed: bool = false

# Daftar path scene kamar untuk setiap hari
var room_scenes: Array[String] = [
	"res://scenes/rooms/kamar/day1.tscn",
	"res://scenes/rooms/kamar/day2.tscn",
	"res://scenes/rooms/kamar/day3.tscn",
	"res://scenes/rooms/kamar/day4.tscn",
	"res://scenes/rooms/kamar/day5.tscn"
]

func advance_to_next_day() -> void:
	current_day += 1

func add_to_total_score(score: int):
	total_score += score

func get_current_room_scene() -> String:
	var day_index = current_day - 1
	if day_index < room_scenes.size():
		return room_scenes[day_index]
	else:
		return room_scenes.back()

func reset_progress() -> void:
	current_day = 1
	total_score = 0
	# Don't reset ending flags when starting new game
	# good_ending and bad_ending persist for Continue functionality

func trigger_good_ending() -> void:
	"""Call this when player gets the good ending"""
	good_ending = true
	game_completed = true
	_save_completion_state()
	print("Good ending triggered!")
	# Auto return to title after ending
	call_deferred("_return_to_title_after_ending")

func trigger_bad_ending() -> void:
	"""Call this when player gets the bad ending"""
	bad_ending = true
	game_completed = true
	_save_completion_state()
	print("Bad ending triggered!")
	# Auto return to title after ending
	call_deferred("_return_to_title_after_ending")

func is_game_completed() -> bool:
	"""Check if player has completed the game with any ending"""
	return good_ending or bad_ending

func get_continue_scene() -> String:
	"""Get the scene to load when Continue is selected"""
	if is_game_completed():
		# Start from day 5 if game is completed
		return "res://scenes/rooms/kamar/day5.tscn"
	else:
		# If somehow called without completion, return current day
		return get_current_room_scene()

func _save_completion_state() -> void:
	"""Save completion state to file"""
	var save_data = {
		"good_ending": good_ending,
		"bad_ending": bad_ending,
		"game_completed": game_completed
	}
	
	var save_file = FileAccess.open("user://game_completion.save", FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(save_data))
		save_file.close()
		print("Game completion state saved")

func _load_completion_state() -> void:
	"""Load completion state from file"""
	if FileAccess.file_exists("user://game_completion.save"):
		var save_file = FileAccess.open("user://game_completion.save", FileAccess.READ)
		if save_file:
			var json_string = save_file.get_as_text()
			save_file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				var save_data = json.data
				good_ending = save_data.get("good_ending", false)
				bad_ending = save_data.get("bad_ending", false)
				game_completed = save_data.get("game_completed", false)
				print("Game completion state loaded: good=", good_ending, " bad=", bad_ending)

func _return_to_title_after_ending() -> void:
	"""Return to title screen after a short delay"""
	await get_tree().create_timer(3.0).timeout # Wait 3 seconds to show ending
	get_tree().change_scene_to_file("res://scenes/title/title.tscn")

func _ready() -> void:
	"""Load completion state when GameState is ready"""
	_load_completion_state()

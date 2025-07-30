# Example: How to integrate game completion with the title screen
# Place this code wherever your game completion logic happens
# (e.g., in the final boss defeat, last level completion, credits scene, etc.)

extends Node

# Example function that could be called when player completes the game
func on_game_completed():
	print("Player has completed the game!")
	
	# Option 1: Direct file access (matches title screen logic)
	var file = FileAccess.open("user://game_completed.save", FileAccess.WRITE)
	if file:
		file.store_string("completed")
		file.close()
		print("Game completion saved!")
	
	# Option 2: Using GameState if you want to track more completion data
	# GameState.game_completed = true
	# GameState.completion_date = Time.get_datetime_string_from_system()
	
	# Option 3: Using a signal system
	# EventBus.game_completed.emit()

# Example integration with your interview/QTE system
func _on_all_interviews_completed(final_score: int) -> void:
	print("All interviews completed with score: ", final_score)
	
	# You could set a minimum score requirement for "completion"
	if final_score >= 80: # Example: 80% or higher to unlock Continue
		on_game_completed()
	else:
		print("Score too low for completion, try again!")

# Example integration with a level-based progression system
func _on_final_level_completed():
	print("Final level completed!")
	on_game_completed()

# Alternative: If you want the Continue button to appear after reaching a certain day
func _on_day_completed(day: int):
	if day >= 5: # Example: Unlock Continue after day 5
		on_game_completed()

# Ending Trigger Script
# This script can be used by ending scenes to trigger completion
extends Node

class_name EndingTrigger

enum EndingType {
	GOOD_ENDING,
	BAD_ENDING
}

# Call this function from your ending scenes
static func trigger_ending(ending_type: EndingType) -> void:
	match ending_type:
		EndingType.GOOD_ENDING:
			print("Triggering good ending...")
			GameState.trigger_good_ending()
		EndingType.BAD_ENDING:
			print("Triggering bad ending...")
			GameState.trigger_bad_ending()

# Example of how to use this in an ending scene:
# 
# In your ending scene script:
# func _ready():
#     # Show ending cutscene/dialogue
#     await show_ending_sequence()
#     
#     # Trigger the appropriate ending
#     EndingTrigger.trigger_ending(EndingTrigger.EndingType.GOOD_ENDING)
#     # or
#     # EndingTrigger.trigger_ending(EndingTrigger.EndingType.BAD_ENDING)

# You can also call GameState functions directly:
# GameState.trigger_good_ending()
# GameState.trigger_bad_ending()

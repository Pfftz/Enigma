extends Control

# Bad Ending Scene
# This scene should be called when the player achieves the bad ending

@onready var ending_label: Label = $VBoxContainer/EndingLabel
@onready var continue_label: Label = $VBoxContainer/ContinueLabel

func _ready() -> void:
	# Show ending text
	ending_label.text = "Game Over\nYou achieved the Bad Ending."
	continue_label.text = "Continue option is now available in the main menu."
	
	# Wait for the player to see the ending
	await get_tree().create_timer(2.0).timeout
	
	# Show continue instruction
	continue_label.visible = true
	
	# Wait a bit more
	await get_tree().create_timer(3.0).timeout
	
	# Trigger the bad ending
	GameState.trigger_bad_ending()
	
	# Note: GameState.trigger_bad_ending() will automatically return to title screen
	# after a delay, so we don't need to handle scene transition here

func _input(event: InputEvent) -> void:
	# Allow player to skip the ending by pressing any key or mouse button
	if event is InputEventKey and event.pressed:
		GameState.trigger_bad_ending()
	elif event is InputEventMouseButton and event.pressed:
		GameState.trigger_bad_ending()

extends Control

# Good Ending Scene
# This scene should be called when the player achieves the good ending

@onready var ending_label: Label = $VBoxContainer/EndingLabel
@onready var continue_label: Label = $VBoxContainer/ContinueLabel

func _ready() -> void:
	# Show ending text
	ending_label.text = "Congratulations!\nYou achieved the Good Ending!"
	continue_label.text = "Continue option is now available in the main menu."
	
	# Wait for the player to see the ending
	await get_tree().create_timer(2.0).timeout
	
	# Show continue instruction
	continue_label.visible = true
	
	# Wait a bit more
	await get_tree().create_timer(3.0).timeout
	
	# Return to title screen directly
	get_tree().change_scene_to_file("res://scenes/title/title.tscn")

func _input(event: InputEvent) -> void:
	# Allow player to skip the ending by pressing any key or mouse button
	if event is InputEventKey and event.pressed:
		get_tree().change_scene_to_file("res://scenes/title/title.tscn")
	elif event is InputEventMouseButton and event.pressed:
		get_tree().change_scene_to_file("res://scenes/title/title.tscn")

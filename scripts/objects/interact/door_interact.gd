extends Marker3D
class_name DoorInteract

@export var confirmation_timeline: String = "door_confirmation"
@export var teleport_scene_path: String = "res://scenes/rooms/nmp.tscn"
@export var delete_collision_on_interact: bool = true

@onready var interaction_symbol = $InteractionSymbol

var current_textbox: Node = null
var is_textbox_open: bool = false
var has_interacted: bool = false
var confirmation_count: int = 0

# Reference to door collision
var door_collision: CollisionShape3D

func _ready():
	# Get reference to door collision
	var door = get_parent()
	if door:
		door_collision = door.get_node_or_null("CollisionShape3D")
	
	# Connect to the interaction symbol's signals
	if interaction_symbol:
		interaction_symbol.in_area.connect(_on_in_area)
		interaction_symbol.triggered.connect(_on_triggered)

func _on_in_area(inside: bool):
	# Handle when player enters/exits the interaction area
	if inside:
		# Show interaction prompt when player enters area
		get_tree().call_group("ui", "show_interact_text", "Press F to interact")
	else:
		# Hide interaction prompt when player leaves area
		get_tree().call_group("ui", "hide_interact_text")
		
		if is_textbox_open:
			# Player left area while textbox is open - close it
			_force_close_textbox()

func _on_triggered():
	# Handle when the interaction is triggered
	if has_interacted:
		return # Prevent multiple interactions
	
	# Hide interaction prompt when interaction starts
	get_tree().call_group("ui", "hide_interact_text")
	
	if not is_textbox_open:
		# Start the confirmation timeline
		_start_confirmation_dialogue()

func _start_confirmation_dialogue():
	"""Start the door confirmation dialogue"""
	is_textbox_open = true
	confirmation_count = 0
	
	# Start the Dialogic timeline
	Dialogic.start(confirmation_timeline)
	
	# Connect to Dialogic signals to handle the dialogue results
	if not Dialogic.signal_event.is_connected(_on_dialogic_signal):
		Dialogic.signal_event.connect(_on_dialogic_signal)
	
	if not Dialogic.timeline_ended.is_connected(_on_timeline_ended):
		Dialogic.timeline_ended.connect(_on_timeline_ended)

func _on_dialogic_signal(argument: String):
	"""Handle signals from Dialogic timeline"""
	match argument:
		"door_yes":
			# Player chose to go out - delete collision to reveal warp behind door
			_delete_collision_and_finish()
			# Show information label specifically for day 5
			_show_day5_information_if_needed()
		"door_no":
			# Player chose not to go out
			confirmation_count += 1
			if confirmation_count >= 2:
				# This shouldn't happen now, but keep as fallback
				_perform_teleport()
		"door_force_teleport":
			# Force teleport after 2 "no" responses
			_perform_teleport()

func _on_timeline_ended():
	"""Handle when timeline ends"""
	is_textbox_open = false
	
	# Disconnect signals to prevent memory leaks
	if Dialogic.signal_event.is_connected(_on_dialogic_signal):
		Dialogic.signal_event.disconnect(_on_dialogic_signal)
	
	if Dialogic.timeline_ended.is_connected(_on_timeline_ended):
		Dialogic.timeline_ended.disconnect(_on_timeline_ended)

func _delete_collision_and_finish():
	"""Delete collision to reveal warp behind door without teleporting"""
	has_interacted = true
	
	# Hide interaction prompt since interaction is now disabled
	get_tree().call_group("ui", "hide_interact_text")
	
	# Delete collision if configured
	if delete_collision_on_interact and door_collision:
		door_collision.disabled = true
		print("DEBUG: Door collision disabled - warp behind door is now accessible")
	
	# Disable the interaction symbol
	if interaction_symbol:
		interaction_symbol.deactivate()
		print("DEBUG: Door interaction deactivated")

func _perform_teleport():
	"""Teleport player to the target scene"""
	has_interacted = true
	
	# Hide interaction prompt since we're teleporting
	get_tree().call_group("ui", "hide_interact_text")
	
	# Delete collision if configured
	if delete_collision_on_interact and door_collision:
		door_collision.disabled = true
	
	# Disable the interaction symbol
	if interaction_symbol:
		interaction_symbol.deactivate()
	
	# Change to target scene
	print("DEBUG: Force teleporting to: ", teleport_scene_path)
	get_tree().change_scene_to_file(teleport_scene_path)

func _force_close_textbox():
	"""Force close any open dialogue when player leaves area"""
	if is_textbox_open:
		Dialogic.end_timeline()
		is_textbox_open = false

func _show_day5_information_if_needed():
	"""Show information label specifically for day 5"""
	# Check if this is day 5 by checking the current scene name or GameState
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.name == "Day5":
		# Find and show the information label
		var ui_node = current_scene.get_node_or_null("UI")
		if ui_node:
			var info_label = ui_node.get_node_or_null("InformationLabel")
			if info_label:
				info_label.text = "keluarlah menuju cahaya"
				info_label.visible = true
				print("DEBUG: Day 5 information label shown")

extends Marker3D
class_name TrapdoorInteract

@export var interaction_text: Array[String]
@export var delete_door_on_interact: bool = true
@export var delete_collision_on_interact: bool = true
@export var play_sound_on_interact: bool = true
@export var interaction_sound: AudioStream

@onready var interaction_symbol = $InteractionSymbol

var current_textbox: Node = null
var is_textbox_open: bool = false
var has_interacted: bool = false

# References to trapdoor components
var door_mesh: MeshInstance3D
var front_collision: CollisionShape3D
var audio_player: AudioStreamPlayer3D

func _ready():
	# Get references to trapdoor components
	var trapdoor = get_parent()
	if trapdoor:
		door_mesh = trapdoor.get_node_or_null("%DoorMesh")
		front_collision = trapdoor.get_node_or_null("%FrontShape")
	
	# Create audio player if needed
	if play_sound_on_interact and interaction_sound:
		audio_player = AudioStreamPlayer3D.new()
		audio_player.stream = interaction_sound
		add_child(audio_player)
	
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
			# Player left area while textbox is open - close it with sound
			_force_close_textbox()

func _on_triggered():
	# Handle when the interaction is triggered
	if has_interacted:
		return # Prevent multiple interactions
	
	# Hide interaction prompt when interaction starts
	get_tree().call_group("ui", "hide_interact_text")
	
	if not is_textbox_open:
		# Show interaction text if provided
		if interaction_text.size() > 0:
			Global.create_Textbox(interaction_text, self)
			is_textbox_open = true
			
			# Find the created textbox and monitor it
			await get_tree().process_frame
			current_textbox = get_children().back() # The textbox should be the last child added
			if current_textbox:
				# Connect to know when textbox finishes naturally
				_monitor_textbox_completion()
		else:
			# No text, just perform the interaction immediately
			_perform_interaction()

func _perform_interaction():
	"""Perform the main interaction logic"""
	has_interacted = true
	
	# Hide interaction prompt since interaction is now disabled
	get_tree().call_group("ui", "hide_interact_text")
	
	# Play sound if configured
	if audio_player:
		audio_player.play()
	
	# Delete door mesh if configured
	if delete_door_on_interact and door_mesh:
		door_mesh.queue_free()
	
	# Delete collision if configured
	if delete_collision_on_interact and front_collision:
		front_collision.disabled = true
	
	# Disable the interaction symbol
	if interaction_symbol:
		interaction_symbol.deactivate()

func _force_close_textbox():
	"""Force close the textbox when player leaves area"""
	if current_textbox and is_instance_valid(current_textbox):
		# Play close sound effect
		var close_sound = current_textbox.get_node_or_null("Close")
		if close_sound:
			close_sound.play()
			await close_sound.finished
		
		# Clean up
		current_textbox.queue_free()
		current_textbox = null
		is_textbox_open = false

func _monitor_textbox_completion():
	"""Monitor textbox to detect when it closes naturally"""
	if not current_textbox:
		return
		
	# Check periodically if textbox still exists
	while current_textbox and is_instance_valid(current_textbox):
		await get_tree().process_frame
	
	# Textbox was closed naturally
	current_textbox = null
	is_textbox_open = false
	
	# Perform the interaction after text is closed
	_perform_interaction()

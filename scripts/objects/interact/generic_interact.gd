extends Marker3D
class_name GenericInteract

@export var interaction_text: Array[String] = ["Press E to interact"]
@export var show_text_on_interact: bool = true
@export var one_time_use: bool = true
@export var interaction_sound: AudioStream

@onready var interaction_symbol = $InteractionSymbol

var current_textbox: Node = null
var is_textbox_open: bool = false
var has_interacted: bool = false
var audio_player: AudioStreamPlayer3D

# Signal emitted when interaction is triggered (for custom behavior)
signal interaction_triggered

func _ready():
	# Create audio player if needed
	if interaction_sound:
		audio_player = AudioStreamPlayer3D.new()
		audio_player.stream = interaction_sound
		add_child(audio_player)
	
	# Connect to the interaction symbol's signals
	if interaction_symbol:
		interaction_symbol.in_area.connect(_on_in_area)
		interaction_symbol.triggered.connect(_on_triggered)

func _on_in_area(inside: bool):
	# Handle when player enters/exits the interaction area
	if not inside and is_textbox_open:
		# Player left area while textbox is open - close it with sound
		_force_close_textbox()

func _on_triggered():
	# Handle when the interaction is triggered
	if has_interacted and one_time_use:
		return # Prevent multiple interactions if one-time use
	
	if not is_textbox_open:
		# Show interaction text if configured
		if show_text_on_interact and interaction_text.size() > 0:
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
	
	# Play sound if configured
	if audio_player:
		audio_player.play()
	
	# Emit signal for custom behavior
	interaction_triggered.emit()
	
	# Disable the interaction symbol if one-time use
	if one_time_use and interaction_symbol:
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

# Public methods for external control
func enable_interaction():
	"""Re-enable the interaction (useful for multi-use interactions)"""
	has_interacted = false
	if interaction_symbol:
		interaction_symbol.enabled = true

func disable_interaction():
	"""Disable the interaction permanently"""
	has_interacted = true
	if interaction_symbol:
		interaction_symbol.deactivate()

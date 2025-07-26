extends Marker3D

@export var text = ["Text"]
@onready var interaction_symbol = $InteractionSymbol

var current_textbox: Node = null
var is_textbox_open: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
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
	if not is_textbox_open:
		# Only create textbox if one isn't already open
		Global.create_Textbox(text, self)
		is_textbox_open = true
		
		# Find the created textbox and monitor it
		await get_tree().process_frame
		current_textbox = get_children().back() # The textbox should be the last child added
		if current_textbox:
			# Connect to know when textbox finishes naturally
			_monitor_textbox_completion()

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

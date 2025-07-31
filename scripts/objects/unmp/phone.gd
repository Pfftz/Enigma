extends Marker3D

const SHAKE_AMOUNT: float = 0.05
const SHAKE_SPEED: float = 0.1

var triggered: bool = false
var shake_tween: Tween
var is_ringing: bool = true

@export_category("Phone Properties")
@export var phone_id: int
@export_category("Dialogue Properties")
@export_multiline var textbox_text: String = "The phone is ringing..."
@export_category("General Properties")
@export var destroy_after_interaction: bool = false
@export var trigger_bad_ending_after_interaction: bool = false

@onready var phone_sprite = $PhoneSprite
@onready var phone_ring = $PhoneRing
@onready var ring_visibility = $PhoneRing/RingVisibility
@onready var idle_visibility = $PhoneRing/IdleVisibility
@onready var phone_sound = $PhoneSound
@onready var ring_animation = $RingAnimation
@onready var dialogue_trigger = $DialogueTrigger


func _ready() -> void:
	# Defer setup to avoid "parent node busy" error
	call_deferred("_setup_phone")


func _setup_phone() -> void:
	# Connect to dialogue trigger signals
	if dialogue_trigger:
		# Only set text if it's not already configured in the scene
		if dialogue_trigger.text.is_empty() or (dialogue_trigger.text.size() == 1 and dialogue_trigger.text[0] == "Text"):
			# Split multiline textbox_text into array for dialogue system
			if textbox_text != "":
				var text_lines = textbox_text.split("\n\n") # Split by double newlines
				# Remove empty lines
				text_lines = text_lines.filter(func(line): return line.strip_edges() != "")
				dialogue_trigger.text = text_lines
			else:
				dialogue_trigger.text = ["The phone is ringing..."]
		
		var interaction_symbol = dialogue_trigger.get_node("InteractionSymbol")
		if interaction_symbol:
			interaction_symbol.triggered.connect(_on_dialogue_triggered)
		
		# Connect to dialogue events
		dialogue_trigger.dialogue_started.connect(_animate_phone)
		dialogue_trigger.dialogue_finished.connect(_reset_phone)
	
	# Start phone ringing
	_start_ringing()


func _start_ringing() -> void:
	"""Start the phone ringing animation and sound"""
	is_ringing = true
	
	# Show ring visibility, hide others
	phone_ring.visible = true
	phone_sprite.visible = false
	ring_visibility.visible = true
	idle_visibility.visible = false
	
	# Start ringing animation
	ring_animation.play("Ring")
	
	# Start phone sound
	phone_sound.play()
	
	# Create shake tween
	if shake_tween:
		shake_tween.kill()
	
	shake_tween = create_tween().set_loops()
	shake_tween.tween_property(
								ring_visibility,
								"position:x",
								SHAKE_AMOUNT,
								SHAKE_SPEED
							).set_trans(Tween.TRANS_SINE)
	shake_tween.tween_property(
								ring_visibility,
								"position:x",
								- SHAKE_AMOUNT,
								SHAKE_SPEED
							).set_trans(Tween.TRANS_SINE)


func _on_dialogue_triggered() -> void:
	"""Called when player interacts with the phone"""
	if not is_ringing:
		return
		
	# Stop ringing
	_stop_ringing()
	
	# Show phone sprite for conversation
	phone_ring.visible = false
	phone_sprite.visible = true
	triggered = true


func _stop_ringing() -> void:
	"""Stop the phone ringing animation and sound"""
	is_ringing = false
	
	# Stop animations and sound
	ring_animation.stop()
	phone_sound.stop()
	
	# Stop shake tween
	if shake_tween:
		shake_tween.kill()
		
	# Reset ring visibility position
	ring_visibility.position.x = 0


func _animate_phone() -> void:
	if triggered:
		phone_sprite.play(&"listen")


func _reset_phone() -> void:
	if triggered:
		print("Phone: Dialogue finished, resetting phone...")
		phone_sprite.play(&"idle")
		triggered = false
		
		# If destroy after interaction is enabled, remove the phone
		if destroy_after_interaction:
			queue_free()
		
		# Trigger bad ending after phone interaction if enabled
		if trigger_bad_ending_after_interaction:
			print("Phone: Bad ending trigger enabled, starting bad ending...")
			_trigger_bad_ending()

func _trigger_bad_ending() -> void:
	"""Trigger the bad ending sequence after phone conversation"""
	print("Phone: Triggering bad ending sequence...")
	
	# Wait a moment for any final dialogue to settle
	await get_tree().create_timer(1.0).timeout
	
	print("Phone: Changing to bad ending scene...")
	# Change to bad ending scene
	get_tree().change_scene_to_file("res://scenes/endings/bad_ending.tscn")

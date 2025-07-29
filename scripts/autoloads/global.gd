extends Node

var is_game_paused: bool = false
var can_pause: bool = true

# NEW: Simplified spawn system
var target_spawn_name: String = ""
var current_scene_path: String = ""
var textbox
var player_node: Node3D = null # Store reference to player

# Environment system time tracking
var clock_float: float = 0.0

# Piece collection system
var piece_count: int = 0
var collected_pieces: Dictionary = {} # Format: {"room_name": [piece_id1, piece_id2, ...]}

# Global data resource
var global_data: Resource

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load global data resource
	global_data = load("res://resource/management/global_data.tres")
	if not global_data:
		print("ERROR: Could not load global_data.tres")
		# Create fallback data by loading the script and creating an instance
		var global_data_script = load("res://scripts/resources/global_data.gd")
		global_data = global_data_script.new()
		global_data.gen = 8
	
	textbox = load("res://scenes/management/control.tscn")
	current_scene_path = get_tree().current_scene.scene_file_path

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Update global time for environment effects
	clock_float += delta
	
func create_Textbox(textboxText: PackedStringArray, parent: Node):
	var newTextbox = textbox.instantiate()
	newTextbox.get_child(0).get_child(0).textboxes = textboxText
	parent.add_child(newTextbox)
	pass

# NEW: Simplified scene change with PackedScene
func change_scene_to_packed(packed_scene: PackedScene) -> void:
	print("Changing scene to: ", packed_scene.resource_path)
	
	# Store reference to player before scene change
	player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		# Remove player from current scene tree but don't free it
		player_node.get_parent().remove_child(player_node)
		print("Player removed from scene tree for transfer")
	
	# Optional: Add fade effect here
	EventBus.scene_transition_started.emit()
	
	# Change scene
	var result = get_tree().change_scene_to_packed(packed_scene)
	print("Scene change result: ", result)
	
	if result != OK:
		print("ERROR: Failed to change scene to ", packed_scene.resource_path)
		return
	
	# Wait for scene to be ready and add player
	call_deferred("_add_player_to_new_scene")
	
	# Update current scene
	current_scene_path = packed_scene.resource_path
	print("Scene changed successfully to: ", current_scene_path)
	
	EventBus.scene_transition_finished.emit()

# NEW: Simplified scene change with file path (avoids circular dependencies)
func change_scene_to_file(scene_path: String) -> void:
	print("Changing scene to: ", scene_path)
	
	# Store reference to player before scene change
	player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		# Remove player from current scene tree but don't free it
		player_node.get_parent().remove_child(player_node)
		print("Player removed from scene tree for transfer")
	
	# Optional: Add fade effect here
	EventBus.scene_transition_started.emit()
	
	# Change scene
	var result = get_tree().change_scene_to_file(scene_path)
	print("Scene change result: ", result)
	
	if result != OK:
		print("ERROR: Failed to change scene to ", scene_path)
		return
	
	# Wait for scene to be ready and add player
	call_deferred("_add_player_to_new_scene")
	
	# Update current scene
	current_scene_path = scene_path
	print("Scene changed successfully to: ", current_scene_path)
	
	EventBus.scene_transition_finished.emit()

func _add_player_to_new_scene() -> void:
	# Wait a bit more to ensure scene is fully loaded
	await get_tree().create_timer(0.1).timeout
	
	print("Attempting to add player to new scene")
	if player_node and get_tree().current_scene:
		get_tree().current_scene.add_child(player_node)
		print("Player added to new scene")
		
		# Player spawning is now handled by spawn points themselves
		player_node = null # Clear reference after adding
	else:
		if not player_node:
			print("ERROR: No player node to add")
		if not get_tree().current_scene:
			print("ERROR: Current scene is null")

# Piece collection functions
func collect_piece(room_name: String, piece_id: int) -> bool:
	"""Collect a piece and return true if it was newly collected, false if already collected"""
	# Check if already collected
	if is_piece_collected(room_name, piece_id):
		return false
	
	# Add to collection
	if not collected_pieces.has(room_name):
		collected_pieces[room_name] = []
	
	collected_pieces[room_name].append(piece_id)
	piece_count += 1
	
	print("Piece collected! Room: ", room_name, " ID: ", piece_id, " Total: ", piece_count)
	
	# Emit signal for UI updates
	EventBus.piece_collected.emit(piece_count)
	
	return true

func is_piece_collected(room_name: String, piece_id: int) -> bool:
	"""Check if a specific piece has been collected"""
	if not collected_pieces.has(room_name):
		return false
	return piece_id in collected_pieces[room_name]

func get_piece_count() -> int:
	"""Get total number of collected pieces"""
	return piece_count

func reset_pieces() -> void:
	"""Reset all piece collection data"""
	piece_count = 0
	collected_pieces.clear()
	print("All pieces reset")

extends Node

# Player spawn info: [previous_scene, warp_id]
var player_spawn_info: Array = []
var current_scene_path: String = ""
var textbox
var player_node: Node3D = null # Store reference to player
var global_data: GlobalData = preload("res://resource/management/global_data.tres")

# Environment system time tracking
var clock_float: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	textbox = load("res://scenes/control.tscn")
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

# Simplified warp function
func warp_to(scene_path: String, spawn_warp_id: int = 0) -> void:
	print("Warping to: ", scene_path, " with spawn ID: ", spawn_warp_id)
	
	# Store spawn information
	player_spawn_info = [current_scene_path, spawn_warp_id]
	
	# Defer the scene change to avoid physics callback issues
	call_deferred("_deferred_warp", scene_path)

func _deferred_warp(scene_path: String) -> void:
	print("Starting deferred warp to: ", scene_path)
	
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
	call_deferred("_add_player_to_scene")
	
	# Update current scene
	current_scene_path = scene_path
	print("Scene changed successfully to: ", current_scene_path)
	
	EventBus.scene_transition_finished.emit()

func _add_player_to_scene() -> void:
	# Wait a bit more to ensure scene is fully loaded
	await get_tree().create_timer(0.1).timeout
	
	print("Attempting to add player to new scene")
	if player_node and get_tree().current_scene:
		get_tree().current_scene.add_child(player_node)
		print("Player added to new scene")
		
		# Now that player is in the scene, trigger spawn positioning
		await get_tree().process_frame # Wait one frame for player to be fully ready
		_handle_player_spawning()
		
		player_node = null # Clear reference after adding
	else:
		if not player_node:
			print("ERROR: No player node to add")
		if not get_tree().current_scene:
			print("ERROR: Current scene is null")

func _handle_player_spawning() -> void:
	print("Handling player spawning...")
	if player_spawn_info.size() >= 2:
		var target_spawn_id = player_spawn_info[1]
		print("Looking for spawn point with ID: ", target_spawn_id)
		
		# Find the correct spawn point
		var spawn_points = get_tree().get_nodes_in_group("spawn")
		var spawn_found = false
		for spawn in spawn_points:
			if spawn.has_method("get") and spawn.warp_id == target_spawn_id:
				print("Found matching spawn point, positioning player")
				var player = get_tree().get_first_node_in_group("player")
				if player:
					player.global_position = spawn.global_position
					if player.has_method("set_direction"):
						player.set_direction(spawn.player_direction)
					print("Player positioned at spawn point: ", target_spawn_id)
					player_spawn_info.clear()
					spawn_found = true
					break
		
		if not spawn_found:
			print("ERROR: No spawn point found with ID: ", target_spawn_id)
	else:
		print("No spawn info available for positioning")

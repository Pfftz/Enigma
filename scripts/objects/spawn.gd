@tool
@icon("res://icon/spawn.png")
extends Marker3D
class_name SpawnClass

@export_file("*.tscn") var scene_path: String
@export var warp_id: int = 0
@export_range(0, 4) var player_direction: int = 0
@export var place_camera: bool = false
@export var place_camera_at: Vector3

func _ready() -> void:
	add_to_group("spawn")
	
	# Note: Player spawning is now handled by Global._handle_player_spawning()
	# This prevents timing issues with scene transitions

func check_spawn() -> void:
	print("Spawn check - warp_id: ", warp_id)
	print("Global spawn info: ", Global.player_spawn_info)
	
	# Check if player should spawn at this point
	if Global.player_spawn_info.size() >= 2:
		var target_spawn_id = Global.player_spawn_info[1]
		print("Target spawn ID: ", target_spawn_id, " - This spawn ID: ", warp_id)
		if target_spawn_id == warp_id:
			spawn_player_here()
		else:
			print("Spawn ID mismatch - not spawning here")
	else:
		print("No spawn info available")

func spawn_player_here() -> void:
	print("Attempting to spawn player at spawn point: ", warp_id)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		print("Found player, setting position to: ", global_position)
		player.global_position = global_position
		if player.has_method("set_direction"):
			player.set_direction(player_direction)
		print("Player spawned at spawn point: ", warp_id)
		
		# Clear spawn info after spawning
		Global.player_spawn_info.clear()
	else:
		print("ERROR: No player found in 'player' group!")

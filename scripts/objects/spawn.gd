@tool
@icon("res://icon/spawn.png")
extends Marker3D
class_name SpawnClass

## Simple spawn point - player appears here when warping to this scene

enum Direction {
	UP = 0,
	RIGHT = 1,
	DOWN = 2,
	LEFT = 3
}

@export var spawn_name: String = "" ## Unique name for this spawn point (leave empty to be default spawn)
@export var player_direction: Direction = Direction.DOWN ## Direction player faces when spawning

func _ready() -> void:
	add_to_group("spawn")
	
	# Auto-assign name if empty
	if spawn_name == "":
		spawn_name = "default"
	
	# Check if we should spawn player here
	call_deferred("_check_spawn")

func _check_spawn() -> void:
	# Check if this is the target spawn point
	var target_name = Global.target_spawn_name
	print("Spawn check - target: '", target_name, "', this spawn: '", spawn_name, "'")
	if target_name == "" or target_name == spawn_name:
		_spawn_player_here()

func _spawn_player_here() -> void:
	print("Spawning player at: '", spawn_name, "'")
	var player = get_tree().get_first_node_in_group("player")
	if player:
		print("Found player, current position: ", player.global_position)
		print("Setting position to spawn: ", global_position)
		
		# Use a small delay to ensure player is fully added to scene
		await get_tree().process_frame
		player.global_position = global_position
		
		# Ensure player is on ground level
		if player.has_method("move_and_slide"):
			player.move_and_slide()
		
		# Set player direction if the method exists
		if player.has_method("set_direction"):
			player.set_direction(int(player_direction))
		
		print("Player spawned successfully at: ", player.global_position)
		print("Player direction set to: ", Direction.keys()[player_direction])
		
		# Clear spawn info
		Global.target_spawn_name = ""
	else:
		print("ERROR: No player found in 'player' group!")
		# Try again after a short delay
		await get_tree().create_timer(0.1).timeout
		_spawn_player_here()

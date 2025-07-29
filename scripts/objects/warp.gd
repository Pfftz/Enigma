extends Area3D
class_name Warp

## Simple warp system - just enter collision to teleport

@export_file("*.tscn") var target_scene_path: String ## Path to target scene (use Quick Open)
@export var target_spawn_name: String = "" ## Name of spawn point in target scene (leave empty for first spawn)

var is_ready: bool = false
var player_in_area: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Small delay to prevent instant teleport on scene load
	await get_tree().create_timer(0.2).timeout
	is_ready = true

func _on_body_entered(body: Node3D) -> void:
	if not is_ready or target_scene_path == "":
		return
	
	if body.is_in_group("player"):
		player_in_area = true
		print("Player entered warp area")
		# Small delay to ensure clean entry
		await get_tree().create_timer(0.1).timeout
		if player_in_area: # Check if player is still in area
			_trigger_warp()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		print("Player exited warp area")

func _trigger_warp() -> void:
	if target_scene_path == "":
		print("Error: No target scene set for warp!")
		return
		
	print("Warping to: ", target_scene_path)
	
	# Store spawn info for target scene
	Global.target_spawn_name = target_spawn_name
	
	# Change scene using file path
	Global.change_scene_to_file(target_scene_path)

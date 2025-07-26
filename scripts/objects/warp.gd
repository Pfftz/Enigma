extends Area3D
class_name Warp

@export var target_scene: String = "" # Scene to warp to
@export var warp_id: int = 0 # This warp's ID
@export var spawn_warp_id: int = 0 # Which spawn point to use in target scene
@export var warp_direction: int = 0 # 0=Up, 1=Right, 2=Down, 3=Left
@export var all_directions: bool = false # Accept any direction

var is_ready: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	# Small delay to prevent instant teleport
	await get_tree().create_timer(0.1).timeout
	is_ready = true

func _on_body_entered(body: Node3D) -> void:
	if !is_ready or target_scene == "":
		return
	
	if body.has_method("get_current_direction"): # Check if it's player
		var player_direction = body.get_current_direction()
		
		# Check if player is moving in correct direction
		if all_directions or player_direction == warp_direction:
			print("Warp triggered! Going to: ", target_scene)
			EventBus.warp_triggered.emit(warp_id, target_scene)
			Global.warp_to(target_scene, spawn_warp_id)

# Helper function to get direction name for debugging
func get_direction_name() -> String:
	var directions = ["Up", "Right", "Down", "Left"]
	return directions[warp_direction]

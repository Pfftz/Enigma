extends Marker3D

signal in_area(inside: bool)
signal triggered

#ANIMATION VARIABLES
const HEIGHT_LIMIT: float = 0.65
const HEIGHT_ANIM_SPEED: float = 0.65
const ROTATION_LIMIT: float = 0.25
const ROTATION_ANIM_SPEED: float = 1.5
const GROW_ANIMATION_SPEED: float = 0.25

@export var enabled: bool = false
@export var height_offset: float = 1.5
@export var min_distance: float = 2.5
var original_position: float = 0.0
var player_inside_zone: bool = false
var is_deactivated: bool = false

@onready var interaction_mesh = $Height/MeshOrigin/InteractionMesh
@onready var height = $Height
@onready var mesh_origin = $Height/MeshOrigin
@onready var interaction_sound = $InteractionSound
@onready var interaction_area = $InteractionArea


func _ready() -> void:
	await get_tree().process_frame
	
	$InteractionArea/InteractionCollision.get_shape().radius = min_distance
	
	interaction_mesh.scale = Vector3.ZERO
	height.position.y = height_offset
	original_position = interaction_mesh.position.y
	
	animate()
	
	if Global.global_data.gen <= 2:
		queue_free()

	# Check if this interaction symbol should be disabled based on game state
	# This is specifically for laptop interactions that should be limited per day
	if should_be_disabled():
		enabled = false
		visible = false
		queue_free()
		return
	
	# Connect to GameState signal to disable when interview is completed
	if is_laptop_interaction_symbol():
		GameState.interview_completed.connect(_on_interview_completed)
	
	enabled = true


func should_be_disabled() -> bool:
	# Check if this is a laptop interaction symbol that should be disabled
	# Look for a parent laptop interaction area
	var parent_node = get_parent()
	if parent_node:
		var laptop_interaction = parent_node.find_child("interact laptop", false, false)
		if laptop_interaction:
			# This is a laptop interaction symbol, check if interview is completed
			return GameState.is_interview_completed(GameState.current_day) or GameState.current_day == 5
	return false

func is_laptop_interaction_symbol() -> bool:
	# Check if this interaction symbol is for a laptop interaction
	var parent_node = get_parent()
	if parent_node:
		var laptop_interaction = parent_node.find_child("interact laptop", false, false)
		return laptop_interaction != null
	return false

func _on_interview_completed(day: int) -> void:
	# If this is the current day's interview completion and this is a laptop symbol, disable it
	if day == GameState.current_day and is_laptop_interaction_symbol():
		enabled = false
		visible = false
		queue_free()


func animate() -> void:
	var tweener_symbol: Tween = create_tween().set_loops()
	
	tweener_symbol.tween_property(
									interaction_mesh,
									"position:y",
									original_position + randf_range(
																		original_position,
																		HEIGHT_LIMIT
																	),
									HEIGHT_ANIM_SPEED
								).set_trans(Tween.TRANS_SINE)
	tweener_symbol.tween_property(
									interaction_mesh,
									"position:y",
									original_position - randf_range(
																		original_position,
																		HEIGHT_LIMIT
																	),
									HEIGHT_ANIM_SPEED
								).set_trans(Tween.TRANS_SINE)
	
	
	var tweener: Tween = create_tween().set_loops()
	
	tweener.tween_property(
								interaction_mesh,
								"rotation:z",
								ROTATION_LIMIT * -1,
								ROTATION_ANIM_SPEED
							).set_trans(Tween.TRANS_SINE)
	tweener.tween_property(
								interaction_mesh,
								"rotation:z",
								ROTATION_LIMIT,
								ROTATION_ANIM_SPEED
							).set_trans(Tween.TRANS_SINE)


func _process(_delta: float) -> void:
	# Don't process input if this should be disabled
	if should_be_disabled():
		return
		
	if (
			Input.is_action_just_pressed("interact") and
			player_inside_zone
		):
		triggered.emit()


func _on_interaction_area_entered(body: Node3D) -> void:
	# Don't show interaction if this should be disabled
	if should_be_disabled():
		return
		
	if body is CharacterBody3D && enabled:
		if interaction_sound and is_instance_valid(interaction_sound):
			interaction_sound.play()
		in_area.emit(true)
		player_inside_zone = true
		if interaction_mesh and is_instance_valid(interaction_mesh):
			create_tween().tween_property(
											interaction_mesh,
											"scale",
											Vector3(1., 1., 1.),
											GROW_ANIMATION_SPEED
										)


func _on_interaction_area_exited(body: Node3D) -> void:
	if body is CharacterBody3D and not is_deactivated:
		_disable()


func _disable() -> void:
	if interaction_sound and is_instance_valid(interaction_sound):
		interaction_sound.play()
	player_inside_zone = false
	in_area.emit(false)
	if interaction_mesh and is_instance_valid(interaction_mesh):
		create_tween().tween_property(
									interaction_mesh,
									"scale",
									Vector3.ZERO,
									GROW_ANIMATION_SPEED
								)


func deactivate() -> void:
	if is_deactivated:
		return
		
	is_deactivated = true
	enabled = false
	if interaction_area and is_instance_valid(interaction_area):
		interaction_area.queue_free()
	_disable()

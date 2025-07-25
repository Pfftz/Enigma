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

	enabled = true


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
	if (
			Input.is_action_just_pressed("pressed_action") and
			player_inside_zone
		):
		triggered.emit()


func _on_interaction_area_entered(body: Node3D) -> void:
	if body is CharacterBody3D && enabled:
		interaction_sound.play()
		in_area.emit(true)
		player_inside_zone = true
		create_tween().tween_property(
										interaction_mesh,
										"scale",
										Vector3(1., 1., 1.),
										GROW_ANIMATION_SPEED
									)


func _on_interaction_area_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		_disable()


func _disable() -> void:
	interaction_sound.play()
	player_inside_zone = false
	in_area.emit(false)
	create_tween().tween_property(
								interaction_mesh,
								"scale",
								Vector3.ZERO,
								GROW_ANIMATION_SPEED
							)


func deactivate() -> void:
	interaction_area.queue_free()
	_disable()

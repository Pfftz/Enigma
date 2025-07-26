extends Resource
class_name PlayerStats

@export var character_id: int = 0
@export var input_enabled: bool = true
@export var player_position: Vector3 = Vector3.ZERO
@export var current_level: int = 0
@export var health: int = 100
@export var experience: int = 0
@export var piece_amount: int = 0 # For piece collection system
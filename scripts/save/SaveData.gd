extends Resource
class_name SaveData

# Basic save data - customize for your game
@export var save_seed: int = 0
@export var player_data: PlayerStats = PlayerStats.new()
@export var save_name: String = ""
@export var current_scene: String = ""
@export var player_position: Vector3 = Vector3.ZERO

# Game-specific data
@export var level_progress: int = 0
@export var collected_items: Array[String] = []
@export var unlocked_areas: Array[String] = []
@export var inventory: Dictionary = {}

# Settings
@export var volume_master: float = 1.0
@export var volume_sfx: float = 1.0
@export var volume_music: float = 1.0

# Piece collection system (for Petscop-like functionality)
@export var piece_log: Dictionary = {} ## A log of collected pieces per room
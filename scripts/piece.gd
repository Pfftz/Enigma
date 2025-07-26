@tool
@icon("res://icon/piece.png")
extends Area3D
class_name Piece

const PIECE_SEED: int = 26
const ANIM_SPEED: int = 10
const HOR_SPEED: int = 5
const VER_SPEED: int = 5

var current_frame: int = 0
var collected: bool = false
var room_name: String = ""
var type_array: Array[int] = [
								0, 1, 2, 3, 4,
								4, 0, 2, 1, 3,
								4, 2, 3, 1, 0,
								2, 3, 1, 4, 0,
								1, 4, 3, 0, 2,
								1, 0, 3, 2, 4,
								2, 3, 1, 0, 4,
								2, 1, 0, 3, 4,
								3, 1, 0, 4, 2,
								1, 0, 4, 2, 3
							]

@onready var piece_id: int = 0 # Will be set in _ready()
@onready var piece_sprite = $PieceSprite
@onready var piece_collision = $PieceCollision
@onready var piece_sound = $PieceSound


func _ready() -> void:
	add_to_group("piece") # Add to piece group
	
	# Connect the body_entered signal
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	if !Engine.is_editor_hint():
		# Set piece_id after being added to group
		piece_id = get_tree().get_nodes_in_group("piece").find(self)
		
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		
		rng.set_seed(PIECE_SEED)
		
		# Get room name from current scene
		var current_scene = get_tree().get_current_scene()
		if current_scene.has_method("get_room_name"):
			room_name = current_scene.get_room_name()
		else:
			# Fallback: use scene filename
			room_name = get_tree().current_scene.scene_file_path.get_file().get_basename()
		
		# Check generation requirements (simplified for now)
		if Global.global_data.gen < 3:
			queue_free()
			return
		
		# Set piece type based on array or random
		if piece_id < type_array.size() and type_array[piece_id] != null:
			piece_sprite.frame_coords.y = type_array[piece_id]
		else:
			piece_sprite.frame_coords.y = rng.randi_range(0, 4)
		
		# Check if already collected
		if SaveManager.get_data().piece_log.has(room_name):
			if SaveManager.get_data().piece_log[room_name].find(piece_id) != -1:
				self.queue_free()
				return
		
		# Character-specific logic
		if SaveManager.get_data().player_data.character_id == 2:
			self.queue_free()
			return


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if type_array[get_tree().get_nodes_in_group("piece").find(self)] != null:
			$PieceSprite.frame_coords.y = type_array[get_tree().get_nodes_in_group("piece").find(self)]
		else:
			$PieceSprite.frame_coords.y = 0


func _on_body_entered(body: Node3D) -> void:
	if !Engine.is_editor_hint():
		# Check if it's the player (check for player group or specific class)
		if body.is_in_group("player") or body.name.to_lower().contains("player"):
			piece_sound.play()
			
			# Log the collected piece
			if SaveManager.get_data().piece_log.has(room_name):
				SaveManager.get_data().piece_log[room_name].push_back(piece_id)
			elif room_name != "" and room_name.rstrip(" ") != "":
				SaveManager.get_data().piece_log[room_name] = [piece_id]
			
			# Increase piece count
			SaveManager.get_data().player_data.piece_amount += 1
			
			# Emit signal for piece collection
			EventBus.piece_collected.emit(SaveManager.get_data().player_data.piece_amount)
			
			# Find HUD - now it's a child of the player
			var player = get_tree().get_first_node_in_group("player")
			var hud_node = null
			if player:
				hud_node = player.get_node_or_null("HUD")
			
			# Update HUD if found
			if hud_node and hud_node.has_method("update_counter"):
				hud_node.update_counter()
			if hud_node and hud_node.has_method("show_counter"):
				hud_node.show_counter()
			
			# Disable collision
			piece_collision.queue_free()
			
			# Play collection animation
			var _collected_anim: Tween = create_tween()
			_collected_anim.tween_property(self, "position", Vector3(0., 10., 10.), 2.).as_relative()
			
			await _collected_anim.finished
			
			visible = false

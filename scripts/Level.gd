extends Node
class_name Level

enum HardcodedProperties {
	NONE,
	EVEN_CARE,
	OTHER
}

@export var room_name: String = ""
@export var hardcoded_properties: HardcodedProperties = HardcodedProperties.NONE
@export var odd_care_room_on_gen_3: bool = false

func _ready():
	# Set default room name based on scene file if not set
	if room_name == "":
		var scene_path = get_tree().current_scene.scene_file_path
		room_name = scene_path.get_file().get_basename()

	setup_room_textures()

func setup_room_textures():
	# Find all textured objects
	var textured_objects = get_tree().get_nodes_in_group("textured")
	
	for obj in textured_objects:
		if obj.has_method("apply_texture"):
			obj.apply_texture("res://textures/room_texture.png")

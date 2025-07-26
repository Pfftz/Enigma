extends Node3D
class_name LevelEnvironmentManager

## Manages environmental effects for a level including fog, lighting, and moving backgrounds

const EnvironmentResource = preload("res://scripts/EnvironmentResource.gd")

@export var environment_settings: EnvironmentResource ## Environment configuration for this level
@export var fog_follow_target: Node3D ## Node that fog should follow (usually the player)

# Internal references
var world_environment: WorldEnvironment
var directional_light: DirectionalLight3D
var fog_focus_position: Vector3 = Vector3.ZERO

func _ready():
	# Initialize the environment system
	setup_world_environment()
	setup_fog_system()
	setup_lighting()
	setup_moving_background()
	
	# If no fog target is set, try to find the player
	if not fog_follow_target and environment_settings and environment_settings.fog_follow_player:
		fog_follow_target = get_tree().get_first_node_in_group("player")

func _process(_delta):
	# Update global time for moving backgrounds
	if environment_settings and environment_settings.sky_texture:
		# Use Global.clock_float directly since it's a public variable
		var current_time = Global.clock_float
		RenderingServer.global_shader_parameter_set("float_time", current_time)
	
	# Update fog position if following a target
	if environment_settings and environment_settings.enable_fog and fog_follow_target:
		update_fog_position()

func setup_world_environment():
	"""Create and configure the WorldEnvironment node"""
	world_environment = WorldEnvironment.new()
	world_environment.environment = Environment.new()
	add_child(world_environment)
	
	if not environment_settings:
		print("Warning: No environment settings found for level")
		return
	
	var env = world_environment.environment
	
	# Set ambient lighting
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = environment_settings.ambient_color
	env.ambient_light_energy = environment_settings.environment_darkness
	
	# Configure background
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()

func setup_fog_system():
	"""Initialize the fog system using global shader parameters"""
	if not environment_settings:
		return
		
	if environment_settings.enable_fog:
		print("Enabling fog system - Color: ", environment_settings.fog_color, " Radius: ", environment_settings.fog_radius)
		RenderingServer.global_shader_parameter_set("fog_enabled", true)
		RenderingServer.global_shader_parameter_set("fog_color", environment_settings.fog_color)
		RenderingServer.global_shader_parameter_set("fog_size", environment_settings.fog_radius)
		
		# Set initial fog position
		if fog_follow_target:
			fog_focus_position = fog_follow_target.global_position
		RenderingServer.global_shader_parameter_set("fog_pos", fog_focus_position)
	else:
		print("Disabling fog system")
		RenderingServer.global_shader_parameter_set("fog_enabled", false)

func setup_lighting():
	"""Setup additional lighting if enabled"""
	if not environment_settings or not environment_settings.enable_directional_light:
		return
		
	directional_light = DirectionalLight3D.new()
	directional_light.light_color = environment_settings.light_color
	directional_light.light_energy = environment_settings.light_energy
	directional_light.position = environment_settings.light_direction.normalized() * -10
	directional_light.look_at(Vector3.ZERO, Vector3.UP)
	add_child(directional_light)

func setup_moving_background():
	"""Setup animated sky background"""
	if not environment_settings or not world_environment:
		return
		
	var sky_material = ShaderMaterial.new()
	sky_material.shader = load("res://shaders/sky_animated.gdshader")
	
	if environment_settings.sky_texture:
		# Use animated texture background
		sky_material.set_shader_parameter("use_texture", true)
		sky_material.set_shader_parameter("sky_texture", environment_settings.sky_texture)
		sky_material.set_shader_parameter("scroll_speed", environment_settings.scroll_speed)
		sky_material.set_shader_parameter("offset_y", environment_settings.offset_y)
		sky_material.set_shader_parameter("texture_size", Vector2(
			environment_settings.sky_texture.get_width(),
			environment_settings.sky_texture.get_height()
		))
	else:
		# Use solid color background
		sky_material.set_shader_parameter("use_texture", false)
		sky_material.set_shader_parameter("sky_color", environment_settings.sky_color)
	
	world_environment.environment.sky.sky_material = sky_material

func update_fog_position():
	"""Update fog position to follow the target"""
	if fog_follow_target and environment_settings.fog_follow_player:
		fog_focus_position = fog_follow_target.global_position
		RenderingServer.global_shader_parameter_set("fog_pos", fog_focus_position)

# Public methods for runtime control
func set_fog_enabled(enabled: bool):
	"""Enable or disable fog at runtime"""
	if environment_settings:
		environment_settings.enable_fog = enabled
		RenderingServer.global_shader_parameter_set("fog_enabled", enabled)

func set_fog_color(color: Color):
	"""Change fog color at runtime"""
	if environment_settings:
		environment_settings.fog_color = color
		RenderingServer.global_shader_parameter_set("fog_color", color)

func set_fog_radius(radius: float):
	"""Change fog radius at runtime"""
	if environment_settings:
		environment_settings.fog_radius = radius
		RenderingServer.global_shader_parameter_set("fog_size", radius)

func set_background_scroll_speed(speed: float):
	"""Change background scroll speed at runtime"""
	if environment_settings and world_environment and world_environment.environment.sky:
		environment_settings.scroll_speed = speed
		var sky_mat = world_environment.environment.sky.sky_material as ShaderMaterial
		if sky_mat:
			sky_mat.set_shader_parameter("scroll_speed", speed)

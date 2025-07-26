extends Resource
class_name EnvironmentResource

## Resource for managing room environments including fog, lighting, and moving backgrounds

@export_category("Sky & Background Properties")
@export var sky_color: Color = Color(0.5, 0.7, 1.0, 1.0) ## Color of the sky when no texture is used
@export var sky_texture: Texture2D ## Texture for animated sky background
@export var scroll_speed: float = 0.2 ## Speed of background scrolling animation
@export var offset_y: float = 0.0 ## Vertical offset for background texture

@export_category("Ambient Lighting")
@export var ambient_color: Color = Color(1.0, 1.0, 1.0, 1.0) ## Ambient light color
@export var environment_darkness: float = 1.0 ## Overall brightness multiplier (0.0 = dark, 1.0 = normal)

@export_category("Fog System")
@export var enable_fog: bool = false ## Enable/disable fog for this environment
@export var fog_color: Color = Color(0.8, 0.8, 0.9, 1.0) ## Color of the fog
@export var fog_radius: float = 15.0 ## Distance at which fog becomes fully opaque
@export var fog_follow_player: bool = true ## Whether fog should follow the player or stay at world origin

@export_category("Additional Effects")
@export var enable_directional_light: bool = false ## Add a directional light source
@export var light_direction: Vector3 = Vector3(-0.5, -1.0, -0.5) ## Direction of the light
@export var light_color: Color = Color(1.0, 0.95, 0.8, 1.0) ## Color of the directional light
@export var light_energy: float = 1.0 ## Strength of the directional light

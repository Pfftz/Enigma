extends MeshInstance3D
class_name TextureApplier

@export var texture_path: String = ""
@export var use_psx_shader: bool = true
@export var uv_scale: Vector2 = Vector2.ONE
@export var modulate_color: Color = Color.WHITE

func _ready():
    setup_material()
    if texture_path != "":
        apply_texture(texture_path)

func setup_material():
    var material = ShaderMaterial.new()
    
    if use_psx_shader:
        material.shader = load("res://shaders/psx_base.gdshader")
    
    # Set default parameters
    material.set_shader_parameter("uv_scale", uv_scale)
    material.set_shader_parameter("modulate_color", modulate_color)
    
    set_surface_override_material(0, material)

func apply_texture(path: String):
    var texture = load(path) as Texture2D
    if texture:
        var material = get_surface_override_material(0) as ShaderMaterial
        material.set_shader_parameter("albedo_texture", texture)
        print("Texture applied: ", path)
    else:
        print("Failed to load texture: ", path)

func change_texture(new_texture: Texture2D):
    var material = get_surface_override_material(0) as ShaderMaterial
    material.set_shader_parameter("albedo_texture", new_texture)
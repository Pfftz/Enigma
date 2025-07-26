shader_type spatial;
render_mode shadows_disabled, specular_disabled, depth_draw_opaque, unshaded;

// Global uniforms for consistency
global uniform float precision_multiplier : hint_range(0.0, 1.0) = 1.0;
global uniform bool fog_enabled = false;
global uniform vec3 fog_color = vec3(0.5, 0.5, 0.5);
global uniform float fog_size = 10.0;
global uniform vec3 fog_pos = vec3(0.0, 0.0, 0.0);

// Material properties
uniform vec4 modulate_color : source_color = vec4(1.0);
uniform sampler2D albedo_texture : source_color, filter_nearest, repeat_enable;
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(0.0, 0.0);

// PSX vertex snapping resolution
const vec2 snap_resolution = vec2(160.0, 120.0);

varying float fog_amount;

// Snap vertices to low-resolution grid (main PSX effect)
vec4 snap_to_grid(vec4 vertex_pos) {
    vec4 snapped = vertex_pos;
    snapped.xyz = vertex_pos.xyz / vertex_pos.w; // Convert to NDC
    
    vec2 snap_res = floor(snap_resolution * precision_multiplier);
    snapped.x = floor(snap_res.x * snapped.x) / snap_res.x;
    snapped.y = floor(snap_res.y * snapped.y) / snap_res.y;
    
    snapped.xyz *= vertex_pos.w; // Convert back
    return snapped;
}

void vertex() {
    // Apply UV transformations
    UV = UV * uv_scale + uv_offset;
    
    // Calculate fog if enabled
    if (fog_enabled) {
        vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
        fog_amount = length(world_pos - fog_pos) / fog_size;
        fog_amount = clamp(fog_amount, 0.0, 1.0);
    }
    
    // Apply PSX vertex snapping
    POSITION = snap_to_grid(PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
    POSITION /= abs(POSITION.w); // Affine texture mapping
}

void fragment() {
    // Sample texture
    vec4 texture_color = texture(albedo_texture, UV);
    
    // Apply vertex color and modulation
    vec4 final_color = texture_color * COLOR * modulate_color;
    
    // Apply fog if enabled
    if (fog_enabled) {
        final_color.rgb = mix(final_color.rgb, fog_color, fog_amount);
    }
    
    ALBEDO = final_color.rgb;
    ALPHA = final_color.a;
}
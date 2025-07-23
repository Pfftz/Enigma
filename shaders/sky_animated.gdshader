shader_type sky;

// Global time for animation
global uniform float float_time;

// Sky texture properties
uniform bool use_texture : hint_default(false) = false;
uniform sampler2D sky_texture : source_color, filter_nearest, repeat_enable;
uniform vec2 texture_size = vec2(320.0, 240.0);
uniform float scroll_speed : hint_range(-2.0, 2.0) = 0.25;
uniform float offset_y : hint_range(-1.0, 1.0) = 0.0;

// Solid color fallback
uniform vec4 sky_color : source_color = vec4(0.5, 0.7, 1.0, 1.0);

void sky() {
	if (use_texture && texture_size.x > 0.0 && texture_size.y > 0.0) {
		// Calculate UV coordinates for scrolling texture
		vec2 screen_size = vec2(320.0, 240.0); // PSX resolution
		vec2 uv = SCREEN_UV;
		
		// Add scrolling animation
		uv.x += float_time * scroll_speed;
		uv.y += offset_y;
		
		// Scale UV to texture size ratio
		uv *= screen_size / texture_size;
		
		// Sample the texture
		COLOR = texture(sky_texture, uv).rgb;
	} else {
		// Use solid color
		COLOR = sky_color.rgb;
	}
}

shader_type spatial;
render_mode skip_vertex_transform;

uniform sampler2D color_texture : filter_nearest;

uniform vec3 tint : source_color = vec3(1);
uniform vec2 fog_start_end = vec2(10, 100);
uniform vec3 fog_color : source_color = vec3(0.42, 0.42, 0.45);

varying vec4 clip_pos;
varying float view_distance;

void vertex() {
	vec4 world_space = MODEL_MATRIX * vec4(VERTEX, 1);
	
	vec4 clip = PROJECTION_MATRIX * VIEW_MATRIX * world_space;
	
	// Snap to nearest pixel
	vec4 vertex = clip;
	vertex.xy = round(clip.xy / clip.w * VIEWPORT_SIZE.xy) / VIEWPORT_SIZE.xy * clip.w;
	
	POSITION = vertex;
	
	// Need to hold on to clip.w
	clip_pos = vertex;
	
	// Calculate vertex distance from camera
	view_distance = length(CAMERA_POSITION_WORLD - world_space.xyz);
	
	//UV = UV * vec2(3.0, 2.0)
	UV = UV * clip_pos.w;
	NORMAL = MODEL_NORMAL_MATRIX * NORMAL;
}

void fragment() {
	// Calculate linear fog factor
	float fog_factor = (fog_start_end.y - view_distance) / (fog_start_end.y - fog_start_end.x);
	fog_factor = 1.0 - clamp(fog_factor, 0.0, 1.0);
	
	vec3 texture_color = texture(color_texture, (UV / clip_pos.w) * 10.0).rgb * tint;
	
	ALBEDO = mix(texture_color, fog_color, fog_factor);
	//ALBEDO = pow(ALBEDO, vec3(2.2));
	
	//ALBEDO = vec3(fog_factor);
	
	//ALBEDO = NORMAL.xyz;
}

void light() {
	DIFFUSE_LIGHT = vec3(dot(NORMAL, normalize(vec3(1, 1, 0))));
	DIFFUSE_LIGHT = vec3(1);
}

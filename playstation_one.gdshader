shader_type spatial;
render_mode skip_vertex_transform;

uniform sampler2D color_texture : filter_nearest;

varying vec4 clip_pos;

void vertex() {
	vec4 clip = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1);
	vec4 vertex = clip;
	//vertex.xy = round(clip.xy / clip.w * VIEWPORT_SIZE.xy) / VIEWPORT_SIZE.xy * clip.w;
	
	POSITION = vertex;
	clip_pos = vertex;
	
	//UV = UV * vec2(3.0, 2.0)
	UV = UV * 10.0 * clip_pos.w;
}

void fragment() {
	ALBEDO = pow(texture(color_texture, UV / clip_pos.w).rgb, vec3(2.2));
}

void light() {
	 DIFFUSE_LIGHT = vec3(1.0);
}

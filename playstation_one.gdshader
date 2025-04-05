shader_type spatial;
render_mode skip_vertex_transform;

uniform sampler2D color_texture : filter_nearest;

uniform vec3 tint : source_color = vec3(1);

varying vec4 clip_pos;

void vertex() {
	vec4 clip = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1);
	vec4 vertex = clip;
	vertex.xy = round(clip.xy / clip.w * VIEWPORT_SIZE.xy) / VIEWPORT_SIZE.xy * clip.w;
	
	POSITION = vertex;
	clip_pos = vertex;
	
	//UV = UV * vec2(3.0, 2.0)
	UV = UV * clip_pos.w;
	NORMAL = MODEL_NORMAL_MATRIX * NORMAL;
}

void fragment() {
	ALBEDO = pow(texture(color_texture, (UV / clip_pos.w) * 10.0).rgb, vec3(2.2));
	ALBEDO *= tint;
	//ALBEDO = NORMAL.xyz;
}

void light() {
	 DIFFUSE_LIGHT = vec3(dot(NORMAL, normalize(vec3(1, 1, 0))));
}

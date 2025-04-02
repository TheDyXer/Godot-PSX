shader_type spatial;

uniform sampler2D color_texture : filter_nearest;

varying vec4 clip_pos;

void vertex() {
	vec4 snapToPixel = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1);
	vec4 v = snapToPixel;
    //POSITION = PROJECTION_MATRIX * (vec4((MODELVIEW_MATRIX * (vec4(VERTEX, 1.0))).xyz, 1));
	POSITION = v;
	clip_pos = v;
	
	UV = UV * vec2(3.0, 2.0);
}

void fragment() {
	ALBEDO = texture(color_texture, UV).rgb;
}

void light() {
	 DIFFUSE_LIGHT = vec3(1.0);
}

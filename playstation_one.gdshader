shader_type spatial;
render_mode skip_vertex_transform;

uniform bool billboard = false;

uniform sampler2D color_texture : source_color, filter_nearest, repeat_disable;

uniform vec3 tint : source_color = vec3(1);
uniform vec2 fog_start_end = vec2(10, 100);
uniform vec3 fog_color : source_color = vec3(0.42, 0.42, 0.45);

uniform bool add_dynamic_vertex_lighting = false;
uniform vec3 light_direction = vec3(0, 1, 0);
uniform float light_intensity = 1.0;
uniform vec3 ambient_light : source_color = vec3(0);

uniform float dither_spread = 0.0045;


varying vec4 clip_pos;
varying float view_distance;

void vertex() {
	mat4 model_matrix = MODEL_MATRIX;
	
	if (billboard) {
		mat4 mat_world = mat4(
				normalize(INV_VIEW_MATRIX[0]),
				vec4(0, 1, 0, 0),
				normalize(INV_VIEW_MATRIX[2]),
				MODEL_MATRIX[3]);
				
		model_matrix = mat_world;
		
		MODELVIEW_MATRIX = VIEW_MATRIX * mat_world;

		MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	}
	
	vec4 world_space = model_matrix * vec4(VERTEX, 1);
	
	vec4 clip = PROJECTION_MATRIX * VIEW_MATRIX * world_space;
	
	// Snap to nearest pixel
	vec4 vertex = clip;
	vertex.xy = round(clip.xy / clip.w * VIEWPORT_SIZE.xy) / VIEWPORT_SIZE.xy * clip.w;
	
	POSITION = vertex;
	
	// Need to hold on to clip.w to reverse perspective corrections
	clip_pos = vertex;
	
	// Calculate vertex distance from camera
	view_distance = length(CAMERA_POSITION_WORLD - world_space.xyz);
	
	// Multiply by perspective correction to undo it in fragment shader
	UV = UV * clip_pos.w;
	
	NORMAL = MODEL_NORMAL_MATRIX * NORMAL;
	
	if (add_dynamic_vertex_lighting) {
		float direct_light = clamp(dot(NORMAL, normalize(light_direction)), 0, 1);
		
		vec3 light = ambient_light + direct_light * light_intensity;
		COLOR.rgb *= clamp(light, vec3(0), vec3(1));
	}
}

void fragment() {
	// Calculate linear fog factor
	float fog_factor = (fog_start_end.y - (view_distance)) / (fog_start_end.y - fog_start_end.x);
	fog_factor = 1.0 - clamp(fog_factor, 0.0, 1.0);
	
	vec3 texture_color = texture(color_texture, (UV / clip_pos.w)).rgb;
	
	vec3 vertex_color = COLOR.rgb;
	
	vec3 albedo = texture_color * vertex_color * tint;
	
	vec3 fogged = mix(albedo, fog_color, fog_factor);
	fogged = clamp(fogged, vec3(0), vec3(1));
	
	int bayer[16] = {
    		0, 8, 2, 10,
    		12, 4, 14, 6,
    		3, 11, 1, 9,
    		15, 7, 13, 5
	};
	
	float noise = float(bayer[(int(FRAGCOORD.x) % 4) + (int(FRAGCOORD.y) % 4) * 4]) * (1.0 / 16.0) - 0.5;
	
	vec3 quantized = pow(fogged + dither_spread * noise, vec3(1.0 / 2.2));
	
	quantized.r = floor((32.0 - 1.0) * quantized.r + 0.5) / (32.0 - 1.0);
	quantized.g = floor((64.0 - 1.0) * quantized.g + 0.5) / (64.0 - 1.0);
	quantized.b = floor((32.0 - 1.0) * quantized.b + 0.5) / (32.0 - 1.0);
	
	ALBEDO = quantized;
	ALBEDO = pow(ALBEDO, vec3(2.2));
	//ALBEDO = fogged;
	
	//ALBEDO = vec3(fog_factor);
	
	//ALBEDO = NORMAL.xyz;
	
	//ALBEDO = pow(COLOR.rgb, vec3(2.2));
}

void light() {
	DIFFUSE_LIGHT = vec3(1);
	SPECULAR_LIGHT = vec3(0);
}

shader_type spatial;
uniform sampler2D main_texture : source_color;

#include "BaseTerrainQuadtreeNode_include.gdshaderinc"

varying vec3 v_color;
varying vec3 v_normal;

void vertex() {
	vec3 world_vertex = CAMERA_POSITION_WORLD * VERTEX;
	VERTEX = get_terrain_base_vertex(VERTEX);
	v_normal = get_base_normal(VERTEX);
	v_color = COLOR.xyz;
	NORMAL = get_base_normal(VERTEX);
}

void fragment() {
	vec2 uv = get_base_uv2(UV);
	//ALBEDO = texture(heightmap, uv).rbg;
	//ALBEDO = v_normal;
	
	//NORMAL *= 0.5;
	
	ALBEDO = texture(main_texture, uv * 100.0).rgb;
	//NORMAL = texture(normal_map, uv).rgb;
	//NORMAL_MAP = texture(normal_map, uv).rgb;
	
	vec3 n = v_normal;
	
	//n = normalize(vec3(0, 1, -0.000015));
	//NORMAL = NORMAL;
	//NORMAL_MAP = vec3(0, 1, 0);
	//ALBEDO = v_color;
	//ALBEDO.g = 1.0;
	//ALBEDO.g = float(lod) / 8.0;
	//ALBEDO.r = float(lod) / 8.0;
	
	
	
	//vec3 lod_color = vec3(1, 1, 1) * float(lod) / 0.8;
	//ALBEDO *= lod_color * .1;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
	    //DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION	 * LIGHT_COLOR;
//}

uniform int lod;
uniform float height;
uniform vec2 heightmap_offset;
uniform sampler2D heightmap;
uniform sampler2D normal_map;

const float _vertex_step = 1.0 / 16.0;

vec2 get_base_uv2(vec2 uv) {
	return uv / pow(2, float(lod)) + heightmap_offset;
}

vec2 get_base_uv(float x, float z) {
	vec2 uv = vec2(x, z) + vec2(0.5, 0.5);
	return uv / pow(2, float(lod)) + heightmap_offset;
}

float get_height(float x, float z) {
	vec2 uv = get_base_uv(x, z);
	return texture(heightmap, uv).x * height;
}

vec3 get_base_normal(vec3 vertex) {
	vec3 right_vertex = vertex + vec3(_vertex_step, 0.0, 0.0);
	right_vertex.y = get_height(right_vertex.x, right_vertex.z);
	vec3 forward_vertex = vertex + vec3(0.0, 0.0, _vertex_step);
	forward_vertex.y = get_height(forward_vertex.x, forward_vertex.z);
	
	vec3 right_vector = right_vertex - vertex;
	vec3 forward_vector = forward_vertex - vertex;
	
	return normalize(cross(forward_vector, right_vector));
}

//vec3 get_global_position(vec3 pos

vec3 get_terrain_base_vertex(vec3 vertex) {
	//uv = get_base_uv(vertex);
	//float h = texture(heightmap, uv).x * 25.0;
	//float h = texture(heightmap, uv).x * size.y / 20.0;
	vertex.y = get_height(vertex.x, vertex.z);
	return vertex;
}

vec3 get_terrain_base_normal() {
	return vec3(0,0,0);
}
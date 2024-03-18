shader_type spatial;

uniform vec3 base_size;
uniform int lod;
uniform int max_lod;

float my_pow(int v1, int v2) {
	float result = 1.0;
	for (int i = 0; i < v2; i++) {
		result *= float(v1);
	}
	return result;
}

void vertex() {
	//vec3 base_size = vec3(100.0, 100.0, 100.0);
	float p = my_pow(2, lod);
	//VERTEX.y += cos(VERTEX.x * 4.0) * sin(VERTEX.z * 4.0);
	VERTEX.x = VERTEX.x * base_size.x / p;
	VERTEX.z = VERTEX.z * base_size.z / p;
}

//void vertex() {
  //VERTEX.y += cos(VERTEX.x * 4.0) * sin(VERTEX.z * 4.0);
//}

void fragment() {
	float r = float(lod) / float(max_lod);
	ALBEDO = vec3(r, 0.0, 0.0);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}

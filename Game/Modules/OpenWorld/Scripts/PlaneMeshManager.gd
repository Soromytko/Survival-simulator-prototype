class_name PlaneMeshManager

class PrebuildMeshData:
	var vertices : PackedVector3Array
	var indices : PackedInt32Array
	var normals : PackedVector3Array
	func _init(vertices : PackedVector3Array, indices : PackedInt32Array, normals : PackedVector3Array):
		self.vertices = vertices
		self.indices = indices
		self.normals = normals
		

static func create_prebuild_mesh_data(size : Vector3) -> PrebuildMeshData:
	var width = size.x
	var depth = size.z
	var width_s = width + 1
	var depth_s = depth + 1
	var vertices : PackedVector3Array = []
	vertices.resize(width_s * depth_s)
	for x in width_s:
		for z in depth_s:
			var w = x - width / 2
			var h = 0
			var d = z - depth / 2
			vertices[x * width_s + z] = Vector3(w, h, d)
			
	var indices : PackedInt32Array = []
	indices.resize(width * depth * 6)
	var vert : int = 0
	var ind : int = 0
	for x in width:
		for z in depth:
			indices[ind + 0] = vert + 0
			indices[ind + 1] = vert + depth_s
			indices[ind + 2] = vert + 1
			indices[ind + 3] = vert + depth_s
			indices[ind + 4] = vert + depth_s + 1
			indices[ind + 5] = vert + 1
		
			vert += 1
			ind += 6
		vert += 1
	
	var normals : PackedVector3Array = []
	normals.resize(vertices.size())
	for i in normals.size():
		normals[i] = Vector3(0, 1, 0)
		
	return PrebuildMeshData.new(vertices, indices, normals)
	
	
static func create_mesh(vertices : PackedVector3Array, indices : PackedInt32Array, normals : PackedVector3Array) -> Mesh:
	var mesh_data = []
	mesh_data.resize(ArrayMesh.ARRAY_MAX)
	mesh_data[ArrayMesh.ARRAY_VERTEX] = vertices
	mesh_data[ArrayMesh.ARRAY_INDEX] = indices
	mesh_data[ArrayMesh.ARRAY_NORMAL] = normals;
	
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data)
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(array_mesh, 0)
	surface_tool.generate_normals()
	
	return surface_tool.commit()


static func create_mesh_from_prebuild_data(prebuild_mesh_data : PrebuildMeshData) -> Mesh:
	var vertices : PackedVector3Array = prebuild_mesh_data.vertices
	var indices : PackedInt32Array = prebuild_mesh_data.indices
	var normals : PackedVector3Array = prebuild_mesh_data.normals
	return create_mesh(vertices, indices, normals)


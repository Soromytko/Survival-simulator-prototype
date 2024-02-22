class_name TerrainQuadTree extends Node3D

@export var main_texture : Texture
@export var heightmap : Texture
@export var normal_map : Texture
@export var size : Vector3i = Vector3.ONE * 100
@export var max_lod : int = 5
@export var update_timeout : float = 2
@export var observer : Node3D
@export var some_child_node_scene : PackedScene
@export var shader : Shader
@export var mesh_subdivision : int = 16

var _root_node : TerrainQuadtreeNode
var _timer : Timer

func _ready2():
	_init_timer()
	_init_root_node()
	_update()
	
	
func _process(delta):
	return
	if Input.is_action_just_pressed("Alt"):
		_update()
	
	
func _update():
	_root_node.update_recursively(observer.global_position)
	#print(_root_node.get_length())
	
	
func _init_timer():
	_timer = Timer.new()
	_timer.timeout.connect(Callable(self, "_update"))
	add_child(_timer)
	_timer.start(update_timeout)
	
	
func _init_root_node():
	var config : TerrainQuadtreeNode.Config = TerrainQuadtreeNode.Config.new()
	config.parent = null
	config.lod = 0
	config.max_distance = size[size.max_axis_index()] * 2
	config.size = size
	var global_config : TerrainQuadtreeNode.GlobalConfig = TerrainQuadtreeNode.GlobalConfig.new()
	global_config.observer = observer
	global_config.max_lod = max_lod
	global_config.meshes = _create_meshes()
	global_config.some_child_scene = some_child_node_scene
	global_config.heightmap = heightmap
	global_config.normal_map = normal_map
	global_config.main_texture = main_texture
	global_config.shader = shader
	_root_node = TerrainQuadtreeNode.new(config, global_config)
	global_config.root = _root_node
	add_child(_root_node)
	

func _is_need_average(vertex : Vector3, value : float) -> bool:
	return is_equal_approx(vertex.x, value) && \
		int((vertex.z + 0.5) * (mesh_subdivision + 1)) % 2 != 0
	
	
func _average_vertex_if_needed(vertex : Vector3, value : float, inverse_xz : bool = false) -> bool:
	var inverse_vertex : Vector3 = Vector3(vertex.z, vertex.y, vertex.x) if inverse_xz else vertex
	return _is_need_average(inverse_vertex, value)
	
	
func _create_meshes():
	#array[2][2][2][2]
	var meshes = [[[[]]]]
	meshes.resize(2)
	for left_index in meshes.size():
		meshes[left_index] = [[[]]]
		meshes[left_index].resize(2)
		for right_index in meshes[left_index].size():
			meshes[left_index][right_index] = [[]]
			meshes[left_index][right_index].resize(2)
			for back_index in meshes[left_index][right_index].size():
				meshes[left_index][right_index][back_index] = []
				meshes[left_index][right_index][back_index].resize(2)
				for forward_index in meshes[left_index][right_index][back_index].size():
					var mesh : Mesh = PlaneMesh.new()
					mesh.size = Vector2i.ONE
					mesh.subdivide_width = mesh_subdivision
					mesh.subdivide_depth = mesh_subdivision
					var array_mesh : ArrayMesh = ArrayMesh.new()
					array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh.get_mesh_arrays())
					var mesh_data_tool : MeshDataTool = MeshDataTool.new()
					mesh_data_tool.create_from_surface(array_mesh, 0)
					var vertex_step : float = 1.0 / (mesh_subdivision + 1)
					for i in mesh_data_tool.get_vertex_count():
						var vertex_color : Color = Color.GREEN
						var current_vertex : Vector3 = mesh_data_tool.get_vertex(i)
						if left_index == 1:
							if _average_vertex_if_needed(current_vertex, -0.5):
								#vertex_color = Color.RED
								mesh_data_tool.set_vertex(i, current_vertex + Vector3.FORWARD * vertex_step)
							#elif is_equal_approx(current_vertex.x, -0.5): vertex_color = Color.BLUE
								pass
						if right_index == 1:
							if _average_vertex_if_needed(current_vertex, +0.5):
								vertex_color = Color.RED
								mesh_data_tool.set_vertex(i, current_vertex + Vector3.FORWARD * vertex_step)
								pass
						if back_index == 1:
							if _average_vertex_if_needed(current_vertex, -0.5, true):
								vertex_color = Color.RED
								mesh_data_tool.set_vertex(i, current_vertex + Vector3.RIGHT * vertex_step)
								pass
						if forward_index == 1:
							if _average_vertex_if_needed(current_vertex, +0.5, true):
								vertex_color = Color.RED
								mesh_data_tool.set_vertex(i, current_vertex + Vector3.RIGHT * vertex_step)
								pass
						mesh_data_tool.set_vertex_color(i, vertex_color)
					array_mesh.clear_surfaces()
					mesh_data_tool.commit_to_surface(array_mesh)
					
					#var surface_tool = SurfaceTool.new()
					#surface_tool.create_from(array_mesh, 0)
					#surface_tool.generate_normals()
					#mesh = surface_tool.commit()
					#meshes[left_index][right_index][back_index][forward_index] = mesh
					
					meshes[left_index][right_index][back_index][forward_index] = array_mesh
	return meshes
	
	

@tool
class_name TerrainQuadtreeNode extends Node3D

class Quarter:
	const FIRST : Vector3 = Vector3(-1, 0, -1)
	const SECOND : Vector3 = Vector3(1, 0, -1)
	const THIRD : Vector3 = Vector3(-1, 0, 1)
	const FOURTH : Vector3 = Vector3(1, 0, 1)
	

signal loaded()
signal updated()
signal released()
signal mesh_created()
signal mesh_released()


class Config:
	var parent : TerrainQuadtreeNode
	var lod : int
	var max_distance : float
	var size : Vector3
	
	
class GlobalConfig:
	var root : TerrainQuadtreeNode
	var observer : Node3D
	var max_lod : int
	var meshes = [[[[]]]]
	var some_child_scene : PackedScene
	var heightmap : Texture2D
	var main_texture : Texture
	var shader : Shader


var _config : Config
var _global_config : GlobalConfig
var _heightmap_offset : Vector2
var _children : Array[TerrainQuadtreeNode]
var mesh_instance : MeshInstance3D:
	get:
		return mesh_instance
var collision_shape : CollisionShape3D:
	get:
		return collision_shape
	
	
func _init(config : Config, global_config : GlobalConfig):
	_config = config
	_global_config = global_config
	if _global_config.some_child_scene != null:
		var some_child = _global_config.some_child_scene.instantiate()
		add_child(some_child)
	
	
func get_config() -> Config:
	return _config
	
	
func is_leaf():
	return _children.size() == 0
	
	
func get_length():
	var result : int = _children.size();
	for child in _children:
		result += child.get_length()
	return result
	
	
func update_recursively(observer_position : Vector3):
	if _can_subdivide():
		if is_leaf():
			_release_mesh()
			_release_collision_shape()
			_create_children()
			updated.emit()
		for child in _children:
			child.update_recursively(observer_position)
	else:
		if !is_leaf():
			_release_children()
		_update_mesh()
		_update_collision_shape()
	
	
func _can_subdivide() -> bool:
	return is_pretty_close_to_observer() && _config.lod < _global_config.max_lod
	
	
func _create_child_config() -> Config:
	var child_config = Config.new()
	child_config.parent = self
	child_config.lod = _config.lod + 1
	child_config.max_distance = _config.max_distance / 2
	child_config.size =  _config.size / 2
	return child_config
	
	
func _create_children():
	_children.resize(4)
	var child_config : Config = _create_child_config()
	for i in _children.size():
		_children[i] = TerrainQuadtreeNode.new(child_config, _global_config)
		add_child(_children[i])
		_children[i].owner = owner
	_children[0]._set_position_in_quadtree(Quarter.FIRST)
	_children[1]._set_position_in_quadtree(Quarter.SECOND)
	_children[2]._set_position_in_quadtree(Quarter.THIRD)
	_children[3]._set_position_in_quadtree(Quarter.FOURTH)
	for child in _children:
		child.loaded.emit()
	
	
func _set_position_in_quadtree(quarter_offset : Vector3):
	position = quarter_offset * _config.size / 2
	var root : TerrainQuadtreeNode = _global_config.root
	var root_size : Vector3 = root.get_config().size
	var global_origin = -Vector3.ONE * 0.5 * root_size + root.global_position
	var local_origin = global_position - _config.size / 2
	var offset = (local_origin - global_origin) / root_size
	_heightmap_offset = Vector2(offset.x, offset.z)
	
	
func _release_children():
	for child in _children:
		child._release_children()
		child.queue_free()
	_children.clear()
	
	
func _update_mesh():
	if mesh_instance == null:
		mesh_instance = MeshInstance3D.new()
		add_child(mesh_instance)
		mesh_instance.owner = owner
		mesh_instance.ignore_occlusion_culling = true
		mesh_instance.mesh = _get_suitable_mesh()
		mesh_instance.extra_cull_margin = 100
		mesh_instance.scale = Vector3(_config.size.x, 1, _config.size.z)
		mesh_instance.material_override = _create_material()
		mesh_created.emit()
	
	
func _update_collision_shape():
	return
	if collision_shape == null:
		collision_shape = CollisionShape3D.new()
		var shape : HeightMapShape3D = HeightMapShape3D.new()
		shape.map_width = _config.size.x + 1
		shape.map_depth = _config.size.z + 1
		collision_shape.shape = shape
		#collision_shape.scale = Vector3.ONE / 15.0 * _config.size
		add_child(collision_shape)
		var image : Image = _global_config.heightmap.get_image()
		var root_config : Config = _global_config.root._config
		
		image.load("res://demo/qtterrain/textures/heightmap2.png")
		
		var offset : Vector3 = _config.size * 0.5
		offset = global_position * 2
		
		for i in shape.map_width:
			for j in shape.map_depth:
				var point : Vector2 = Vector2(i + offset.x, j + offset.z) / \
					Vector2(root_config.size.x, root_config.size.z)
				var pixel : Vector2i = Vector2i(point * Vector2(image.get_size()))
				var y : float = image.get_pixel(pixel.y, pixel.x).r * _global_config.root._config.size.y
				shape.map_data[i * shape.map_depth + j] = y
		collision_shape.owner = owner
		
		
var debug_node : Node3D
func _get_suitable_mesh() -> Mesh:
	var left_index : int = 0
	var right_index : int = 0
	var back_index : int = 0
	var forward_index : int = 0
	
	if _config.parent != null:
		var parent : TerrainQuadtreeNode = _config.parent
		var parent_config : TerrainQuadtreeNode.Config = parent.get_config()
		var parent_size : Vector3 = parent_config.size
		var signs : Vector3i = sign(position)
		
		var x_neighbor_offset : Vector3 = Vector3.RIGHT * signs.x * parent_size.x
		var z_neighbor_offset : Vector3 = -Vector3.FORWARD * signs.z * parent_size.z
		var x_has_neighbor : int = int(!parent.is_pretty_close_to_observer(x_neighbor_offset))
		var z_has_neighbor : int = int(!parent.is_pretty_close_to_observer(z_neighbor_offset))
		
		if signs.x < 0:
			left_index = x_has_neighbor
		else:
			right_index = x_has_neighbor
		if signs.z < 0:
			back_index = z_has_neighbor
		else:
			forward_index = z_has_neighbor
			
	return _global_config.meshes[left_index][right_index][back_index][forward_index]
	
	
func is_pretty_close_to_observer0(position : Vector3, max_distance : float) -> bool:
	var distance : float = _global_config.observer.global_position.distance_to(position)
	return distance < max_distance   
	
	
func is_pretty_close_to_observer(node_offet : Vector3 = Vector3.ZERO) -> bool:
	#return _global_config.observer.global_position.distance_to(global_position + node_offet) < _config.max_distance
	var relative_observer_position : Vector3 = _global_config.observer.global_position - global_position - node_offet
	var box_size : Vector3 = _config.size * 2
	box_size.y *= 5
	box_size.y += _global_config.root._config.size.y
	return relative_observer_position.x < box_size.x && relative_observer_position.x > -box_size.x && \
		relative_observer_position.y < box_size.y * 2 && relative_observer_position.y > 0 && \
		relative_observer_position.z < box_size.z && relative_observer_position.z > -box_size.z
	
	
func _create_material():
	var material : ShaderMaterial = ShaderMaterial.new()
	material.shader = _global_config.shader
	material.set_shader_parameter("lod", _config.lod)
	material.set_shader_parameter("height", _global_config.root._config.size.y)
	material.set_shader_parameter("heightmap", _global_config.heightmap)
	material.set_shader_parameter("heightmap_offset", _heightmap_offset)
	material.set_shader_parameter("main_texture", _global_config.main_texture)
	return material
	
	
func _release_mesh():
	if mesh_instance != null:
		mesh_instance.queue_free()
		mesh_released.emit()
		mesh_instance = null
	
	
func _release_collision_shape():
	if collision_shape != null:
		collision_shape.queue_free()
		collision_shape = null
	
	
func _create_collision_shape() -> CollisionShape3D:
	var collision_shape : CollisionShape3D = CollisionShape3D.new()
	collision_shape.shape = HeightMapShape3D.new()
	return collision_shape


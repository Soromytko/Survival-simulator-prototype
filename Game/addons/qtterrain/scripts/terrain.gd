@tool
extends Node3D

## The size of the terrain
@export var size : Vector3i = Vector3.ONE * 100:
	get:
		return size
	set(value):
		size = value
		_recreate_terrain()
		_update_collision_shape()
		
@export var main_texture : Texture:
	get:
		return main_texture
	set(value):
		main_texture = value
		_recreate_terrain()
	
@export var heightmap : Texture2D:
	get:
		return heightmap
	set(value):
		heightmap = value
		print(heightmap)
		_recreate_terrain()
		_update_collision_shape()
		
## The depth of the quadtree
@export var max_lod : int = 5:
	get:
		return max_lod
	set(value):
		max_lod = value
		print(max_lod)
		_recreate_terrain()
		
@export var observer : Node3D:
	get:
		return observer
	set(value):
		observer = value
		
@export var some_child_node_scene : PackedScene
@export var mesh_subdivision : int = 7:
	get: return mesh_subdivision
	set(value):
		mesh_subdivision = value
		_recreate_terrain(true)

const Quadtree = preload("./TerrainQuadtreeNode.gd")
const MeshGenerator = preload("./terrain_mesh_generator.gd")
const HeightmapCollision = preload("./height_map_collision.gd")

const _shader : Shader = preload("./../shaders/BaseTerrainQuadtreeNode.gdshader")

var _quadtree = null
var _heightmap_collision = null
var _mesh_generator = MeshGenerator.new()


func _ready():
	owner = get_tree().get_edited_scene_root()
	_recreate_terrain()
	_update_collision_shape()
	
	
func _process(delta):
	if _quadtree != null:
		_quadtree.update_recursively(observer.global_position)
	
	
func _recreate_terrain(is_recreate_mesh : bool = false):
	if !_validate_data():
		return
	if is_recreate_mesh || _mesh_generator.meshes == null:
		_mesh_generator.create_meshes(mesh_subdivision * 2 + 1)
	if _quadtree != null:
		_quadtree.queue_free()
		_quadtree = null
	var config = _create_config()
	var global_config = _create_global_config()
	_quadtree = Quadtree.new(config, global_config)
	global_config.root = _quadtree
	add_child(_quadtree)
	#_quadtree.owner = owner
	
	
func _update_collision_shape():
	return
	if !_validate_data():
		return
	if _heightmap_collision != null:
		_heightmap_collision.queue_free()
	_heightmap_collision = HeightmapCollision.new()
	add_child(_heightmap_collision)
	_heightmap_collision.owner = owner
	_heightmap_collision.heightmap = heightmap.get_image()
	_heightmap_collision.width = size.x + 1
	_heightmap_collision.height = size.y
	_heightmap_collision.depth = size.z + 1
	_heightmap_collision.update()
	
	
func _create_global_config():
	var global_config = Quadtree.GlobalConfig.new()
	global_config.main_texture = main_texture
	global_config.heightmap = heightmap
	global_config.max_lod = max_lod
	#global_config.update_timeout = update_timeout
	global_config.observer = observer
	global_config.some_child_scene = some_child_node_scene
	global_config.shader = _shader
	global_config.meshes = _mesh_generator.meshes
	return global_config
	
	
func _create_config():
	var config = Quadtree.Config.new()
	config.parent = null
	config.lod = 0
	config.max_distance = size[size.max_axis_index()] * 2
	config.size = size
	return config
	
	
func _validate_data() -> bool:
	if heightmap == null:
		return false
	return true

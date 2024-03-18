extends Node3D

var _terrain_node : TerrainQuadtreeNode
var _config : TerrainQuadtreeNode.Config
var _global_config : TerrainQuadtreeNode.GlobalConfig
var _material : StandardMaterial3D

@export var _shader : Shader

func _ready():
	_terrain_node = get_parent()
	_config = _terrain_node.get_config()
	_global_config = _terrain_node._global_config
	_terrain_node.mesh_created.connect(_on_mesh_created)
	_create_material()
	
	
func _on_mesh_created():
	return
	var mesh_instance : MeshInstance3D = _terrain_node.mesh_instance
	mesh_instance.material_override = _material
	return
	
	var material : ShaderMaterial = ShaderMaterial.new()
	material.shader = _shader
	material.set_shader_parameter("base_size", Vector3.ONE * 100)
	material.set_shader_parameter("lod", _config.lod)
	material.set_shader_parameter("max_lod", _global_config.max_lod)
	mesh_instance.material_override = material
	

func _create_material():
	_material = StandardMaterial3D.new()
	var r : float = _config.lod / float(_global_config.max_lod)
	_material.albedo_color = Color(r, 0, 0, 1.0)
	


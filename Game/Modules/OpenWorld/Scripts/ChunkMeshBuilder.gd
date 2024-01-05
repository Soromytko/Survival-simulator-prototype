extends Node3D

# The size of the chunk in meters
@export var chunk_size : Vector3 = Vector3.ONE * 10
# Number of vertices per meter
@export var chunk_subdivision : float = 1
@export var saving_path : String = "res://ChunkMeshes"
@export var chunk_scene : PackedScene


#func _ready():
	#var format_string = "func _generate_L%s_R%s_B%s_F%s():"
	#for l in 2:
		#for r in 2:
			#for b in 2:
				#for f in 2:
					#var str = format_string % [str(l), str(r), str(b), str(f)]
					#print(str)


func _ready():
	var prebuild_mesh_data = PlaneMeshManager.create_prebuild_mesh_data(chunk_size)
	var mesh : Mesh = PlaneMeshManager.create_mesh_from_prebuild_data(prebuild_mesh_data)
	
	$MeshInstance3D.mesh = mesh
	
	#$CollisionShape3D.shape = array_mesh.create_trimesh_shape()
	
	_save_node($MeshInstance3D)


func _save_node(node : Node, path : String = "res://Modules/OpenWorld/MyScene.tscn"):
	var scene = PackedScene.new()
	scene.pack(node)
	ResourceSaver.save(scene, path)


func generate():
	var chunk_cc = chunk_scene.instantiate()
	
	
func _generate_L0_R0_B0_F0():
	pass
func _generate_L0_R0_B0_F1():
	pass
func _generate_L0_R0_B1_F0():
	pass
func _generate_L0_R0_B1_F1():
	pass
func _generate_L0_R1_B0_F0():
	pass
func _generate_L0_R1_B0_F1():
	pass
func _generate_L0_R1_B1_F0():
	pass
func _generate_L0_R1_B1_F1():
	pass
func _generate_L1_R0_B0_F0():
	pass
func _generate_L1_R0_B0_F1():
	pass
func _generate_L1_R0_B1_F0():
	pass
func _generate_L1_R0_B1_F1():
	pass
func _generate_L1_R1_B0_F0():
	pass
func _generate_L1_R1_B0_F1():
	pass
func _generate_L1_R1_B1_F0():
	pass
func _generate_L1_R1_B1_F1():
	pass


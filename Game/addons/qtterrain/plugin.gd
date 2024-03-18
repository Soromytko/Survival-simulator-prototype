@tool
extends EditorPlugin

const Terrain = preload("./scripts/terrain.gd")
const icon : Texture2D = preload("./icons/icon.png")
const type_name : String = "Terrain (QTTerrain plugin)"


func _apply_changes():
	print("CHANGE")
	
	
func _enter_tree():
	#add_inspector_plugin(inspector_plugin)
	add_custom_type(type_name, "Node3D", Terrain, icon)
	

func _exit_tree():
	#remove_inspector_plugin(inspector_plugin)
	remove_custom_type(type_name)

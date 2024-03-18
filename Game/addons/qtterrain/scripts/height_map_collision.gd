@tool
extends StaticBody3D

@export var width : int:
	get:
		return width
	set(value):
		width = clampi(value, 0, abs(value))
		_calculate_collision_shape_array_size()
		update()
	
@export var height : float:
	get:
		return height
	set(value):
		height = value
		_calculate_collision_shape_array_size()
		update()
	
@export var depth : int:
	get:
		return depth
	set(value):
		depth = clampi(value, 0, abs(value))
		_calculate_collision_shape_array_size()
		update()
	
@export var heightmap : Image:
	get:
		return heightmap
	set(value):
		heightmap = value
		if heightmap.is_compressed():
			heightmap.decompress()
		_calculate_collision_shape_array_size()
		update()
	
## Maximum size of a single collision shape (in meters).
## The Y coordinate is not used.
@export var collision_shape_max_size : Vector3i = Vector3i.ONE * 101:
	get:
		return collision_shape_max_size
	set(value):
		collision_shape_max_size = value
	
var _collision_shapes = []
var _collision_shape_array_size : Vector2i
var _thread : Thread = Thread.new()
var _is_terminate_thread : bool = false

func update():
	if heightmap == null || width == 0 || depth == 0:
		return
	if _thread.is_started():
		_is_terminate_thread = true
		_thread.wait_to_finish()
		_is_terminate_thread = false
	
	for collision_shapes in _collision_shapes:
		for collision_shape in collision_shapes:
			collision_shape.queue_free()
	
	_collision_shapes.resize(_collision_shape_array_size.x)
	for i in _collision_shape_array_size.x:
		var array = []
		array.resize(_collision_shape_array_size.y)
		_collision_shapes[i] = array
		for j in _collision_shape_array_size.y:
			var current_collision_shape : CollisionShape3D = CollisionShape3D.new()
			var shape : HeightMapShape3D = HeightMapShape3D.new()
			shape.map_width = collision_shape_max_size.x
			shape.map_depth = collision_shape_max_size.y
			current_collision_shape.shape = shape
			
			add_child(current_collision_shape)
			current_collision_shape.owner = owner
			current_collision_shape.visible = false
			_collision_shapes[i][j] = current_collision_shape
	
	_update_collision_shapes_async()
	
	
func _calculate_collision_shape_array_size():
	if width <= 0 || depth <= 0:
		return
	_collision_shape_array_size = Vector2i(
		ceili(float(width) / collision_shape_max_size.x),
		ceili(float(depth) / collision_shape_max_size.z)
	)
	
	
func updating_collision_shapes():
	print("start...")
	_is_terminate_thread = false
	for collision_shapes in _collision_shapes:
		for collision_shape in collision_shapes:
			var current_shape : HeightMapShape3D = collision_shape.shape
			#current_shape.map_width = collision_shape_max_size.x
			#current_shape.map_depth = collision_shape_max_size.z
			for i in current_shape.map_width:
				for j in current_shape.map_depth:
					var pixel : Vector2i = Vector2(i, j) / Vector2(width, depth) * \
					Vector2(heightmap.get_size())
					#var h : float = heightmap.get_pixel(pixel.y, pixel.x).r * height
					var h = 0
					current_shape.map_data[i * current_shape.map_depth + j] = h
					if _is_terminate_thread:
						return
	print("done")

func _update_collision_shapes_async():
	_thread.start(updating_collision_shapes)
	

func _exit_tree():
	if _thread.is_started():
		_is_terminate_thread = true
		_thread.wait_to_finish()

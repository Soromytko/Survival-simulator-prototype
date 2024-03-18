@tool
extends TextureRect

## Resolution of the resulting heightmap
@export var resolution : Vector2i = Vector2i(1024, 1024):
	get:
		return resolution
	set(value):
		resolution = Vector2i(clampi(value.x, 0, value.x), clampi(value.y, 0, value.y))
		_create()
	
	
@export var noise_size : Vector2i = Vector2i(1024, 1024):
	get:
		return noise_size
	set(value):
		noise_size = Vector2i(clampi(value.x, 0, value.x), clampi(value.y, 0, value.y))
		_create()
	
	
## Path to save the resulting heightmap
@export var path_to_save : String = "res://demo/qtterrain/textures/heightmap.png":
	get:
		return path_to_save
	set(value):
		path_to_save = value
	
	
func _ready():
	_create()
	
	
func _create2():
	var noise_texture = NoiseTexture2D.new()
	noise_texture.noise = FastNoiseLite.new()
	await noise_texture.changed
	var image = noise_texture.get_image()
	print(image.get_size())
	texture = noise_texture
	

func _create():
	_create2()
	return
	var noise : FastNoiseLite = FastNoiseLite.new()
	noise.seed = hash("some")
	var image = Image.create(resolution.x, resolution.y, false, Image.FORMAT_RGBA8)
	#for i in resolution.x:
		#for j in resolution.y:
			#var noise_vector : Vector2 = Vector2(i, j) / Vector2(resolution) * Vector2(noise_size)
			#var h : float = noise.get_noise_2dv(noise_vector)
			#var pixel_color : Color = Color(h, h, h, 1)
			#image.set_pixel(i, j, pixel_color)
	image = noise.get_image(resolution.x, resolution.y)
	var error = image.save_png(path_to_save)
	var result : ImageTexture = ImageTexture.create_from_image(image)
	texture = result
	#normal_map = _create_normal_map_from_heightmap(heightmap)
	
	
func _create_normal_map_from_heightmap(heightmap : ImageTexture) -> ImageTexture:
	var heightmap_image : Image = heightmap.get_image()
	var image_size = heightmap_image.get_size()
	var normal_map_image : Image = Image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
	for x in image_size.x:
		for y in image_size.y:
			var current_height : float = heightmap_image.get_pixel(x, y).r
			var right_height : float = heightmap_image.get_pixel(x + 1 if x + 1 < image_size.x else image_size.x - 1, y).r
			var forward_height : float = heightmap_image.get_pixel(x, y + 1 if y + 1 < image_size.y else image_size.y - 1).r
			
			current_height *= size.y
			right_height *= size.y
			forward_height *= size.y
			
			var right_vector : Vector3 = Vector3(1, right_height - current_height, 0)
			var forward_vector : Vector3 = Vector3(0, forward_height - current_height, 1)
			
			var normal : Vector3 = forward_vector.cross(right_vector).normalized()
			
			var color : Color = Color(normal.x, normal.z, normal.y, 1)
			normal_map_image.set_pixel(x, y, color)
			
	#normal_map_image.save_png("normal_map_test.png")
	return ImageTexture.create_from_image(normal_map_image)
	
	
	

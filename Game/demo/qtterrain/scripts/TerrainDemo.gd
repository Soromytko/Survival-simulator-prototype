@tool
extends "res://addons/qtterrain/scripts/terrain.gd"

@export var heightmap_size : Vector2i = Vector2i.ONE * 256
@export var noise_size : Vector2i = Vector2i.ONE * 256


@export var texture_rect : TextureRect


func _ready():
	_init_heightmap()
	super._ready()
	

func _init_heightmap():
	var noise : FastNoiseLite = FastNoiseLite.new()
	noise.seed = hash("some")
	var image = Image.create(heightmap_size.x, heightmap_size.y, false, Image.FORMAT_RGBA8)
	for i in heightmap_size.x:
		for j in heightmap_size.y:
			var noise_vector : Vector2 = Vector2(i, j) / Vector2(heightmap_size) * Vector2(noise_size)
			var h : float = noise.get_noise_2dv(noise_vector)
			var pixel_color : Color = Color(h, h, h, 1)
			image.set_pixel(i, j, pixel_color)
	#image.save_png("heightmap_test.png")
	heightmap = ImageTexture.create_from_image(image)
	texture_rect.texture = heightmap
	normal_map = _create_normal_map_from_heightmap(heightmap)
	
	
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
	

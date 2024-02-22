extends Node3D


func _ready():
	print("Started")
	await try_await()
	print("Done")
	
	
func _process(delta):
	if Input.is_action_just_pressed("sprint"):
		print("start")
		try_await()
		print("Done")

func try_await():
	#await get_tree().create_timer(3.0).timeout
	for i in 10000:
		for j in 1000:
			var a = i + j
			await a
	print("After timout")

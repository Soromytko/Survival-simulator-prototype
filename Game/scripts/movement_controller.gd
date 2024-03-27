extends Node3D

@export var character_body : CharacterBody3D


func move(direction : Vector3, speed : float):
	character_body.velocity.x = direction.x * speed
	character_body.velocity.z = direction.z * speed
	character_body.move_and_slide()


func apply_gravity(force : float):
	character_body.velocity.y -= force
	character_body.move_and_slide()


func jump(force : float):
	character_body.velocity.y += force


func is_grounded() -> bool:
	return character_body.is_on_floor()


func rotate_to_direction(direction : Vector3, speed : float):
	var rotation_target : float = atan2(-direction.x, -direction.z)
	character_body.rotation.y = lerp_angle(character_body.rotation.y, rotation_target, speed)


func get_direction_relative_to_camera(direction : Vector3):
	var camera : Camera3D = _get_camera()
	if camera != null:
		return camera.global_transform.basis.x * direction.x + camera.global_transform.basis.z * direction.z
	return direction


func _get_camera() -> Camera3D:
	return get_viewport().get_camera_3d()

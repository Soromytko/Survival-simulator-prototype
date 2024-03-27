extends "../movement_controller.gd"
class_name PlayerMovementController

@export var movement_speed : float = 1.5
@export var sprint_speed : float = 15.0
@export var rotation_speed : float = 5.0
@export var jump_force : float = 4.0
@export var gravity_force : float = 9.8


func move(direction : Vector3, delta : float):
	super.move(direction, delta * movement_speed * 100.0)


func apply_gravity(delta : float):
	super.apply_gravity(gravity_force * delta)


func jump(force : float = jump_force):
	super.jump(force)


func rotate_to_direction(direction : Vector3, delta : float):
	super.rotate_to_direction(direction, delta * rotation_speed)

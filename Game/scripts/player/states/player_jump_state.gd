extends "./player_state.gd"


func _on_enter():
	player_movement_controller.jump()


func _on_physics_update(delta):
	player_movement_controller.apply_gravity(delta)
	var input : Vector3 = class_player_input.get_move_axes()
	player_movement_controller.rotate_to_direction(input, delta)
	if player_movement_controller.is_grounded():
		return _switch_state("PlayerIdleState")


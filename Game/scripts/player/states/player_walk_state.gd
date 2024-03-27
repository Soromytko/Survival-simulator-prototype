extends "./player_state.gd"


func _on_enter():
	_play_anim("walk")


func _on_physics_update(delta):
	var input : Vector3 = class_player_input.get_move_axes()
	var relative_input = player_movement_controller.get_direction_relative_to_camera(input)
	
	if Input.is_action_pressed("sprint"):
		_play_anim("run")
	else: _play_anim("walk")
	
	if player_movement_controller.is_grounded():
		if class_player_input.get_is_jump():
			_switch_state("PlayerJumpState")
	else:
		player_movement_controller.apply_gravity(delta)

	player_movement_controller.move(relative_input, delta)
	player_movement_controller.rotate_to_direction(relative_input, delta)
	if input != Vector3.ZERO:
		player_movement_controller.rotate_to_direction(relative_input, delta)
	else:
		_switch_state("PlayerIdleState")


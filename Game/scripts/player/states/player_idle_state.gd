extends "./player_state.gd"


func _on_enter():
	_play_anim("idle")


func _on_physics_update(delta):
	if !player_movement_controller.is_grounded():
		player_movement_controller.apply_gravity(delta)
	#player_movement_controller.apply_velocity()
	
#	if !player.is_on_floor():
#		return _switch_state("FALL")
	
	var input : Vector3 = class_player_input.get_move_axes()
	if input != Vector3.ZERO:
		return _switch_state("PlayerWalkState")
		
	if Input.is_action_just_pressed("jump"):
		return _switch_state("PlayerJumpState")



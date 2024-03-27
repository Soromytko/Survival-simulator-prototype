extends StateMachineState
class_name PlayerState

const class_player_movement_controller = preload("res://scripts/player/player_movement_controller.gd")
const class_player_input = preload("../player_input.gd")

enum State {IDLE, FALL, JUMP, WALK, ON_GROUND, IN_FULL}

@export var player_movement_controller : class_player_movement_controller
@export var animation_tree : AnimationTree

var anim_names : Array[String] = ["idle", "walk", "run"]

func _play_anim(name : String):
	var par : String = "parameters/conditions/"
	for anim_name in anim_names:
		var is_true_name = name == anim_name
		animation_tree.set(par + anim_name, is_true_name)

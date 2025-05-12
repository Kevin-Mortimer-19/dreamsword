extends PlayerState


func enter(_args: Dictionary = {}):
	player.change_animation('Idle')


func update(_delta: float) -> void:
	if (Input.is_action_just_pressed('move_down')
	or Input.is_action_just_pressed('move_up')
	or Input.is_action_just_pressed('move_left')
	or Input.is_action_just_pressed('move_right')):
		machine.change_state('Walk')
	else:
		player.velocity = Vector2(0,0)

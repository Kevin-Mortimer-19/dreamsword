extends PlayerState


func enter(_args: Dictionary = {}):
	player.change_animation('Walk')


func update(_delta: float) -> void:
	player.walk()
	if ((not Input.is_action_pressed('move_down'))
	and (not Input.is_action_pressed('move_up'))
	and (not Input.is_action_pressed('move_left'))
	and (not Input.is_action_pressed('move_right'))):
		machine.change_state('Idle')

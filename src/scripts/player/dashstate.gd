extends PlayerState


func enter(_args: Dictionary = {}):
	player.change_animation('Dash')


func physics_update(_delta: float) -> void:
	player.dash()

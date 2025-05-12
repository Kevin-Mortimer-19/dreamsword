extends PlayerState


func enter(_args: Dictionary = {}):
	player.change_animation('Sword')


func update(_delta: float) -> void:
	player.walk()

extends PlayerState


func enter(args: Dictionary = {}):
	player.change_animation('Hurt')
	if args.has('dmg_source'):
		player.knockback(args['dmg_source'])


func update(_delta: float) -> void:
	pass

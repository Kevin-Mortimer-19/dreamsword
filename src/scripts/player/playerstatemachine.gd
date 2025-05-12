extends StateMachine

@export var player: Player


func _ready() -> void:
	call_deferred('initialize_states')
	super._ready()


func initialize_states():
	for c in get_children():
		c.player = player

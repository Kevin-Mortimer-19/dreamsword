extends Node2D

@export var monster: PackedScene

@export var notifier: VisibleOnScreenNotifier2D

# State determining the spawner's behavior.
#	ACTIVATED: The spawner is on screen and has already created a monster.
#	DEACTIVATED: The spawner is not on screen and will spawn a monster when it first enters the camera.
#enum State {
	#ACTIVATED,
	#DEACTIVATED,
#}
#
#var state

func _ready() -> void:
	notifier.screen_entered.connect(spawn_monster)


func spawn_monster():
	var m = monster.instantiate()
	add_child(m)

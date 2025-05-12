class_name StateMachine extends Node

@export var initial_state: State

var current_state: State


func _ready() -> void:
	for c in get_children():
		if c is State:
			c.machine = self
	current_state = initial_state
	call_deferred('enter_initial_state')


func enter_initial_state():
	current_state.enter()


func _process(delta: float) -> void:
	current_state.update(delta)


func _physics_process(delta: float) -> void:
	current_state.physics_update(delta)


func change_state(next_state: String, args: Dictionary = {}) -> void:
	current_state.exit()
	current_state = get_node(next_state)
	current_state.enter(args)

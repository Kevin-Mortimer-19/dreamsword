class_name Player extends CharacterBody2D

var health = 6

@export_category('Node References')
@export var timer: Timer
@export var sprite: AnimatedSprite2D
@export var machine: StateMachine

@export_category('Scenes')
@export var sword: PackedScene
@export var boots: PackedScene

@export_category('Movement Data')
@export var move_speed: int
@export var dash_speed: int
@export var dash_time: float
@export var run_speed: int
@export var knockback_time: float
@export var knockback_speed: int

enum PlayerAnim {
	WALK,
	SWORD,
	HURT,
	IDLE,
}

enum TimerState {
	KNOCKBACK,
	DASH,
}

var timer_state: TimerState

var facing: Vector2

var items : Array[PackedScene] = [null, null]

var animationstate: PlayerAnim


func _ready() -> void:
	animationstate = PlayerAnim.IDLE
	
	timer.wait_time = knockback_time
	
	facing = Vector2.DOWN
	
	items[0] = sword
	items[1] = boots


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	read_input()
	animate()
	move_and_slide()
	print_facing()


func read_input() -> void:
	if Input.is_action_just_pressed("item1"):
		useitem1()
	elif Input.is_action_just_pressed('item2'):
		useitem2()
	find_facing()


func walk() -> void:
	velocity = Input.get_vector('move_left', 'move_right', 'move_up', 'move_down').normalized() * move_speed


func print_facing():
	match facing:
		Vector2.DOWN:
			print('v')
		Vector2.UP:
			print('^')
		Vector2.RIGHT:
			print('>')
		Vector2.LEFT:
			print('<')
		_ :
			pass


func find_facing() -> void:
	# If player releases a movement button (ie they were moving
	# diagonally then moved straight), their direction changes
	if (Input.is_action_just_released("move_down")
	or Input.is_action_just_released("move_up")
	or Input.is_action_just_released("move_left")
	or Input.is_action_just_released("move_right")):
		get_tree().physics_frame.connect(update_facing, CONNECT_ONE_SHOT)
	
	# If player presses a new button, their direction updates
	if Input.is_action_just_pressed("move_down"):
		facing = Vector2.DOWN
	if Input.is_action_just_pressed("move_up"):
		facing = Vector2.UP
	if Input.is_action_just_pressed("move_right"):
		facing = Vector2.RIGHT
	if Input.is_action_just_pressed("move_left"):
		facing = Vector2.LEFT


func update_facing():
	match velocity.normalized():
		Vector2.DOWN:
			facing = Vector2.DOWN
		Vector2.UP:
			facing = Vector2.UP
		Vector2.RIGHT:
			facing = Vector2.RIGHT
		Vector2.LEFT:
			facing = Vector2.LEFT
		_ :
			pass


func dash() -> void:
	velocity = facing * dash_speed


func run() -> void:
	velocity = facing * run_speed


func useitem1() -> void:
	var i = items[0].instantiate()
	i.player = self
	add_child(i)


func useitem2() -> void:
	var i = items[1].instantiate()
	i.player = self
	add_child(i)


func swing_sword():
	machine.change_state('Sword')


func start_dash():
	machine.change_state('Dash')
	timer.wait_time = dash_time
	timer_state = TimerState.DASH
	timer.start()


func damage(dmg_source: Vector2, dmg_value: int) -> void:
	if machine.current_state.name != 'Hurt':
		machine.change_state('Hurt', {'dmg_source' : dmg_source})
		health -= dmg_value
		if health <= 0:
			die()


func die() -> void:
	queue_free()


func knockback(source: Vector2) -> void:
	timer.wait_time = knockback_time
	var direction = (position - source).normalized()
	velocity = direction * knockback_speed
	timer_state = TimerState.KNOCKBACK
	timer.start()


func timer_end() -> void:
	match timer_state:
		TimerState.KNOCKBACK:
			machine.change_state('Idle')
		TimerState.DASH:
			machine.change_state('Idle')


func animate():
	match animationstate:
		PlayerAnim.WALK:
			play_anim('walk')
		PlayerAnim.SWORD:
			play_anim('sword')
		PlayerAnim.HURT:
			play_anim('hurt')
		PlayerAnim.IDLE:
			play_anim('idle')


func play_anim(anim_name: String) -> void:
	if sprite.animation != anim_name:
		sprite.play(anim_name)


func change_animation(new_animation: String) -> void:
	match new_animation:
		'Walk':
			animationstate = PlayerAnim.WALK
		'Idle':
			animationstate = PlayerAnim.IDLE
		'Hurt':
			animationstate = PlayerAnim.HURT
		'Sword':
			animationstate = PlayerAnim.SWORD
		_:
			animationstate = PlayerAnim.IDLE


func animation_finish() -> void:
	if machine.current_state.name == 'Sword':
		machine.change_state('Idle')

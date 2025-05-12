class_name Player extends CharacterBody2D

var health = 3

@export_category('Node References')
@export var knockback_timer: Timer
@export var sprite: AnimatedSprite2D
@export var machine: StateMachine

@export_category('Scenes')
@export var sword: PackedScene
@export var boots: PackedScene

@export_category('Movement Data')
@export var move_speed: int
@export var knockback_time: float
@export var knockback_speed: int

enum Movement {
	FREE,
	DAMAGE,
	SWORD,
}

enum PlayerAnim {
	WALK,
	SWORD,
	HURT,
	IDLE,
}

var items : Array[PackedScene] = [null, null]

var movestate: Movement
var animationstate: PlayerAnim


func _ready() -> void:
	knockback_timer.wait_time = knockback_time
	movestate = Movement.FREE
	animationstate = PlayerAnim.IDLE
	items[0] = sword
	items[1] = sword


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	read_input()
	animate()
	move_and_slide()


func read_input() -> void:
	if Input.is_action_just_pressed("item1"):
		useitem1()
	elif Input.is_action_just_pressed('item2'):
		useitem2()


func walk() -> void:
	velocity = Input.get_vector('move_left', 'move_right', 'move_up', 'move_down').normalized() * move_speed


func useitem1() -> void:
	var i = items[0].instantiate()
	i.player = self
	add_child(i)


func useitem2() -> void:
	var i = items[1].instantiate()
	i.player = self
	add_child(i)


func swing_sword():
	if movestate == Movement.FREE:
		movestate = Movement.SWORD
		animationstate = PlayerAnim.SWORD


func damage(dmg_source: Vector2, dmg_value: int) -> void:
	if machine.current_state.name != 'Hurt':
		machine.change_state('Hurt', {'dmg_source' : dmg_source})
		health -= dmg_value
		if health <= 0:
			die()


func die() -> void:
	queue_free()


func knockback(source: Vector2) -> void:
	var direction = (position - source).normalized()
	velocity = direction * knockback_speed
	knockback_timer.start()


func knockback_end() -> void:
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
	if sprite.animation == 'sword':
		animationstate = PlayerAnim.IDLE
		movestate = Movement.FREE

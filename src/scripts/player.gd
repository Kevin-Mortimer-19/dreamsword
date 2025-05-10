class_name Player extends CharacterBody2D

var health = 3

@export_category('Node References')
@export var knockback_timer: Timer
@export var sprite: AnimatedSprite2D

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
	if movestate == Movement.FREE or movestate == Movement.SWORD:
		velocity = Vector2(0,0)
		walk()
		if velocity == Vector2(0,0) and animationstate == PlayerAnim.WALK:
			animationstate = PlayerAnim.IDLE
	if Input.is_action_just_pressed("item1"):
		useitem1()
	elif Input.is_action_just_pressed('item2'):
		useitem2()


func walk() -> void:
	var move_flag = false
	if Input.is_action_pressed("move_left"):
		velocity.x -= move_speed
		move_flag = true
	if Input.is_action_pressed("move_right"):
		velocity.x += move_speed
		move_flag = true
	if Input.is_action_pressed("move_up"):
		velocity.y -= move_speed
		move_flag = true
	if Input.is_action_pressed("move_down"):
		velocity.y += move_speed
		move_flag = true
	if move_flag and movestate != Movement.SWORD:
		animationstate = PlayerAnim.WALK


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
	if movestate != Movement.DAMAGE:
		movestate = Movement.DAMAGE
		health -= dmg_value
		if health <= 0:
			die()
		else:
			knockback(dmg_source)


func die() -> void:
	queue_free()


func knockback(source: Vector2) -> void:
	var direction = (position - source).normalized()
	velocity = direction * knockback_speed
	knockback_timer.start()


func knockback_end() -> void:
	movestate = Movement.FREE


func animate():
	match animationstate:
		PlayerAnim.WALK:
			play_anim('walk')
			#sprite.play('walk')
		PlayerAnim.SWORD:
			play_anim('sword')
			#sprite.play('sword')
		PlayerAnim.HURT:
			play_anim('hurt')
			#sprite.play('hurt')
		PlayerAnim.IDLE:
			play_anim('idle')
			#sprite.play('idle')


func play_anim(anim_name: String) -> void:
	if sprite.animation != anim_name:
		sprite.play(anim_name)

func animation_finish() -> void:
	if sprite.animation == 'sword':
		animationstate = PlayerAnim.IDLE
		movestate = Movement.FREE

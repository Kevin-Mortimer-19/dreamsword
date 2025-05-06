class_name Player extends CharacterBody2D

var health = 3

@export_category('Node References')
@export var knockback_timer: Timer
@export var sprite: AnimatedSprite2D

@export_category('Scenes')
@export var sword: PackedScene

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

var movestate: Movement
var animationstate: PlayerAnim


func _ready() -> void:
	knockback_timer.wait_time = knockback_time
	movestate = Movement.FREE
	animationstate = PlayerAnim.IDLE


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	read_input()
	animate()
	move_and_slide()
	#fix_sprite()
	# Adding this code fixes the visual pixel blurring (as best I can tell), 
	# but makes velocity uneven between opposite directions
	#position.x = floorf(position.x)
	#position.y = floorf(position.y)

# This solution to the sprite bug won't work because the Sprite's position is always 0
#func fix_sprite() -> void:
	#sprite.position = Vector2(0,0)
	#sprite.position.x = floorf(position.x)
	#sprite.position.y = floorf(position.y)


func read_input() -> void:
	if movestate == Movement.FREE or movestate == Movement.SWORD:
		velocity = Vector2(0,0)
		walk()
		if velocity == Vector2(0,0) and animationstate == PlayerAnim.WALK:
			animationstate = PlayerAnim.IDLE
	if Input.is_action_just_pressed("ui_accept"):
		swing_sword()


func walk() -> void:
	var move_flag = false
	if Input.is_action_pressed("ui_left"):
		velocity.x -= move_speed
		move_flag = true
	if Input.is_action_pressed("ui_right"):
		velocity.x += move_speed
		move_flag = true
	if Input.is_action_pressed("ui_up"):
		velocity.y -= move_speed
		move_flag = true
	if Input.is_action_pressed("ui_down"):
		velocity.y += move_speed
		move_flag = true
	if move_flag:
		animationstate = PlayerAnim.WALK


func swing_sword():
	if movestate == Movement.FREE:
		movestate = Movement.SWORD
		animationstate = PlayerAnim.SWORD
		var s = sword.instantiate()
		add_child(s)


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
			sprite.play('walk')
		PlayerAnim.SWORD:
			sprite.play('sword')
		PlayerAnim.HURT:
			sprite.play('hurt')
		PlayerAnim.IDLE:
			sprite.play('idle')
	#if movestate == Movement.FREE:
		#if velocity == Vector2(0,0):
			#sprite.play('idle')
		#else:
			#sprite.play('walk')
	#elif movestate == Movement.DAMAGE:
		#sprite.play('hurt')
	#elif movestate == Movement.SWORD:
		#sprite.play("sword")


func animation_finish() -> void:
	if sprite.animation == 'sword':
		animationstate = PlayerAnim.IDLE

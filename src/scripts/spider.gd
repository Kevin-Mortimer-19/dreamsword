extends CharacterBody2D

@export_category("Node References")
@export var sprite: AnimatedSprite2D
@export var move_timer: Timer
@export var ray: RayCast2D
@export var anim_player: AnimationPlayer

@export_category("Movement")
@export var idle_time: float
@export var jump_time: float
@export var crouch_time: float
@export var knockback_time: float

enum State {
	CROUCH,
	IDLE,
	JUMP,
	DAMAGE,
}

var move_state: State

var move_speed = 80
var knockback_speed = 100

var rng = RandomNumberGenerator.new()

var health: int = 3

# Logic for the spider's jump
# next_angle: a candidate for where the spider will jump next
# move_length: (roughly) how far the spider will jump
# wall_distance: how far away a wall can be before the spider will avoid it
# will_jump: boolean used for the state logic when deciding to jump
var next_angle: Vector2
var move_length: float = 48.0
var wall_distance: float = 24.0
var will_jump: bool

var damage_dealt = 1


var move_vectors = [Vector2.UP, 
					Vector2.UP.rotated(deg_to_rad(45)).normalized(), 
					Vector2.DOWN, 
					Vector2.DOWN.rotated(deg_to_rad(45)).normalized(), 
					Vector2.LEFT, 
					Vector2.LEFT.rotated(deg_to_rad(45)).normalized(), 
					Vector2.RIGHT, 
					Vector2.RIGHT.rotated(deg_to_rad(45)).normalized(),
					]


func _ready() -> void:
	move_state = State.IDLE
	sprite.play("idle")
	move_timer.wait_time = idle_time
	move_timer.start()


func _physics_process(_delta: float) -> void:
	if move_state == State.IDLE or move_state == State.CROUCH:
		velocity = Vector2(0,0)
	move_and_slide()
	for i in get_slide_collision_count():
		var c = get_slide_collision(i).get_collider()
		if c is Player:
			c.damage(position, damage_dealt)
		


func start_moving():
	sprite.play("jump")
	match move_state:
		State.CROUCH:
			if will_jump:
				jump()
			else:
				idle()
		State.IDLE:
			crouch()
		State.JUMP:
			idle()
		State.DAMAGE:
			crouch()
	move_timer.start()


func jump():
	sprite.play("jump")
	move_timer.wait_time = jump_time
	velocity = next_angle * move_speed
	move_state = State.JUMP
	anim_player.play("jump")


func idle():
	sprite.play("idle")
	move_timer.wait_time = idle_time
	velocity = Vector2(0,0)
	move_state = State.IDLE
	will_jump = false


func crouch():
	# Try 20 angles, choose the first that meets the following conditions:
	# Within the current camera boundaries
	# Away from a wall if already touching one
	for i in range(20):
		next_angle = choose_angle()
		ray.target_position = next_angle * move_length
		if Map.within_camera_bounds(ray.target_position + position):
			ray.target_position = next_angle * wall_distance
			ray.force_raycast_update()
			if not ray.is_colliding():
				will_jump = true
				break
	sprite.play("crouch")
	move_timer.wait_time = crouch_time
	move_state = State.CROUCH


func choose_angle():
	var choice = rng.randi_range(0, 7)
	return move_vectors[choice]


func die() -> void:
	queue_free()


func damage(dmg_source: Vector2, dmg_value: int) -> void:
	if move_state != State.DAMAGE:
		move_state = State.DAMAGE
		health -= dmg_value
		if health <= 0:
			die()
		else:
			knockback(dmg_source)


func knockback(source: Vector2) -> void:
	var direction = (position - source).normalized()
	velocity = direction * knockback_speed
	move_timer.wait_time = knockback_time
	move_timer.start()

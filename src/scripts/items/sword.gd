extends Item

@export var anim: AnimationPlayer
@export var hitbox: Area2D

var damage = 1


func use():
	player.swing_sword()
	anim.play('swing')
	anim.connect('animation_finished', end_swing)


func end_swing(_name: String) -> void:
	call_deferred('queue_free')


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.damage(hitbox.position, damage)

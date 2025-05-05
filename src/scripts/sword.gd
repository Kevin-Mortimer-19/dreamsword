extends Area2D

@export var anim: AnimationPlayer

var damage = 1


func _ready() -> void:
	anim.play('swing')
	anim.connect('animation_finished', end_swing)


func end_swing(_name: String) -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.damage(position, damage)

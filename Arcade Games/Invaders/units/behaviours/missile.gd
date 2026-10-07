class_name Missile
extends Behaviour

@export var speed = 240

func _process(u: Unit, delta: float):
	move_and_collide(u, u.direction * speed * delta)

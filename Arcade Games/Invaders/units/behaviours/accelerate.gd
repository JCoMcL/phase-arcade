class_name Accelerate
extends Inertial

@export var acceleration: = 10
@export var target_speed: = 240
@export var initial_speed: = 0

func _initialize(u: Unit):
	if initial_speed:
		u.velocity = u.direction * initial_speed

func _process(u: Unit, delta: float):
	u.velocity = u.velocity.move_toward(u.direction * target_speed, acceleration * delta)
	super(u, delta)

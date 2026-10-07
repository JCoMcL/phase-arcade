class_name Bouncy
extends Behaviour

@export_flags_2d_physics var ignore_layers
@export_range(0,1) var bounciness = 1

func _handle_collision(struck_object: Node2D, u: Unit):
	super(struck_object, u)
	if struck_object.collision_layer & ~ignore_layers:
		u.direction.x *= -bounciness
		u.velocity.x *= -bounciness

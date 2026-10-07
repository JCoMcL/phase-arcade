class_name Deadly
extends Behaviour

@export_flags_2d_physics var ignore_layers = 0
@export var damage = 1
@export var take_damage = 1

func _handle_collision(struck_object: Node2D, u: Unit):
	super(struck_object, u)
	if struck_object.collision_layer & ~ignore_layers:
		if "alive" in struck_object and not struck_object.alive:
			return
		if struck_object.has_method("_hit"):
			u.claim_points(struck_object._hit(damage))
		if take_damage:
			u._hit(take_damage)

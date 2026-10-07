class_name Behaviour
extends Resource

@export var play_area_bounded = false

func get_physics(c: PhysicsBody2D) -> PhysicsDirectSpaceState2D:
	return PhysicsServer2D.space_get_direct_state(c.get_world_2d().space)

func _handle_collision(struck_object: Node2D, u: Unit):
	pass

func move_and_collide(u: Unit, motion: Vector2):
	var k = u.move_and_collide(motion)
	if k and k.get_collider():
		u.handle_collision(k.get_collider())

func _initialize(u: Unit):
	pass

func _process(u: Unit, delta: float):
	pass

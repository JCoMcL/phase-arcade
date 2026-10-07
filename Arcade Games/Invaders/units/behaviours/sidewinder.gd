class_name Sidewinder
extends Behaviour

@export var speed = 100 # pixels per second
@export var turn_speed = 10 #radians per second
@export_flags_2d_physics var avoidance_layers = 8
@export var avoidance_scale = 1
var target_direction = Vector2.RIGHT

func turn_radius() -> float:
	var omega: float = float(max(turn_speed, 0.001))
	return (speed / omega)

func test_for_collision(u: Unit) -> bool:
	var pq = PhysicsRayQueryParameters2D.new()
	pq.from = u.global_position
	pq.to = pq.from + u.direction * turn_radius() * avoidance_scale
	pq.collision_mask = avoidance_layers if avoidance_layers else u.collision_mask
	if get_physics(u).intersect_ray(pq):
		return true
	return false

func flip(u: Unit):
	target_direction = Vector2(-u.direction.x, 0).normalized()

func _process(u: Unit, delta: float):
	if not u.direction:
		u.direction = target_direction

	if not is_equal_approx(u.direction.x, target_direction.x):
		u.direction = u.direction.rotated( min(
			abs(target_direction.angle_to(u.direction)),
			abs(turn_speed * delta)
		) * -sign(target_direction.x) )
	else:
		u.direction = target_direction

	if test_for_collision(u):
		flip(u)
	move_and_collide(u, u.direction * speed * delta)

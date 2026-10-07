extends Behaviour
class_name Bomber

@export var interval = 10.0
@export var random_offset = true
@export var require_clear_shot = false
@export var override_shoota: NodePath

var cumer: Cumer
func _initialize(u: Unit):
	cumer = Cumer.new(1.0/interval, shoot.bind(u))
	cumer.add(interval * randf())

func get_shoota(u: Unit) -> Shoota:
	if override_shoota:
		var shoota = u.get_node(override_shoota)
		if shoota is Shoota:
			return shoota
	for c in u.get_children():
		if c is Shoota:
			return c
	print("Warning: Bomber could not find Shoota on %s" % u)
	return null

func shot_blocked_by_friendly(shoota: Shoota, u: Unit) -> bool:
	if not require_clear_shot:
		return false
	var pq = PhysicsRayQueryParameters2D.new()
	pq.from = shoota.global_position
	pq.to = pq.from + Vector2.DOWN * 200
	pq.collision_mask = u.collision_layer
	var result =  get_physics(u).intersect_ray(pq)
	if result:
		return true
	return false

func shoot(u: Unit):
	var shoota = get_shoota(u)
	if shot_blocked_by_friendly(shoota, u):
		cumer.add(interval * 0.9)
		return
	if "target" in u and u.target is Node2D:
		shoota.shoot(u.target)
	else:
		shoota.shoot(Vector2.DOWN)

func _process(u: Unit, delta):
	cumer.add(delta)

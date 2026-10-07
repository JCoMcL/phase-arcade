class_name TestCollision
extends Behaviour

func get_collision_shapes(c: CollisionObject2D) -> Array[CollisionShape2D]:
	var out: Array[CollisionShape2D]
	for child in c.get_children():
		if child is CollisionShape2D:
			out.append(child)
	return out
	#return c.get_children().filter(func(n): return n is CollisionObject2D)

func _process(u: Unit, delta: float):
	for c_shape in get_collision_shapes(u):
		var pq = PhysicsShapeQueryParameters2D.new()
		pq.collision_mask = u.collision_mask
		pq.shape = c_shape.shape
		pq.transform = c_shape.global_transform
		var result = get_physics(u).intersect_shape(pq, 1) #Limit to just one for simplicity

		if result and result[0]["collider"]:
			u.handle_collision(result[0]["collider"])

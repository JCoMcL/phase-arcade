extends Node2D
class_name FauxUnit

@export var behaviours: Array[Behaviour]
@export var auto_free = true

var health: int
var current_health: int

signal expire
signal hit

var alive = true
func _expire():
	if not alive:
		print("Warning: %s: double expire" % self)
		return
	alive = false
	if auto_free:
		queue_free()
	expire.emit()

func _on_unit_expire(u: Node):
	assert(u is Unit or u is FauxUnit)
	current_health -= 1
	hit.emit()
	if current_health <= 0:
		_expire()

var subunits: Array[Node]
func get_units() -> Array[Node]:
	var out: Array[Node]
	for u in subunits:
		if is_instance_valid(u) and (u is Unit or u is FauxUnit) and u.alive:
			out.append(u)
	subunits = out
	return out

func add_subunit(unit: Node, from:Node = self):
	assert(unit is Unit or unit is FauxUnit)
	health += 1
	current_health += 1
	if Engine.is_editor_hint():
		add_child(unit)
	else:
		await InvadersGame.add_to_playfield(unit, from)
		unit.expire.connect(_on_unit_expire.bind(unit), CONNECT_ONE_SHOT)
	subunits.append(unit)

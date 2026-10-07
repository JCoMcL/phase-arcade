@tool
extends FauxUnit
class_name Formation

@export_range(1,20) var rank: int = 1:
	set(val):
		rank = val
		refresh()
@export_range(1,20) var file: int = 1:
	set(val):
		file = val
		refresh()
@export_range(0, 100) var spacing: float:
	set(val):
		spacing = val
		refresh()
@export var staggered: bool:
	set(val):
		staggered = val
		refresh()

enum UnitPattern {SINGLE_UNIT, PATTERN}
@export var using: UnitPattern
@export var unit: PackedScene:
	set(val):
		unit = val
		if val:
			using = UnitPattern.SINGLE_UNIT
			refresh()
@export var unit_pattern: GridPattern:
	set(val):
		unit_pattern = val
		if val:
			using = UnitPattern.PATTERN
			refresh()

var _setup_queued = false
func refresh():
	if not _setup_queued:
		_setup_queued = true
		setup.call_deferred()

var _unit_bounds_cache = {}
func get_unit_bounds(u: Unit, scn: PackedScene) -> Vector2:
	if _unit_bounds_cache.has(scn):
		return _unit_bounds_cache[scn]
	var out = U2ls.localise_rect(U2ls.get_global_rect(u), self).size
	_unit_bounds_cache[scn] = out
	return out

func clean():
	_unit_bounds_cache.clear()
	health = 0
	for c in get_children():
		assert(Engine.is_editor_hint)
		c.free()
	for u in get_units():
		u.free()
	subunits.clear()

func _get_unit(_rank, _file) -> PackedScene:
	if using == UnitPattern.SINGLE_UNIT:
		return unit
	else:
		return unit_pattern.read(_file, _rank)

func setup():
	clean()
	_setup_queued = false
	if not unit and not unit_pattern:
		return

	var formation_size: Vector2
	for i in range(rank):
		var rank_size: Vector2
		var rank_units: Array[Unit]
		for j in range(file):
			var scn = _get_unit(i, j)
			var u: Unit = scn.instantiate()
			await add_subunit(u)
			var unit_bounds = get_unit_bounds(u,scn)
			rank_units.append(u)
			# Postitioning
			u.position = Vector2(
				rank_size.x + unit_bounds.x / 2,
				-(formation_size.y + unit_bounds.y /2)
			)
			if u.get_parent() != self:
				u.position += position
			rank_size.x += unit_bounds.x
			rank_size.y = max(rank_size.y, unit_bounds.y)
			if rank_size.x > formation_size.x and i > 1:
				break
		if not formation_size.x:
			formation_size.x = rank_size.x
		formation_size.y += rank_size.y

		var discrepency = rank_size.x - formation_size.x
		for u in rank_units:
			u.position.x -= discrepency / 2
	current_health = health

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	for b in behaviours:
		for u in get_units():
			if is_instance_valid(u):
				b._process(u, delta)
			else:
				print("Err: fix you shit")

func _ready():
	setup()
	if not Engine.is_editor_hint():
		for b in behaviours:
			for u in get_units():
				b._initialize(u) #NOTE: this happens BEFORE the units' _ready becuase they've just been created

@tool
extends Area2D
class_name PlayArea

@export_range(0, 2000) var width = 512:
	set(w):
		width = w
		refresh()

@export_range(0, 2000) var height = 480:
	set(h):
		height = h
		refresh()

@export_range(0, 480) var top_padding = 24:
	set(p):
		top_padding = min(p, height-bottom_padding-24)
		refresh()

@export var bottom_padding = 12:
	set(p):
		bottom_padding = min(p, height-top_padding-12)
@export var ceiling = true:
	set(b):
		if not b and has_node("UpWall"):
			$UpWall.free()
		ceiling = b
		refresh()
@export var left_wall = true:
	set(b):
		if not b and has_node("LeftWall"):
			$LeftWall.free()
		left_wall = b
		refresh()
@export var right_wall = true:
	set(b):
		if not b and has_node("RightWall"):
			$RightWall.free()
		right_wall = b
		refresh()

@export_tool_button("refresh") var f = refresh

## Expose components for viewing and editing.
## May cause strange bugs if left on
@export var viewable: bool = false:
	set(b):
		viewable = b
		refresh()

func refresh():
	if not _set_up:
		return
	if Engine.is_editor_hint():
		setup_region.call_deferred()

func get_component(path: NodePath, type: Variant) -> Node:
	var out = get_node_or_null(path)
	if not out:
		out = type.new()
		out.name = path.get_name(path.get_name_count() -1)
		var parent = self
		if path.get_name_count() > 1:
			parent = get_node(NodePath(path.get_name(path.get_name_count() - 2)))

		parent.add_child(out)

	elif typeof(out) != typeof(type):
		out.free()
		return get_component(path, type)

	out.owner = get_tree().edited_scene_root if viewable else null
	return out

func get_inner_shape() -> CollisionShape2D:
	return get_component("CollisionShape2D", CollisionShape2D)

func get_wall(d: int) -> StaticBody2D:
	return get_component("%sWall" % Direction.pretty(d), StaticBody2D)

func get_wall_collider(d: int) -> CollisionShape2D:
	return get_component("%sWall/CollisionShape2D" % Direction.pretty(d), CollisionShape2D)

func get_background() -> ColorRect:
	return get_component("Background", ColorRect)

func get_foreground() -> Control:
	return get_component("Foreground", Control)

func get_header() -> Control:
	return get_component("Header", Control)

func set_region(w,h):
	var end = Vector2(w,h)
	var center = end / 2
	var end_pad = Vector2(0, top_padding)
	var center_pad = end_pad / 2

	var header = get_header()
	header.size = Vector2(w,top_padding)
	header.position = Vector2.ZERO
	header.z_index = 1

	var shape = get_inner_shape()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = end - end_pad
	shape.position = center + center_pad
	shape.visible = false

	var background = get_background()
	background.size = (end - end_pad) / 2
	background.scale = Vector2.ONE * 2
	background.z_index = -10
	background.position.y = top_padding

	var foreground = get_foreground()
	foreground.size = end /2
	foreground.scale = Vector2.ONE * 2
	foreground.z_index = 1
	foreground.position = Vector2.ZERO

	var active_walls = [ceiling, true, left_wall, right_wall]
	for direction in Direction.each:
		if active_walls[direction]:
			var wall = get_wall(direction)
			wall.position = Direction.to_vec(direction) * (center - center_pad) + center + center_pad
			wall.collision_layer = Layers.combined("2d_physics", ["World", ["Ceiling", "Floor", "Walls", "Walls"][direction]])
			var wall_collider = get_wall_collider(direction)
			wall_collider.shape = WorldBoundaryShape2D.new()
			wall_collider.rotation = Direction.to_radians(direction) - (PI /2)
			wall_collider.one_way_collision = true
			wall_collider.one_way_collision_margin = 50

	var ground = get_wall(Direction.DOWN)
	ground.position.y -= bottom_padding

func setup_region():
	set_region(width, height)

func _on_body_exited(body: Node2D):
	if body.has_method("_on_exit_play_area"):
		body._on_exit_play_area()

func _on_body_entered(body: Node2D):
	if body.has_method("_on_enter_play_area"):
		body._on_enter_play_area()

var _set_up = false
func _ready():
	setup_region()
	_set_up = true
	collision_layer = Layers.physics2D["PlayArea"]
	collision_mask = Layers.physics2D["AreaBounded"]
	monitoring = true
	if not Engine.is_editor_hint():
		body_exited.connect(_on_body_exited)
		body_entered.connect(_on_body_entered)

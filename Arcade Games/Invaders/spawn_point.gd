@tool
extends Marker2D
class_name SpawnPoint

@export_range(-100,200,2, "suffix:%") var x = 50:
	set(val):
		x = val
		set_pos()
@export_range(-100,200,2, "suffix:%") var y = 50:
	set(val):
		y = val
		set_pos()
@export var mirrored = false:
	set(b):
		mirrored = b
		if mirrored and not mirror:
			setup_mirror()
		elif mirror and not mirrored:
			mirror.free()
@export_tool_button("recalc") var f = set_xy

var mirror: SpawnPoint
func setup_mirror():
	if not is_node_ready():
		await ready
	if not mirror:
		mirror = SpawnPoint.new()
		mirror.name = "%s_M" % name
		get_parent().add_child.call_deferred(mirror)
	mirror.x = 100 -x
	mirror.y = y

func get_play_area_rect():
	var game = Game.get_game(self)
	if game:
		var play_area = game.play_area
		if play_area:
			return U2ls.get_global_rect(play_area)
	return null

func set_xy():
	var r = get_play_area_rect()
	if r:
		var v = Vector2(global_position - r.position) * 100 / r.size
		lock = true
		x = v.x
		y = v.y
		lock = false
	if mirror:
		setup_mirror()

var lock = false
func set_pos():
	if not is_node_ready():
		return
	if lock:
		return
	var r = get_play_area_rect()
	if r:
		global_position = r.position + r.size * (Vector2(x,y)/100)
	if mirror:
		setup_mirror()

func _ready() -> void:
	set_pos()
	if Engine.is_editor_hint():
		item_rect_changed.connect(set_xy)

extends EffectSprite2D
class_name CharacterSprite2D

@export_range(0,16) var speed_frames: int = 0
@export_range(0,1000) var speed_start:float = 0.0
@export_range(0,3000) var speed_end:float = 1000.0
@export var vertical_speed_only = false
@export var directional_hflip = false
@export var directional_vflip = false
@export var directional_rotate = false
@export_range(0,16) var damage_frames: int = 0
@export var evil_mode = false:
	set(b):
		evil_mode = b
		material.set_shader_parameter("apply_palette", evil_mode)
@export var action_pose_offset = 0
@export var action_pose = false:
	set(b):
		if b and frame < action_pose_offset:
			frame += action_pose_offset
		if not b and frame >= action_pose_offset:
			frame -= action_pose_offset
		action_pose = b

@onready var unit: Unit = get_parent()

func set_speed_frame(delta: float):
	assert(speed_frames > 1)
	var speed_sqr = unit.velocity.y ** 2 if vertical_speed_only else unit.velocity.length_squared()
	var _frame = 0
	var speed_interval = (speed_end - speed_start) / speed_frames
	for i in range(speed_frames):
		if speed_sqr <= (speed_start + speed_interval * i) ** 2:
			break
		_frame += 1

	frame = min(_frame, speed_frames-1)

func advance_damage():
	var d = damage_frames-1
	frame = d - d * unit.current_health / unit.health

var initial_hflip: bool
var initial_vflip: bool
func _ready() -> void:
	super()
	initial_hflip = flip_h
	initial_vflip = flip_v
	if damage_frames and not Engine.is_editor_hint():
		unit.hit.connect(advance_damage)

func get_direction() -> Vector2:
	if not unit:
		return Vector2.ZERO
	if unit.velocity != Vector2.ZERO:
		return unit.velocity
	if "direction" in unit: #this should always be true but for some reason isn't
		return unit.direction
	return Vector2.ZERO

func _process(delta: float):
	if directional_hflip:
		if get_direction().x > 0:
			flip_h = initial_hflip
		elif get_direction().x < 0:
			flip_h = !initial_hflip
	if directional_vflip:
		if get_direction().y < 0:
			flip_v = initial_vflip
		elif get_direction().y > 0:
			flip_v = !initial_vflip
	if directional_rotate:
		material.set_shader_parameter("rotation", get_direction().angle()+PI/2)
	if speed_frames:
		set_speed_frame(delta)
	super(delta)

func _get_configuration_warnings() -> PackedStringArray:
	var out = []
	var p = get_parent()
	if not p or p is not Unit:
		out.append("Parent must by Unit")
	return out

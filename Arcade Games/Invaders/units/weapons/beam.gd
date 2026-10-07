extends Unit

@export var max_range = 1000
@export_range(0.001, 20, 0.1, "suffix:Hz") var hitrate = 1.0

var line: Line2D
var pq: PhysicsRayQueryParameters2D
var contact_effect: VFXSprite
func _ready():
	super()
	pq = PhysicsRayQueryParameters2D.new()
	line = $Line2D
	#line.texture = get_sprite().texture
	line.clear_points()
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.ZERO)

func wakeup():
	super()
	if not contact_effect:
		contact_effect = VFX.play_looping("scorch", self)
		contact_effect.flip_v = true
		InvadersGame.add_to_playfield(contact_effect, self)

func _expire():
	if contact_effect:
		contact_effect.stop()
		contact_effect = null
	super()

@onready var damage_cumer: Cumer = Cumer.new(hitrate)
func _physics_process(delta: float) -> void:
	super(delta)
	pq.from = global_position
	var endpoint = direction.normalized() * max_range
	pq.to = pq.from + endpoint
	pq.collision_mask = collision_mask
	var result = get_world_2d().direct_space_state.intersect_ray(pq)
	if result:
		endpoint = result.position - global_position
		damage_cumer.add(delta)
		for i in range(damage_cumer.cycles_accumulated()):
			handle_collision(result.collider)
	else:
		damage_cumer.reset()

			#await Vfx.play("pop", self, line.get_point_position(1))
	line.set_point_position(1, endpoint / global_scale)
	contact_effect.global_position = global_position + (line.get_point_position(1) * global_scale)

func _get_configuration_warnings():
	var out = super()
	if not (has_node("Line2D") and $Line2D is Line2D):
		out.append("no Line2D")
	return out

extends Shoota
class_name OrbThrower

@export_range(0.0, 10.0, 0.01, "suffix:s") var respawn_delay = 0.2
enum {ORBITING, WIND_UP, LAUNCHING, PASSIVE}
var bullet_state: Dictionary

func _on_bullet_expire(b: Unit):
	b.velocity = Vector2.ZERO
	await spawn_bullet() #this is probably the same bullet
	assert(bullet_state.size() == ammo_count)

func shoot(towards:Variant=default_direction, parent_to:Node=null, mask:int=-1) -> Unit:
	for b in bullet_state.keys():
		if bullet_state[b] == ORBITING:
			bullet_state[b] = WIND_UP
			return b
	return null

func _physics_process(delta: float) -> void:
	for b in bullet_state.keys():
		match bullet_state[b]:
			ORBITING:
				b.velocity += (global_position - b.global_position) * delta * 40
				b.velocity *= 0.8
			WIND_UP:
				if b.velocity.y < 140:
					b.velocity.y += 900 * delta
				else:
					bullet_state[b] = LAUNCHING
			LAUNCHING:
				if b.velocity.y > -600:
					b.velocity.y -= 1600 * delta
				else:
					bullet_state[b] = PASSIVE

func spawn_bullet():
	if parent and not parent.alive:
		return #cancel if our owner is dead

	if cooldown_countdown > 0:
		await cooled_down
	if respawn_delay > 0:
		await Utils.delay(respawn_delay)
	var b = await super.shoot()
	if not is_instance_valid(b): #This occurs when the game is quitting
		return
	b.expire.connect(_on_bullet_expire.bind(b), CONNECT_ONE_SHOT)
	bullet_state[b] = ORBITING
	if autoshoot:
		shoot(default_direction)

func _ready() -> void:
	super()
	autoshoot_in_loop = false
	for i in range(ammo_count):
		await spawn_bullet()

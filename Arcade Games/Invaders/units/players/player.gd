extends Unit
class_name Player

@export var acceleration = 1800
@export var speed = 240
@export var auto_ground = true
@export var death_sfx: StringName = "beyum"

@export var bomb_cooldown = 0.0
@export var bomb_count = 1 # not implemented
@export var bomb_icon = BombIndicator.Icons.STAR
@export_range(0.0001, 0.1, 0.0001, "suffix:f/px") var walk_rate = 0.03:
	set(f):
		walk_rate = f
		walk_cumer = Cumer.new(walk_rate)

var shoota: Shoota
var bomba: Shoota
var bomb_countdown: float

func get_speed_modifiers() -> float:
	var out = 1.0
	if shoota:
		out *= shoota.get_speed_modifier()
	if bomba:
		out *= bomba.get_speed_modifier()
	return out

func _physics_process(delta):
	super(delta)
	var _acceleration = acceleration if alive else 2400 if is_on_floor() else 800
	velocity.x = move_toward(velocity.x, direction.x * speed * get_speed_modifiers(), _acceleration * delta)
	velocity += get_gravity() * delta
	move_and_slide()
	if sign(direction.x) == sign(velocity.x):
			get_sprite().flip_h = (direction.x < 0)

func _unhandled_input(ev: InputEvent):
	if not alive:
		return
	if ev.is_action_pressed("fire"):
		shoota.shoot(Vector2.UP)
	elif ev.is_action_pressed("bomb"):
		bomb()

var invulnerable = false
func grace_window(seconds:float=2):
	var sprite = get_sprite()
	invulnerable = true
	sprite.strobe_rate = 8
	sprite.reset()
	await Utils.delay(seconds)
	invulnerable = false
	sprite.strobe_rate = 0
	sprite.reset()
	sprite.visible = true

func _hit(damage:int=0) -> int:
	if not invulnerable:
		return super(damage)
	return 0

func wakeup():
	grace_window()
	super()
	reset_bomb_cooldown()
	if auto_ground:
		move_and_collide(Vector2.DOWN * 1000)
		reset_physics_interpolation()
	collision_layer = Layers.physics2D["Friendly"]

func claim_points(points: int):
	super(points)
	var game = Game.get_game(self)
	if game:
		game.add_score(points)

func _ready():
	super()
	shoota = $Shoota
	for c in get_children():
		if c is Shoota:
			c.points_claimed.connect(claim_points)
			if c.name == "Bomb":
				bomba = c
	if can_process():
		var game = Game.get_game(self)
		if game:
			Game.get_game(self).set_active_player(self)

func bomb_active_time():
	return bomb_cooldown - bomb_countdown
func reset_bomb_cooldown():
	bomb_countdown = bomb_cooldown

var active_bomb: Node
func bomb() -> bool:
	if bomb_countdown > 0:
		return false
	if has_node("Bomb") and $Bomb is Shoota:
		active_bomb = await $Bomb.shoot()
	reset_bomb_cooldown()
	return true

func _expire():
	super()
	velocity = Vector2(
		600 * (1 if get_sprite().flip_h else -1),
		-200
	)
	Game.play_sfx(self, death_sfx)
	collision_layer = Layers.physics2D["Dead"]

enum Frames {
	PORTRAIT, PROFILE, WALK0, WALK2, WALK3, WALK_END, SKID, REEL, GRAVE, SPECIAL
}
func on_frame_changed(frame: int):
	if frame == Frames.GRAVE:
		Game.play_sfx(self, "crunch")
		process_mode = Node.PROCESS_MODE_DISABLED

func walk_frame(i: int) -> int:
	if i >= Frames.WALK0 and i <= Frames.WALK_END:
		return i
	return Frames.WALK0

var walk_cumer = Cumer.new(walk_rate)
func choose_frame(delta: float) -> int:
	var spd = abs(velocity.x)
	if not alive:
		if spd > 50 or not is_on_floor():
			return Frames.REEL
		return Frames.GRAVE

	if sign(direction.x) != sign(velocity.x) and spd > 0:
		return Frames.SKID
	if spd > speed * 0.5:
		var wlk = walk_frame(get_sprite().frame)
		walk_cumer.add(spd * delta)
		for i in walk_cumer.cycles_accumulated():
			wlk = walk_frame(wlk + 1)
		return wlk
	if spd > 1:
		return Frames.PROFILE
	return Frames.PORTRAIT

func _process(delta):
	shoota.autoshoot=ArcadeCabinet.get_input_state(self).firing and alive
	if alive:
		if bomb_countdown > 0:
			bomb_countdown = bomb_countdown - delta
		if bomb_countdown < 0: #rare case where it's exactly zero and this doesn't trigger
			Game.play_sfx(self, "blip")
			bomb_countdown = 0
		direction.x = ArcadeCabinet.get_input_state(self).movement.x
	else:
		direction = Vector2.ZERO
	get_sprite().frame = choose_frame(delta)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = super()
	if not has_node("Shoota") or $Shoota is not Shoota:
		warnings.append("no Shoota")

	return warnings

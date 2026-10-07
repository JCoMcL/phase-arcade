extends Player

func be_invulernerable_for(seconds: float):
	invulnerable = true
	await Utils.delay(seconds)
	invulnerable = false

func bomb() -> bool:
	if await super():
		var dash_direction = sign(direction.x)
		if not dash_direction:
			dash_direction = (-1 if get_sprite().flip_h else 1)
		velocity.x = 1200 * dash_direction
		get_sprite().visible = false
		Game.play_sfx(self, "swish")
		be_invulernerable_for(0.4)
		await Utils.delay(0.1)
		get_sprite().visible = true

		return true
	return false

func choose_frame(delta) -> int:
	if alive and abs(velocity.x) > 800:
		return Frames.SPECIAL
	return super(delta)

func _process(delta):
	super(delta)
	if bomb_active_time() < 0.1:
		shoota.autoshoot = false

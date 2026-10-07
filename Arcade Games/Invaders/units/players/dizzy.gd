extends Player

func is_bomb_active() -> bool:
	return active_bomb and active_bomb.alive

func choose_frame(delta: float) -> int:
	if is_bomb_active():
		return Frames.SPECIAL
	return super(delta)

func _physics_process(delta):
	if is_bomb_active():
		velocity += get_gravity() * delta * -1.01
		velocity.x = 0
	super(delta)

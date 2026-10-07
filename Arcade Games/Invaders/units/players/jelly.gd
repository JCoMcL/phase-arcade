extends Player

func reset_bomb_cooldown():
	if active_bomb and active_bomb.alive:
		active_bomb.expire.connect(reset_bomb_cooldown, Node.CONNECT_ONE_SHOT)
		return
	super()

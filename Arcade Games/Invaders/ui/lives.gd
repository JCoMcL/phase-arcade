@tool
extends Control
class_name Lives

func get_life_containers() -> Array[LifeContainer]:
	var out: Array[LifeContainer]
	for c in get_children():
		if c is LifeContainer:
			out.append(c)
	return out

func get_life() -> Unit:
	for c in get_life_containers():
		var l = c.life
		if l and l.alive:
			return l
	return null

func add_life(life: Unit) -> LifeContainer:
	for c in get_life_containers():
		if not c.life:
			c.life = life
			return c
	return null

func reclaim_life(dead_life: Unit) -> LifeContainer:
	for c in get_life_containers():
		if c.life == dead_life:
			if dead_life.get_parent():
				dead_life.get_parent().remove_child(dead_life)
			c.revive()
			return c
	return null

func clear_lives():
	for c in get_life_containers():
		c.life = null
		c.life_scene = null

func is_filled() -> bool:
	for c in get_life_containers():
		if not c.life:
			return false
	return true

func has_life() -> bool:
	for c in get_life_containers():
		if c.life:
			return true
	return false

func commune(with: Lives):
	var ours = get_life_containers()
	var theirs = with.get_life_containers()
	for i in range(ours.size()):
		theirs[i].life = ours[i].life

func _ready():
	var game = Game.get_game(self)
	if game and not game.lives:
		game.lives = self

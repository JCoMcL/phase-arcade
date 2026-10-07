@tool
extends SpawnPoint

func _ready():
	super()
	var game: Game = Game.get_game(self)
	if game and not game.player_spawn_point:
		game.player_spawn_point = self

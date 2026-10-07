extends Label

func _on_win():
	text = "You Win!"

func _on_lose():
	text = "Game Over"

func _ready():
	text = ""
	Game.get_game(self).win.connect(_on_win)
	Game.get_game(self).lose.connect(_on_lose)

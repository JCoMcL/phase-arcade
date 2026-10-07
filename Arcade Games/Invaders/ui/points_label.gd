extends Label

func set_score(i: int):
	text = "%03d" % i

func _ready():
	Game.get_game(self).score_changed.connect(set_score)

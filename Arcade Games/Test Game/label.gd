extends Label

var time:float = 0
func _process(delta: float) -> void:
	time += delta
	rotation = sin(time) * 0.5
	scale = Vector2.ONE * (1 + sin(time * 2 - 2.8) * 0.2)

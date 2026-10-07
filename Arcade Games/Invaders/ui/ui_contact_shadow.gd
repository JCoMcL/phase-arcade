extends UITextureRect

func refresh(l: LifeContainer):
	show_as_focused = l.life != null

func _ready():
	var n = get_parent()
	if n and n is LifeContainer:
		n.life_changed.connect(refresh.bind(n))
		refresh(n)

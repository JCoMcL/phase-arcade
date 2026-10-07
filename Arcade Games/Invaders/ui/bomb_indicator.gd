extends HBoxContainer
class_name BombIndicator

@export var player: Player:
	set(p):
		player = p
		draw_icons(p)

func set_player(p: Player):
	player = p

enum Icons{CROSS,STAR,GUST,FLAME}

func new_icon():
	var ico = TextureRect.new()
	ico.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	ico.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	ico.texture = HandyAtlas.new()
	ico.texture.atlas = load("res://Arcade Games/Invaders/units/players/bomb_icons.png")
	ico.texture.region.size = Vector2(8,8)
	return ico

func draw_icons(p: Player):
	for c in get_children():
		c.free()
	if not p:
		return
	for i in range(p.bomb_count):
		var ico = new_icon()
		ico.texture.set_xy(0, p.bomb_icon)
		add_child(ico)

func _ready():
	alignment = BoxContainer.ALIGNMENT_CENTER
	var game = Game.get_game(self)
	if game:
		if game.current_player:
			draw_icons(game.current_player)
		game.player_changed.connect(set_player)

func _process(delta):
	if player and player.alive:
		var ico = get_child(0)
		var shade: float
		if player.bomb_countdown:
			shade = lerp(0.6, 0.3, player.bomb_countdown / player.bomb_cooldown)
		else:
			shade = 1.0
		ico.modulate = Color(shade, shade, shade)

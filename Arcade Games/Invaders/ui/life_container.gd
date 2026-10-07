extends TextureRect
class_name LifeContainer

@export_range(1,3,1) var scaling = 1:
	set(val):
		scaling=val
		refresh()
var life: Unit:
	set(val):
		life = val
		refresh()
@export var life_scene: PackedScene:
	set(val):
		if val:
			life = val.instantiate()
		else:
			life = null
		life_scene = val

signal life_changed
func refresh():
	setup_life.call_deferred()
	life_changed.emit()

func setup_life():
	if not life:
		texture = null
		return
	var sprite = life.get_sprite()
	texture = HandyAtlas.new()
	texture.atlas = sprite.texture

	var sprite_size = sprite.texture.get_size() / Vector2(sprite.hframes, sprite.vframes)
	texture.region.size = sprite_size

	scale = Vector2.ONE * scaling
	var f = _on_life_sprite_change.bind(life)
	if not sprite.frame_changed.is_connected(f):
		sprite.frame_changed.connect(f, Node.CONNECT_ONE_SHOT)

func revive():
	if life and not life.alive:
		life.alive = true
		texture.set_xy(0,0)

func _on_life_sprite_change(p: Player):
	if p != life:
		return
	var sp:Sprite2D = p.get_sprite()
	sp.frame_changed.connect(_on_life_sprite_change.bind(life), Node.CONNECT_ONE_SHOT)
	if texture:
		assert(texture is HandyAtlas)
		if sp.frame == Player.Frames.GRAVE:
			texture.set_xy(Player.Frames.GRAVE, 0)
		else:
			texture.set_xy(0,0)

func _ready():
	size_flags_horizontal = Control.SIZE_EXPAND
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	if life_scene:
		life = life_scene.instantiate()
		setup_life()
	custom_minimum_size = Vector2i.ONE * 32

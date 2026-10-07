extends TextureRect
class_name UITextureRect

@export var show_as_focused = false:
	set(b):
		show_as_focused = b
		if b:
			show_focus_overlay()
		else:
			hide_focus_overlay()

static var atlas_height = 64

func on_gain_focus(focus_parent: Control):
	show_focus_overlay()
	focus_parent.focus_exited.connect(hide_focus_overlay, CONNECT_ONE_SHOT)

func listen_for_focus():
	var p = self
	while p and p is Control:
		p.focus_entered.connect(on_gain_focus.bind(p))
		p = p.get_parent()

func _ready() -> void:
	if not texture:
		texture = AtlasTexture.new()
		texture.atlas = load("res://Arcade Games/Invaders/ui/ui.png")
	listen_for_focus()

func create_focus_overlay() -> TextureRect:
	var t = TextureRect.new()
	t.texture = texture.duplicate()
	assert(t.texture is AtlasTexture)
	t.texture.region.position.y += atlas_height
	return t

var focus_overlay: TextureRect
func show_focus_overlay():
	if not focus_overlay:
		focus_overlay = create_focus_overlay()
		focus_overlay.visible = false
		add_child(focus_overlay)
	focus_overlay.visible = true

func hide_focus_overlay():
	if focus_overlay:
		focus_overlay.visible = false

static func branch_has_focus(from: Control) -> bool:
	if from.has_focus():
		return true
	var p = from.get_parent()
	if p and p is Control:
		return branch_has_focus(p)
	return false

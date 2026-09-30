@tool
extends CollisionObject3D

signal interacted
signal interacted_by(Node3D)

@export var tooltip:String = "[LMB] interact":
	set(s):
		tooltip = s
		if is_node_ready():
			%Label.text = s

@export var rotate_tooltip = false
@export var active = true:
	set(b):
		active = b
		visible = b
		collision_layer = Layers.physics3D["Interactive"] if b else 0
@export var oneshot = false
@export var debug = false

func _ready() -> void:
	%Label.text = tooltip
	if not Engine.is_editor_hint():
		collision_layer = Layers.physics3D["Interactive"] if active else 0
		$Tooltip.modulate.a = 0

var hover_timer:float = 0
func hover(observer: Node3D):
	hover_timer = 0.2
	var pos_difference = observer.global_position - global_position
	if rotate_tooltip:
		$Tooltip.rotation.y = atan2(pos_difference.x, pos_difference.z)
	pass

func interact(operator: Node3D):
	print(self, "interacted with")
	interacted.emit()
	interacted_by.emit(operator)
	if oneshot:
		active = false

func _process(delta):
	if Engine.is_editor_hint():
		return

	if hover_timer > 0:
		hover_timer -= delta
	var hovered = hover_timer > 0
	$Tooltip.modulate.a = move_toward(
		$Tooltip.modulate.a,
		0.2 if hovered or debug else 0.0,
		1.2 * delta
	)
	var tooltip_visible = $Tooltip.modulate.a > 0
	$Tooltip.visible = tooltip_visible

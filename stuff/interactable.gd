@tool
extends CollisionObject3D

signal interacted 

@export var shape:Shape3D:
	set(s):
		if not is_node_ready():
			await ready
		$CollisionShape3D.shape = s
	get():
		if not is_node_ready():
			await ready
		return $CollisionShape3D.shape

func _ready() -> void:
	if not Engine.is_editor_hint():
		collision_layer = Layers.physics3D["Interactive"]

func interact():
	print(self, "interacted with")
	interacted.emit()

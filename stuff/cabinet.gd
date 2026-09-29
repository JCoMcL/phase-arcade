extends Node3D
class_name ArcadeCabinet

func _interacted_by(operator:FirstPersonCharacter):
	operator.set_active_cabinet(self)

func get_observation_point() -> CameraTransform:
	return CameraTransform.new(%ObservationPoint)

func _ready() -> void:
	$Screen.texture = $SubViewport.get_texture()
	%ScreenInteractZone.interacted_by.connect(_interacted_by)

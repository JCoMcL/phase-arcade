extends Object
class_name CameraTransform

var position:Vector3
var rotation:Vector3
var fov:float

func _init(to:Camera3D, from:Camera3D=null):
	position = to.global_position
	rotation = to.global_rotation
	fov = to.fov

	if from:
		position -= from.global_position
		rotation -= from.global_rotation
		fov -= from.fov

func apply_absolute(cam:Camera3D):
	cam.global_position = position
	cam.global_rotation = rotation
	cam.fov = fov

func apply_relative(cam:Camera3D):
	cam.global_position += position
	cam.global_rotation += rotation
	cam.fov += fov

extends RefCounted
class_name CameraTransform

const TRANSITION_TIME := 0.3

var position:Vector3
var rotation:Vector3
var fov:float

func _init(to:Camera3D, from:Camera3D=null):
	if not to:
		return
	position = to.global_position
	rotation = to.global_rotation
	fov = to.fov

	if from:
		position -= from.global_position
		rotation -= from.global_rotation
		fov -= from.fov


func inverse() -> CameraTransform:
	var out = CameraTransform.new(null)
	out.position = -position
	out.rotation = -rotation
	out.fov = -fov
	return out

func apply_absolute(cam:Camera3D):
	cam.global_position = position
	cam.global_rotation = rotation
	cam.fov = fov
	cam.reset_physics_interpolation()

func apply_relative(cam:Camera3D):
	cam.global_position += position
	cam.global_rotation += rotation
	cam.fov += fov
	cam.reset_physics_interpolation()

func transition_absolute(cam:Camera3D, duration:float=TRANSITION_TIME) -> Tween:
	var from = CameraTransform.new(cam)
	var tween = cam.create_tween()
	var blend = tween.tween_method(_blend.bind(cam, from, self), 0.0, 1.0, duration)
	blend.set_trans(Tween.TRANS_SINE)
	blend.set_ease(Tween.EASE_IN_OUT)
	return tween

func transition_relative(cam:Camera3D, duration:float=TRANSITION_TIME) -> Tween:
	var from = CameraTransform.new(cam)
	var tween = cam.create_tween()
	var blend = tween.tween_method(_blend_relative.bind(cam, from, self), 0.0, 1.0, duration)
	blend.set_trans(Tween.TRANS_SINE)
	blend.set_ease(Tween.EASE_IN_OUT)
	return tween

func _blend(t:float, cam:Camera3D, from:CameraTransform, to:CameraTransform):
	cam.global_position = from.position.lerp(to.position, t)
	cam.global_rotation = Vector3(
		lerp_angle(from.rotation.x, to.rotation.x, t),
		lerp_angle(from.rotation.y, to.rotation.y, t),
		lerp_angle(from.rotation.z, to.rotation.z, t)
	)
	cam.fov = lerpf(from.fov, to.fov, t)

func _blend_relative(t:float, cam:Camera3D, from:CameraTransform, to:CameraTransform):
	from.apply_absolute(cam)
	var step = CameraTransform.new(null)
	step.position = to.position * t
	step.rotation = to.rotation * t
	step.fov = to.fov * t
	step.apply_relative(cam)

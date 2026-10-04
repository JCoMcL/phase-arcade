extends RefCounted
class_name CameraTransform

const TRANSITION_TIME := 0.3

var transform:Transform3D
var position:Vector3
var fov:float
var from_basis := Basis.IDENTITY

func _init(to:Camera3D, from:Camera3D=null):
	if not to:
		return
	transform = Transform3D(to.get_global_basis())
	position = to.get_global_position()
	fov = to.fov

	if from:
		from_basis = from.get_global_basis()
		transform *= Transform3D(from_basis).inverse()
		position -= from.get_global_position()
		fov -= from.fov


func inverse() -> CameraTransform:
	var out = CameraTransform.new(null)
	out.transform = transform.inverse()
	out.position = -position
	out.fov = -fov
	return out

func apply_absolute(cam:Camera3D):
	cam.global_transform = Transform3D(transform.basis, position)
	cam.fov = fov
	cam.reset_physics_interpolation()

func apply_relative(cam:Camera3D):
	# not implemented
	pass

func yaw(angle:float):
	transform = transform.rotated(Vector3.UP, angle)
func pitch(angle:float):
	transform = transform.rotated_local(Vector3.RIGHT, angle)
func yaw_and_pitch(v:Vector2):
	yaw(v.x)
	pitch(v.y)

func blend_relative(target:CameraTransform, cam:Camera3D, factor:float):
	var t := clampf(factor, 0.0, 1.0)
	var delta := Basis(Quaternion.IDENTITY.slerp(target.transform.basis.get_rotation_quaternion(), t))
	# the relative transform goes on the left: at t == 1 this is the target's basis, exactly
	cam.global_transform = Transform3D(delta * transform.basis, position + target.position * t)
	cam.fov = fov + lerpf(0.0, target.fov, t)
	cam.reset_physics_interpolation()

## How far `aim` has turned from the orientation this transform was captured relative to.
func angle_from(aim:Basis) -> float:
	return rad_to_deg(
		from_basis.get_rotation_quaternion()
		.angle_to(aim.get_rotation_quaternion())
	)

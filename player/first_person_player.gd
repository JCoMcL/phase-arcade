@tool
extends CharacterBody3D

const speed = 3.0
const accel = 20.0

@export_range(0.2, 2.0, 0.01) var mouse_sensitivity:float = 1

@export var height = 1.6:
	set(val):
		height = val
		setup_children()
@export var width = 0.5:
	set(val):
		width = val
		setup_children()

var height_mod = 1.0

func setup_children() -> void:
	if not is_node_ready():
		# the above setters will trigger this early, so we have to wait until our children come home
		await ready 

	var _height:float = height * height_mod
	$Camera3D.position.y = max(_height - 0.3, _height * 0.8)
	var col:CapsuleShape3D = $CollisionShape3D.shape
	col.radius = width/2
	col.height = _height
	$CollisionShape3D.position.y = _height / 2

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	velocity += get_gravity() * delta

	# TODO: collision check when unchrouching
	# TODO: smooth motion
	var crouching = Input.is_action_pressed("crouch")
	const crouch_speed:float = 4
	height_mod = move_toward(height_mod, 0.4 if crouching else 1.0, crouch_speed * delta)
	setup_children()
	

	var walk_input := Input.get_vector("left", "right", "forward", "backward").normalized()
	var walk = walk_input.rotated(-rotation.y) * speed * (0.4 if crouching else 1.0)

	# maybe this should be relative to the floor normal, but probably doesn't matter
	velocity.x = move_toward(velocity.x, walk.x, accel * delta)
	velocity.z = move_toward(velocity.z, walk.y, accel * delta)



	move_and_slide()

func _input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if ev.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if ev is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var look = ev.relative * -mouse_sensitivity / 1000

		if DisplayServer.get_name() == &"web":
			look *=  0.6 # Look is faster on the web for some reason

		rotate_y(look.x)
		$Camera3D.rotate_x(look.y)
		const max_vertical_look = PI/2
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -max_vertical_look, max_vertical_look)
	

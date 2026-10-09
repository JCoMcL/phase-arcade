extends Node3D
class_name ControlPlane
## THis node has a description

var input_tracker:InputTracker
func _ready():
	var cab = ArcadeCabinet.get_cabinet(self)
	if not cab.is_node_ready():
		print("cabbie is sleepy")
		await cab.ready
	input_tracker = cab.input_tracker

func fbool(b:bool) -> float:
	return 1.0 if b else 0.0

func rotate_control(c:Node3D, v:Vector2, delta:float, travel:float=0.3, speed:float=10):
	c.rotation = c.rotation.move_toward(Vector3(v.y,0,-v.x) * travel, speed * delta)
func press_control(c:Node3D, f:float, delta:float, travel:float=0.004, speed:float=4):
	c.position.y = move_toward(c.position.y, f * -travel, speed * delta)

func _process(delta: float) -> void:
	rotate_control($Joystick/Stick, input_tracker.movement, delta)
	press_control($FireButton/Push_004, fbool(input_tracker.firing), delta, 0.004, 4)
	press_control($BombButton/Push_003, fbool(input_tracker.bombing), delta, 0.003, 4)

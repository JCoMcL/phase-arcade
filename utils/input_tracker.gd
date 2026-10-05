extends Object
class_name InputTracker

var movement: Vector2
var firing: bool
var bombing: bool

var _input_left: float
var _input_right: float
var _input_up: float
var _input_down: float

func sanity_check():
	if not Input.is_action_pressed("left"):
		_input_left = 0.0
	if not Input.is_action_pressed("right"):
		_input_right = 0.0
	if not Input.is_action_pressed("up"):
		_input_up = 0.0
	if not Input.is_action_pressed("down"):
		_input_down = 0.0

	if not Input.is_action_pressed("fire"):
		firing = false

func _input(ev: InputEvent) -> void:
	# NOTE: the lack of `elif` here is actually important for controllers
	if ev.is_action("left"):
		_input_left = ev.get_action_strength("left")
	if ev.is_action("right"):
		_input_right = ev.get_action_strength("right")
	if ev.is_action("forward"):
		_input_up = ev.get_action_strength("forward")
	if ev.is_action("backward"):
		_input_down = ev.get_action_strength("backward")

	elif ev.is_action("fire"):
		firing = not ev.is_action_released("fire")
	elif ev.is_action("bomb"):
		bombing = not ev.is_action_released("bomb")

	movement = Vector2(_input_right - _input_left, _input_down - _input_up)
	if movement.length_squared() > 1:
		movement = movement.normalized()

func reset():
	movement = Vector2.ZERO
	firing = false
	bombing = false
	_input_left=0
	_input_right=0
	_input_up=0
	_input_down=0

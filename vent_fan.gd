extends MeshInstance3D

var speed
var maxSpeed = 0.1
var minSpeed = 2.4
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed = rng.randf_range(minSpeed, maxSpeed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if rng.randf() > 0.7:
		speed = lerpf(speed, minSpeed, delta * 0.1)
	else:
		speed = lerpf(speed, maxSpeed, delta * 40.0)
	
	rotation += Vector3(delta * 2.0, 0, 0)#speed, 0, 0)
	pass

extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var velocity:Vector2
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity += input_tracker.movement_input * delta
	position += velocity
	var outer = get_parent().get_global_rect()
	var inner = get_global_rect()

	if inner.position.x < outer.position.x or inner.end.x > outer.end.x:
		velocity.x *= -1
		$AudioStreamPlayer2D.play()
	if inner.position.y < outer.position.y or inner.end.y > outer.end.y:
		velocity.y *= -1
		$AudioStreamPlayer2D.play()


var input_tracker = InputTracker.new()
func _unhandled_input(event: InputEvent) -> void:
	input_tracker._input(event)

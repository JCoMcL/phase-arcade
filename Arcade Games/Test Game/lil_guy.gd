extends TextureRect

var velocity:Vector2
func _process(delta: float) -> void:
	velocity += ArcadeCabinet.get_input_state(self).movement * delta
	position += velocity
	var outer = get_parent().get_global_rect()
	var inner = get_global_rect()

	if inner.position.x < outer.position.x or inner.end.x > outer.end.x:
		velocity.x *= -1
		$AudioStreamPlayer2D.play()
	if inner.position.y < outer.position.y or inner.end.y > outer.end.y:
		velocity.y *= -1
		$AudioStreamPlayer2D.play()

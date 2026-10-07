class_name Inertial #NOTE: behaviours that move based on velocity should inherit from this
extends Behaviour

@export_range(0, 10) var drag = 0
@export_range(0, 1, 0.01) var randomize_drag: float = 0

var effective_drag = drag

func _initialize(u: Unit):
	effective_drag = Yute.vary(drag, randomize_drag)

func _process(u: Unit, delta: float):
	super(u, delta)
	var decay := clampf(1.0 - effective_drag * delta, 0.0, 1.0)
	u.velocity *= decay
	move_and_collide(u, u.velocity * delta)

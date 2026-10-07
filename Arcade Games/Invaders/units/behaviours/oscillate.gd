class_name Oscillate
extends Behaviour

@export_range(0.01, 10) var x_frequency = 1.0
@export_range(0.01, 10) var y_frequency = 0.4
@export var amplitude = Vector2.ONE
@export_range(0, 0.9) var frequency_spread = 0.1
const time_factor = TAU / 1000
var time_offset: Vector2
var frequency_factor: Vector2

func spread():
	return randf_range(1-frequency_spread, 1+frequency_spread)

func _initialize(u: Unit):
	super(u)
	time_offset = Vector2(randf() * TAU, randf() * TAU)
	frequency_factor = Vector2(spread(), spread())

func _process(u: Unit, delta: float):
	super(u, delta)
	u.position += Vector2(
		sin((Time.get_ticks_msec() * time_factor + time_offset.x) * x_frequency * frequency_factor.x) * x_frequency,
		sin((Time.get_ticks_msec() * time_factor + time_offset.y) * y_frequency * frequency_factor.y) * y_frequency
	) * amplitude * delta

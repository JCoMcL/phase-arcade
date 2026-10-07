class_name Fuse
extends Behaviour

@export_range(0,60) var fuse_time = 3.0
@export_range(0,1.0) var variability = 0.0

var timer: SceneTreeTimer
func _initialize(u: Unit):
	if timer and timer.timeout.is_connected(u._hit):
		timer.timeout.disconnect(u._hit)
	timer = u.get_tree().create_timer(
		fuse_time + randf_range(fuse_time*variability*0.5, fuse_time*variability*-0.5)
	)
	timer.timeout.connect(u._hit)

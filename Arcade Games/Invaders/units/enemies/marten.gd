extends Unit

@export var target: Unit
@export var h_distance: float = 50
@export_range(0,1) var h_distance_variance = 0.2

var home: Vector2
func wakeup():
	super()
	home = global_position

func windup():
	get_sprite().action_pose = true
	await $Shoota.windup_ended
	get_sprite().action_pose = false

func try_acquire_target():
	var game = Game.get_game(self)
	if game:
		target = game.current_player
	if not target or not target.alive:
		await Utils.delay(1)
		try_acquire_target()
	else:
		target.expire.connect(try_acquire_target)

var _h_dist: float
func _ready():
	super()
	_h_dist = Yute.vary(h_distance, h_distance_variance)
	$Shoota.windup_started.connect(windup)
	if not target or not target.alive:
		await try_acquire_target()


func harrying_position(to: Vector2, horizontal_distance:float =40) -> Vector2:
	return Vector2	(
		to.x + horizontal_distance * sign(home.x - to.x),
		home.y
	)

func _physics_process(delta: float) -> void:
	if target:
		velocity = velocity.move_toward(harrying_position(target.global_position, _h_dist) - global_position, 100.0 * delta)
		move_and_slide()
	super(delta)

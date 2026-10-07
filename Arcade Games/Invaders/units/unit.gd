class_name Unit
extends CharacterBody2D

@export var behaviours: Array[Behaviour]
@export var health: int = 0
@export var auto_free = true
@export var points_worth = 0
@export var expire_outside_play_area = false
@export var expire_fx: Array[FXID]

signal expire
@onready var current_health:int  = health
var direction: Vector2
var monitoring_play_area = false:
	set(b):
		monitoring_play_area = b
		if b:
			collision_layer |= Layers.physics2D["AreaBounded"]
		else:
			collision_layer &= ~Layers.physics2D["AreaBounded"]
var inside_play_area: bool

func _on_enter_play_area():
	inside_play_area = true

func _on_exit_play_area():
	inside_play_area = false
	assert(monitoring_play_area)
	if alive and expire_outside_play_area:
		_expire()

func get_sprite() -> CharacterSprite2D:
	for c in get_children():
		if c is CharacterSprite2D:
			return c
	return null

var alive: bool = true
func _expire():
	if not alive:
		print("Warning: %s: double expire" % self)
		return
	alive = false
	velocity = Vector2.ZERO
	for fxid in expire_fx:
		var fx = fxid.play(self)
		if fx is VFXSprite:
			InvadersGame.add_to_playfield(fx, self)
	expire.emit()
	if auto_free:
		queue_free()

signal hit
func _hit(damage: int = 1) -> int:
	if not alive:
		print("Warning: hit after death")
		return 0
	current_health -= damage
	hit.emit()
	if current_health <= 0:
		_expire()
		return points_worth
	return 0

var points_earned = 0
signal points_claimed(int)
func claim_points(points: int):
	points_earned += points
	points_claimed.emit(points)

# May be called multiple times, use wisely
func wakeup():
	if not is_inside_tree():
		print("Warn: %s: attempt wakeup while still outside tree" % self)
		return
	alive = true
	process_mode = Node.PROCESS_MODE_INHERIT
	current_health = health
	init_behaviours()
	reset_physics_interpolation()

func handle_collision(c: Node2D):
	for b in behaviours:
		b._handle_collision(c, self)

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		for b in behaviours:
			if inside_play_area or not b.play_area_bounded:
				b._process(self, delta)

func init_behaviours():
	if not Engine.is_editor_hint():
		for b in behaviours:
			if b:
				b._initialize(self)
				monitoring_play_area = monitoring_play_area or b.play_area_bounded
			else:
				print("Warning: %s: behaviours not set up properly!" % self)

func is_on_enemy_team() -> bool:
	if collision_layer & Layers.physics2D["Friendly"]:
		return false
	if collision_layer & Layers.physics2D["Enemy"]:
		return true
	if collision_mask & Layers.physics2D["Friendly"]:
		return true
	return false

func on_frame_changed(frame: int):
	pass

func _on_frame_changed():
	on_frame_changed(get_sprite().frame)

func _ready():
	wakeup()
	get_sprite().frame_changed.connect(_on_frame_changed)
	monitoring_play_area = monitoring_play_area or expire_outside_play_area

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	if not get_sprite():
		warnings.append("no Sprite2D")
	return warnings

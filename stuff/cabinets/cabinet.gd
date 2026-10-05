extends Node3D
class_name ArcadeCabinet

@export var start_powered_on:bool
@export var circuit:StringName
@export var game_scene:PackedScene

@onready var game_parent = %CRTLayer
var curr_game:Node

# --- External Interface ---

func _interacted_by(operator:FirstPersonCharacter):
	operator.set_active_cabinet(self)

func on_operator_release():
	%ScreenInteractZone.active = true
	input_tracker.reset()

func get_observation_delta(from:Camera3D) -> CameraTransform:
	return CameraTransform.new(%ObservationPoint, from)

var input_tracker=InputTracker.new()
func push_input(ev: InputEvent):
	get_viewport().set_input_as_handled()
	input_tracker._input(ev)
	$ControlPlane.track_input(ev)
	$SubViewport.push_input(ev)

const GAME_AUDIO_TYPES := [&"AudioStreamPlayer", &"AudioStreamPlayer2D"]

var power:bool
func set_power_state(on:bool):
	power = on
	if not is_node_ready():
		await ready
	if on:
		if game_scene:
			curr_game = game_scene.instantiate()
			game_parent.add_child(curr_game)
			curr_game.z_index = -1
			print(game_parent)
			print(game_parent.get_children())
		$Screen.texture = $SubViewport.get_texture()
	else:
		$Screen.texture = null
		if curr_game:
			curr_game.queue_free()
	%ScreenInteractZone.active = on

# --- Circuits ---

func _on_circuit_switched(on:bool):
	set_power_state(on)

## Subscribes the cabinet to [param s], seeding the circuit while it's still fresh.
func join_circuit(s:StringName):
	var switched := HandyLight.register_circuit(s)
	switched.to.connect(_on_circuit_switched)
	if not switched.state and start_powered_on:
		switched.state = start_powered_on
	else:
		set_power_state(switched.state)

# --- Internal Interface ---

static func get_cabinet(from:Node) -> ArcadeCabinet:
	while from and from is not ArcadeCabinet:
		from = from.get_parent()
	return from

static func get_input_state(from:Node) -> InputTracker:
	var cab = get_cabinet(from)
	if cab:
		return cab.input_tracker
	return null

func _route_game_audio(node: Node) -> void:
	if not $SubViewport.is_ancestor_of(node):
		return
	if node is AudioStreamPlayer:
		(node as AudioStreamPlayer).bus = ArcadeCabinetAudio.GAME_BUS
	elif node is AudioStreamPlayer2D:
		(node as AudioStreamPlayer2D).bus = ArcadeCabinetAudio.GAME_BUS

# --- Main ---

func _ready() -> void:
	if circuit != &"":
		join_circuit(circuit)
	else:
		set_power_state(start_powered_on)
	%ScreenInteractZone.interacted_by.connect(_interacted_by)
	for type in GAME_AUDIO_TYPES:
		for player in $SubViewport.find_children("*", type, true, false):
			_route_game_audio(player)
	get_tree().node_added.connect(_route_game_audio)

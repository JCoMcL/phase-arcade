extends Node3D
class_name ArcadeCabinet

@export var start_powered_on:bool
@export var circuit:StringName
@export var game_scene:PackedScene

@onready var game_parent = %CRTLayer
var curr_game:Node

func _interacted_by(operator:FirstPersonCharacter):
	operator.set_active_cabinet(self)

func on_operator_release():
	%ScreenInteractZone.active = true

func get_observation_delta(from:Camera3D) -> CameraTransform:
	return CameraTransform.new(%ObservationPoint, from)

func push_input(ev: InputEvent):
	get_viewport().set_input_as_handled()
	$SubViewport.push_input(ev)

const GAME_AUDIO_TYPES := [&"AudioStreamPlayer", &"AudioStreamPlayer2D"]

var power:bool
func set_power_state(on:bool):
	if not is_node_ready():
		await ready
	if on:
		if game_scene:
			curr_game = game_scene.instantiate()
			game_parent.add_child(curr_game)
			print(game_parent)
			print(game_parent.get_children())
		$Screen.texture = $SubViewport.get_texture()
	else:
		$Screen.texture = null
		if curr_game:
			curr_game.queue_free()
	%ScreenInteractZone.active = on

func _ready() -> void:
	set_power_state(start_powered_on)
	%ScreenInteractZone.interacted_by.connect(_interacted_by)
	for type in GAME_AUDIO_TYPES:
		for player in $SubViewport.find_children("*", type, true, false):
			_route_game_audio(player)
	get_tree().node_added.connect(_route_game_audio)
	if not start_powered_on:
		await get_tree().create_timer(6).timeout
		set_power_state(true)

func _route_game_audio(node: Node) -> void:
	if not $SubViewport.is_ancestor_of(node):
		return
	if node is AudioStreamPlayer:
		(node as AudioStreamPlayer).bus = ArcadeCabinetAudio.GAME_BUS
	elif node is AudioStreamPlayer2D:
		(node as AudioStreamPlayer2D).bus = ArcadeCabinetAudio.GAME_BUS

extends Node3D
class_name ArcadeCabinet

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

func _ready() -> void:
	$Screen.texture = $SubViewport.get_texture()
	%ScreenInteractZone.interacted_by.connect(_interacted_by)
	for type in GAME_AUDIO_TYPES:
		for player in $SubViewport.find_children("*", type, true, false):
			_route_game_audio(player)
	get_tree().node_added.connect(_route_game_audio)

func _route_game_audio(node: Node) -> void:
	if not $SubViewport.is_ancestor_of(node):
		return
	if node is AudioStreamPlayer:
		(node as AudioStreamPlayer).bus = ArcadeCabinetAudio.GAME_BUS
	elif node is AudioStreamPlayer2D:
		(node as AudioStreamPlayer2D).bus = ArcadeCabinetAudio.GAME_BUS

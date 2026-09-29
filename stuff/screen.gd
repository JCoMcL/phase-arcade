@tool
extends Node3D

@export var texture:Texture2D:
	set(tex):
		if not is_node_ready():
			await  ready
		$SmArcadeCabAScreen.material_override.emission_texture = tex
	get():
		return $SmArcadeCabAScreen.material_override.emission_texture

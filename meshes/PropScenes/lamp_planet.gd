@tool
extends HandyLight

func _on_circuit_switched(state:bool):
	super(state)
	$SM_PlanetLamp/PlanetLamp.mesh.surface_get_material(1).set_shader_parameter("On", state)
